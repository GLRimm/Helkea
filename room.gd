extends Node2D

@export var enemy_scene: PackedScene
@export var health_pack_scene: PackedScene

@export var bedroom_tileset: TileSet 
@export var kitchen_tileset: TileSet
@export var living_room_tileset: TileSet
@export var bathroom_tileset: TileSet

@onready var wall_tile_map = $TileMapWalls

var room_data: RoomData
var is_cleared: bool = false
var is_visited: bool = false
var active_enemies: Array[Node] = []
var all_doors: Dictionary = {}

var layout_generator: RoomLayoutGenerator

signal room_cleared
signal door_entered(direction: String)

const TILE_SIZE = 32
const OPEN_NORTH_DOOR = preload("res://patterns/open_north_door.tres")
const CLOSED_NORTH_DOOR = preload("res://patterns/closed_north_door.tres")
const OPEN_WEST_DOOR = preload("res://patterns/open_west_door.tres")
const CLOSED_WEST_DOOR = preload("res://patterns/closed_west_door.tres")
const OPEN_EAST_DOOR = preload("res://patterns/open_east_door.tres")
const CLOSED_EAST_DOOR = preload("res://patterns/closed_east_door.tres")
const OPEN_SOUTH_DOOR = preload("res://patterns/open_south_door.tres")
const CLOSED_SOUTH_DOOR = preload("res://patterns/closed_south_door.tres")

func _init():
	layout_generator = RoomLayoutGenerator.new()
	
func _ready():
	add_child(layout_generator)

func setup(data: RoomData):
	room_data = data
	is_cleared = data.is_cleared
	is_visited = data.is_visited
	
	if room_data.wall_tiles.is_empty() and room_data.furniture_zones.is_empty():
		layout_generator.generate_layout(room_data)
		print("Generated %s layout for room #%d with %d zones" % [
			room_data.layout_type,
			room_data.room_id,
			room_data.furniture_zones.size()
		])
	await get_tree().process_frame
		
	_apply_layout()
	_setup_doors()
	_configure_doors()
	_apply_room_tint()
	
func _apply_layout():
	"""
	Apply the generated layout to the room
	This will place walls and furniture based on room_data
	"""
	# TODO: Implement this based on your tilemap setup
	# For now, just print debug info
	print("  Wall tiles: %d" % room_data.wall_tiles.size())
	print("  Furniture zones: %d" % room_data.furniture_zones.size())
	
	# _place_walls()
	_place_furniture_in_zones()
	
	
func _place_furniture_in_zones():
	
	if not has_node("FurnitureTileMapLayer"):
		print("Warning: No FurnitureTileMapLayer found!")
		return
	
	var furniture_layer = $FurnitureTileMapLayer
	furniture_layer.clear()
	
	# Set appropriate tileset based on room's furniture_set
	var tileset = living_room_tileset # _get_furniture_tileset()
	if not tileset:
		print("Warning: No tileset for furniture_set: %s" % room_data.furniture_set)
		return
	
	furniture_layer.tile_set = tileset
	
	# Fill each zone with furniture
	for zone in room_data.furniture_zones:
		_fill_zone_with_furniture(furniture_layer, zone, tileset)
		

func _get_furniture_tileset() -> TileSet:
	"""Get the appropriate tileset for this room's furniture set"""
	match room_data.furniture_set:
		"bedroom":
			return bedroom_tileset
		"kitchen":
			return kitchen_tileset
		"living_room":
			return living_room_tileset
		"bathroom":
			return bathroom_tileset
		_:
			return living_room_tileset  # Default fallback
		
func _fill_zone_with_furniture(layer: TileMapLayer, zone: Rect2i, tileset: TileSet):
	"""Randomly place furniture tiles in a zone"""
	# Calculate how many furniture pieces to place based on zone size
	var zone_area = zone.size.x * zone.size.y
	var num_pieces = clampi(zone_area / 4, 1, 4)  # 1-4 pieces per zone
	
	# Get available tiles from tileset
	var source = tileset.get_source(0)
	if not source:
		return
	
	var available_tiles = source.get_tiles_count()
	if available_tiles == 0:
		return
	
	# Track placed tiles to avoid overlaps
	var placed_positions = []
	
	for i in range(num_pieces):
		# Try up to 5 times to place this piece
		for attempt in range(5):
			# Pick random tile from tileset
			var tile_id = randi_range(0, available_tiles - 1)
			var atlas_coords = source.get_tile_id(tile_id)
			
			# Random position within zone
			var tile_x = zone.position.x + randi_range(0, max(0, zone.size.x - 1))
			var tile_y = zone.position.y + randi_range(0, max(0, zone.size.y - 1))
			var tile_pos = Vector2i(tile_x, tile_y)
			
			# Check if position is already occupied
			if tile_pos in placed_positions:
				continue
			
			# Place the tile
			layer.set_cell(tile_pos, 0, atlas_coords)
			placed_positions.append(tile_pos)
			break  # Successfully placed, move to next piece

