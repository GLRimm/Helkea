extends Node
class_name DungeonManager

var player: CharacterBody2D

var dungeon_generator: DungeonGenerator
var dungeon_rooms: Dictionary = {}
var loaded_rooms: Dictionary = {}
var current_room_position: Vector2i = Vector2i.ZERO
var current_room = null

var is_transitioning: bool = false

@export var room_container: Node2D
@export var default_room_scene: PackedScene
@export var camera: Camera2D

func _ready():
	add_to_group("dungeon_manager")
	
	dungeon_generator = DungeonGenerator.new()
	add_child(dungeon_generator)
	
	generate_new_dungeon()
		
func generate_new_dungeon():
	_clear_dungeon()
	dungeon_rooms = dungeon_generator.generate_dungeon()
	dungeon_generator.print_dungeon_layout()
	
	for pos in dungeon_rooms.keys():
		if dungeon_rooms[pos].room_type == "start":
			current_room_position = pos
			break
	
	current_room = _load_room_at_position(current_room_position)
	spawn_player()
	
func _clear_dungeon():
	for room in loaded_rooms.values():
		if is_instance_valid(room):
			room.queue_free()
	loaded_rooms.clear()
	dungeon_rooms.clear()
	current_room = null
	
func _load_room_at_position(grid_pos: Vector2i):
	if grid_pos in loaded_rooms:
		return loaded_rooms[grid_pos]
		
	if grid_pos not in dungeon_rooms:
		push_error("Trying to load non-existant room at %s" % grid_pos)
		return null
	
	var room_data = dungeon_rooms[grid_pos]
	
	var room_scene = default_room_scene # TODO: make different scenes for different room types
	
	if not room_scene:
		push_error("No default room scene set!")
		return null
	
	var room = room_scene.instantiate()
	room_container.add_child(room)
	
	room.position = Vector2.ZERO # TODO: multiple visible rooms?
	
	room.setup(room_data)
	
	room.door_entered.connect(_on_door_entered)
	room.room_cleared.connect(_on_room_cleared)
	
	loaded_rooms[grid_pos] = room  # Cache the room
	return room
	
func spawn_player():
	if not player:
		player = get_tree().get_first_node_in_group("player")
		
	if not player:
		print("no player found")
		return
	
	var spawn_pos = current_room.get_spawn_position()
	
	player.global_position = spawn_pos
	
	current_room.activate()
	
func transition_to_room(direction: String):
	if is_transitioning:
		return
	
	var direction_vec = dungeon_generator.DIRECTIONS.get(direction, Vector2i.ZERO)
	if direction_vec == Vector2i.ZERO:
		push_error("Invalid direction: %s" % direction)
		return
	
	var target_pos = current_room_position + direction_vec
	if target_pos not in dungeon_rooms:
		push_error("No room at position %s" % target_pos)
		return
	
	is_transitioning = true
	await _transition_to_room_async(target_pos, direction)
	is_transitioning = false
	
func _transition_to_room_async(target_pos: Vector2i, from_direction: String):
	if current_room:
		loaded_rooms.erase(current_room_position)
		current_room.queue_free()
		current_room = null
		
	await get_tree().process_frame
	
	# Load target room if not already loaded
	var target_room = _load_room_at_position(target_pos)
	if not target_room:
		push_error("Failed to load room at %s" % target_pos)
		return
	
	# Update current room reference
	current_room_position = target_pos
	current_room = target_room
	current_room.visible = true
	
	# Position player at correct door
	if player:
		var spawn_pos = current_room.get_door_spawn_position(from_direction)
		player.global_position = spawn_pos
	
	# Optional: Camera transition (simple version)
	if camera:
		camera.global_position = current_room.global_position + Vector2(320, 180)
	
	# Activate new room
	current_room.activate()
	
func _on_room_cleared():
	print("Room cleared at position: %s" % current_room_position)
	
	# Check if boss room was cleared
	if dungeon_rooms[current_room_position].room_type == "boss":
		_on_dungeon_completed()
	
func _on_dungeon_completed():
	print("=== DUNGEON COMPLETED! ===")
	# TODO: Show victory screen, generate new dungeon, etc.
	await get_tree().create_timer(2.0).timeout
	generate_new_dungeon()
	
func _on_door_entered(direction: String):
	transition_to_room(direction)
	
