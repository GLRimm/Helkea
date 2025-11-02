extends Node2D

@export var enemy_count: int = 1
@export var enemy_scene: PackedScene
@export var health_pack_scene: PackedScene

var room_data: RoomData
var is_cleared: bool = false
var is_visited: bool = false

var active_enemies: Array[Node] = []
var all_doors: Dictionary = {}

signal room_cleared
signal door_entered(direction: String)

func _ready() -> void:
	pass
	
func _setup_doors():
	print("=== SETTING UP DOORS ===")
	var door_count = $Doors.get_children().size()
	print("Found %d door nodes" % door_count)
	
	for door in $Doors.get_children():
		print("  Door node: ", door.name, " | Type: ", door.get_class())
		if door is Area2D:
			var door_name = door.name.to_lower()
			var direction = "north"
			# Extract direction from name
			if "south" in door_name:
				direction = "south"
			elif "east" in door_name:
				direction = "east"
			elif "west" in door_name:
				direction = "west"
			
			print("    -> Mapped to direction: ", direction)
			all_doors[direction] = door
			
			# Connect signal
			if door.has_signal("player_entered_door"):
				door.player_entered_door.connect(_on_door_entered)
	
	print("all_doors dictionary populated with %d entries" % all_doors.size())
	print("Keys: ", all_doors.keys())
			
func setup(data: RoomData):
	room_data = data
	is_cleared = data.is_cleared
	is_visited = data.is_visited
	
	_setup_doors()
	_configure_doors()
	_setup_room_appearance()
	
func _configure_doors():
	for direction in all_doors.keys():
		var door = all_doors[direction]
		var is_connected = room_data.connections[direction]
		
		door.visible = is_connected
		door.monitoring = is_connected
		
		if is_connected and not is_cleared:
			door.lock(true)
			
func _setup_room_appearance():
	match room_data.room_type:
		"start":
			modulate = Color(0.8, 1.0, 0.8)
		"boss":
			modulate = Color(1.0, 0.8, 0.8)
		"treasure":
			modulate = Color(1.0, 1.0, 0.7)
			
func activate():
	print("=== ACTIVATING ROOM ===")
	print("Room type: ", room_data.room_type)
	print("Is cleared: ", is_cleared)
	print("Is visited: ", is_visited)
	
	if is_visited and is_cleared:
		_lock_all_doors(false)
		return
	
	is_visited = true
	room_data.is_visited = true
	
	# Spawn enemies if this is the first visit
	if not is_cleared and room_data.room_type != "start":
		spawn_enemies()
	else:
		_lock_all_doors(false)
	
	
func spawn_enemies():
	var spawn_points = $EnemySpawns.get_children()
	
	if spawn_points.is_empty():
		print("No spawns found")
		_on_room_cleared()
		return
	if not enemy_scene:
		print("No enemy scene assigned")
		_on_room_cleared()
		return
		
	if room_data.room_type == "start":
		_on_room_cleared()
		return
		
	_lock_all_doors(true)
	
	for i in range(enemy_count):
		var spawn_point = spawn_points.pick_random()
		
		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_point.global_position
		
		add_child(enemy)
		
		active_enemies.append(enemy)
		
		if enemy.has_node("HealthComponent"):
			enemy.get_node("HealthComponent").died.connect(_on_enemy_died)

func _on_room_cleared():
	print("all enemies cleared")
	is_cleared = true
	room_data.is_cleared = true
	
	_lock_all_doors(false)
	
	# Spawn treasure for treasure rooms
	if room_data.room_type == "treasure":
		_spawn_treasure()
	
	room_cleared.emit()

func _lock_all_doors(should_lock: bool):
	for direction in all_doors.keys():
		var door = all_doors[direction]
		if door.visible and room_data.connections.get(direction, false):
			door.lock(should_lock)
			
func _spawn_treasure():
	# TODO: Spawn special treasure item
	# For now, spawn extra health packs
	if health_pack_scene:
		var treasure_pos = Vector2(320, 180)  # Center of room
		var health_pack = health_pack_scene.instantiate()
		health_pack.global_position = treasure_pos
		add_child(health_pack)
	
func _on_enemy_died(location: Vector2):
	# Check if all enemies dead
	var health_pack = health_pack_scene.instantiate()
	
	health_pack.global_position = location
	
	add_child(health_pack)
	
	print("enemy died")
	await get_tree().create_timer(0.1).timeout  # Small delay to let enemy queue_free
	_check_room_cleared()
	
func _check_room_cleared():
	var remaining_enemies = 0
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			remaining_enemies += 1
	
	if remaining_enemies == 0:
		print("all enemies cleared")
			
		_on_room_cleared()
		
func get_spawn_position() -> Vector2:
	print("spawning player in new room")
	return $PlayerSpawn.global_position
	
func get_door_spawn_position(from_direction: String) -> Vector2:
	var opposite_directions = {
		"north": "south",
		"south": "north",
		"east": "west",
		"west": "east"
	}
	
	var spawn_direction = opposite_directions.get(from_direction, "south")
	
	if spawn_direction in all_doors:
		# Position player slightly inside the room from the door
		var door_pos = all_doors[spawn_direction].global_position
		var offset = Vector2.ZERO
		
		match spawn_direction:
			"north":
				offset = Vector2(0, 64)  # Move down from north door
			"south":
				offset = Vector2(0, -32)  # Move up from south door
			"east":
				offset = Vector2(-32, 0)  # Move left from east door
			"west":
				offset = Vector2(64, 0)  # Move right from west door
		
		return door_pos + offset
	
	return get_spawn_position()

func _on_door_entered(direction: String):
	print("door entered")
	door_entered.emit(direction)
