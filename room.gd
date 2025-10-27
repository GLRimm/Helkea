extends Node2D

@export var enemy_count: int = 1
@export var enemy_scene: PackedScene
@export var health_pack_scene: PackedScene

var active_enemies: Array[Node] = []
var all_doors: Array[Area2D] = []

signal room_cleared
signal door_entered

func _ready() -> void:
	for door in $Doors.get_children():
		if door is Area2D:
			all_doors.append(door)
			door.player_entered_door.connect(_on_door_entered)
	spawn_enemies()
	
func spawn_enemies():
	var spawn_points = $EnemySpawns.get_children()
	
	if spawn_points.is_empty():
		print("No spawns found")
		room_cleared.emit()
		return
	if not enemy_scene:
		print("No enemy scene assigned")
		room_cleared.emit()
		return
	
	for i in range(enemy_count):
		var spawn_point = spawn_points[i]
		
		var enemy = enemy_scene.instantiate()
		enemy.global_position = spawn_point.global_position
		
		add_child(enemy)
		
		active_enemies.append(enemy)
		
		if enemy.has_node("HealthComponent"):
			enemy.get_node("HealthComponent").died.connect(_on_enemy_died)

		
	
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
		for door in all_doors:
			door.lock(false)
		room_cleared.emit()
		

func get_spawn_position() -> Vector2:
	print("spawning player in new room")
	return $PlayerSpawn.global_position

func _on_door_entered():
	print("door entered")
	door_entered.emit()
