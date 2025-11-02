extends Camera2D

@export var player: Node2D
@export var detection_range: float = 300
@export var camera_smoothness: float = 4.0
@export var enemy_group: String = "enemies"

var target_position: Vector2 = Vector2.ZERO

func _ready():
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if player:
		global_position = player.global_position
		
		
func _process(delta: float) -> void:
	if not player:
		return
	
	# Get all enemies from the specified group
	var all_enemies: Array = get_tree().get_nodes_in_group(enemy_group)
	
	# Calculate the target camera position
	target_position = calculate_camera_position(all_enemies)
	
	# Smoothly interpolate to the target position
	global_position = global_position.lerp(target_position, camera_smoothness * delta)


func calculate_camera_position(enemies: Array) -> Vector2:
	var player_pos: Vector2 = player.global_position
	
	# Filter enemies that are within range
	var enemies_in_range: Array[Node2D] = []
	
	for enemy in enemies:
		if enemy is Node2D:
			var distance: float = player_pos.distance_to(enemy.global_position)
			if distance <= detection_range:
				enemies_in_range.append(enemy)
	
	# If no enemies in range, center on player
	if enemies_in_range.is_empty():
		return player_pos
	
	# Calculate average position of enemies in range
	var average_enemy_pos: Vector2 = Vector2.ZERO
	for enemy in enemies_in_range:
		average_enemy_pos += enemy.global_position
	average_enemy_pos /= enemies_in_range.size()
	
	# Return position halfway between player and average enemy position
	return player_pos.lerp(average_enemy_pos, 0.4)


# Optional: Public method to update detection range at runtime
func set_detection_range(new_range: float) -> void:
	detection_range = new_range


# Optional: Public method to change camera smoothness at runtime
func set_smoothness(new_smoothness: float) -> void:
	camera_smoothness = new_smoothness