func _setup_doors():
	for door in $Doors.get_children():
		if not door is Door:
			continue
		
		# Auto-detect direction from node name
		var door_name = door.name.to_lower()
		for direction in ["north", "south", "east", "west"]:
			if direction in door_name:
				door.direction = direction
				all_doors[direction] = door
				door.player_entered_door.connect(_on_door_entered)
				break

func _configure_doors():
	for direction in all_doors.keys():
		var door = all_doors[direction]
		var is_connected = room_data.connections.get(direction, false)
		door.monitoring = is_connected
		if is_connected and not is_cleared:
			_lock_door(door, true)

func _apply_room_tint():
	match room_data.room_type:
		"start": modulate = Color(0.8, 1.0, 0.8)
		"boss": modulate = Color(1.0, 0.8, 0.8)
		"treasure": modulate = Color(1.0, 1.0, 0.7)

func activate():
	# Add door cooldowns to prevent instant re-triggering
	await get_tree().process_frame
	for door in all_doors.values():
		door.start_cooldown(0.5)
	
	if is_visited and is_cleared:
		_lock_all_doors(false)
		return
	
	is_visited = true
	room_data.is_visited = true
	
	if not is_cleared and room_data.room_type != "start":
		_spawn_enemies()
	else:
		_lock_all_doors(false)

func _spawn_enemies():
	var spawn_points = $EnemySpawns.get_children()
	
	if spawn_points.is_empty() or not enemy_scene:
		_on_room_cleared()
		return
	
	_lock_all_doors(true)
	
	# Spawn 1 enemy for testing
	var spawn_point = spawn_points.pick_random()
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position
	add_child(enemy)
	active_enemies.append(enemy)
	
	if enemy.has_node("HealthComponent"):
		enemy.get_node("HealthComponent").died.connect(_on_enemy_died)

func _on_enemy_died(location: Vector2):
	if health_pack_scene:
		var health_pack = health_pack_scene.instantiate()
		health_pack.global_position = location
		add_child(health_pack)
	
	await get_tree().create_timer(0.1).timeout
	_check_room_cleared()

func _check_room_cleared():
	var remaining = active_enemies.filter(func(e): return is_instance_valid(e)).size()
	if remaining == 0:
		_on_room_cleared()

func _on_room_cleared():
	is_cleared = true
	room_data.is_cleared = true
	_lock_all_doors(false)
	
	if room_data.room_type == "treasure":
		_spawn_treasure()
	
	room_cleared.emit()

func _lock_all_doors(should_lock: bool):
	for door in all_doors.values():
		if door.visible and room_data.connections.get(door.direction, false):
			_lock_door(door, should_lock)
			
func _lock_door(door: Door, should_lock: bool):
	if not has_node("TileMapWalls"):
		print("WARNING: No TileMapWalls node found!")
		return
	
	var wall_tile_map = $TileMapWalls
	
	print("DEBUG: _lock_door called for %s door, should_lock=%s" % [door.direction, should_lock])
	
	match door.direction:
		"north":
			var pattern = CLOSED_NORTH_DOOR if should_lock else OPEN_NORTH_DOOR
			print("DEBUG: Setting north door pattern at (8, -3)")
			wall_tile_map.set_pattern(Vector2i(8, -3), pattern)
		"west":
			var pattern = CLOSED_WEST_DOOR if should_lock else OPEN_WEST_DOOR
			print("DEBUG: Setting west door pattern at (-1, 6)")
			wall_tile_map.set_pattern(Vector2i(-1, 6), pattern)
		"east":
			var pattern = CLOSED_EAST_DOOR if should_lock else OPEN_EAST_DOOR
			print("DEBUG: Setting east door pattern at (20, 6)")
			wall_tile_map.set_pattern(Vector2i(20, 6), pattern)
		"south":
			var pattern = CLOSED_SOUTH_DOOR if should_lock else OPEN_SOUTH_DOOR
			print("DEBUG: Setting south door pattern at (8, 19)")
			wall_tile_map.set_pattern(Vector2i(8, 19), pattern)
	
	print("DEBUG: Pattern applied, calling door.lock(%s)" % should_lock)
	door.lock(should_lock)

func _spawn_treasure():
	if health_pack_scene:
		var health_pack = health_pack_scene.instantiate()
		health_pack.global_position = Vector2(320, 180)
		add_child(health_pack)

func get_spawn_position() -> Vector2:
	return $PlayerSpawn.global_position if has_node("PlayerSpawn") else Vector2(320, 180)

func get_door_spawn_position(from_direction: String) -> Vector2:
	const OPPOSITE = {"north": "south", "south": "north", "east": "west", "west": "east"}
	const OFFSETS = {"north": Vector2(0, 80), "south": Vector2(0, -32), "east": Vector2(-32, 0), "west": Vector2(80, 0)}
	
	var spawn_dir = OPPOSITE.get(from_direction, "south")
	if spawn_dir in all_doors:
		return all_doors[spawn_dir].global_position + OFFSETS.get(spawn_dir, Vector2.ZERO)
	
	return get_spawn_position()

func _on_door_entered(direction: String):
	door_entered.emit(direction)
