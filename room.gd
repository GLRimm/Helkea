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

signal room_cleared
signal door_entered(direction: String)

const TILE_SIZE = 32



func setup(data: RoomData):
	room_data = data
	is_cleared = data.is_cleared
	is_visited = data.is_visited
	
	if room_data.furniture_placements.is_empty():
		var layout = RoomLayoutGenerator.generate_layout(room_data)
		room_data.furniture_placements = layout["furniture_placements"]
		print("Generated %s layout for room #%d with %d zones" % [
			RoomData.LayoutType.keys()[room_data.layout_type],
			room_data.room_id,
			room_data.furniture_placements.size()
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
	# print("  Wall tiles: %d" % room_data.wall_tiles.size())
	print("  Furniture zones: %d" % room_data.furniture_placements.size())
	
	# _place_walls()
	_place_furniture_in_zones()
	
	
func _place_furniture_in_zones():
	for placement in room_data.furniture_placements:
		#
		var furniture_data = FurnitureDB.get_random_furniture(
			room_data.furniture_set,
			placement.size_requirement
		)
		
		if not furniture_data:
			# Fallback: get any furniture if exact size not available
			furniture_data = FurnitureDB.get_random_furniture(room_data.furniture_set)
		
		if furniture_data:
			_spawn_furniture(furniture_data, placement.position * 32, placement.rotation)

func _spawn_furniture(data: FurniturePieceData, position: Vector2, rotation: float = 0.0):
	var furniture_scene = preload("res://furniture.tscn")
	var furniture = furniture_scene.instantiate()
	furniture.furniture_data = data
	furniture.position = position
	furniture.rotation_degrees = rotation
	add_child(furniture)
		

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
			door.lock(true)

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
	const OFFSETS = {"north": Vector2(50, 96), "south": Vector2(50, 0), "east": Vector2(0, 128), "west": Vector2(32, 128)}
	
	var spawn_dir = OPPOSITE.get(from_direction, "south")
	if spawn_dir in all_doors:
		return all_doors[spawn_dir].global_position + OFFSETS.get(spawn_dir, Vector2.ZERO)
	
	return get_spawn_position()

func _on_door_entered(direction: String):
	door_entered.emit(direction)
