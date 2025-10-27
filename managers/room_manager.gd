extends Node

var current_room: Node2D
var player: CharacterBody2D
var level: int

@export var room_container: Node2D
@export var default_room_scene: PackedScene

func _ready():
	level = 1
	if default_room_scene:
		load_room(default_room_scene)
		
func load_room(room_scene: PackedScene):
	if current_room:
		current_room.queue_free()
		
	current_room = room_scene.instantiate()
	current_room.enemy_count = level
	room_container.add_child(current_room)
	
	current_room.door_entered.connect(_on_door_entered)
	
	spawn_player()
	
func spawn_player():
	if not player:
		player = get_tree().get_first_node_in_group("player")
		
	if not player:
		print("no player found")
		return
	
	var spawn_pos = current_room.get_spawn_position()
	
	player.global_position = spawn_pos
	

	
func _on_door_entered():
	level += 1
	load_room(default_room_scene)
