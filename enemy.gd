extends CharacterBody2D

@export var speed = 120
@export var knockback_strength = 400

@onready var collision_shape = $CollisionShape2D

var player = null
var is_stunned = false

func _ready():
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")
	$HealthBar.update_health($HealthComponent.current_health, $HealthComponent.max_health)
	
func _physics_process(delta):
	if is_stunned:
		move_and_slide()
		velocity = velocity.lerp(Vector2.ZERO, 0.1)
		
		if velocity.length() < 10:
			is_stunned = false
			set_collision_mask_value(2, true)
			collision_shape.disabled = false
		return
	
	if player == null:
		return
	
	# Calculate direction to player
	var direction = (player.global_position - global_position).normalized()
	
	# Set velocity and move
	velocity = direction * speed
	move_and_slide()

func take_damage(amount: float, attacker_position: Vector2):
	$HealthComponent.take_damage(amount, global_position)
	var knockback_direction = (global_position - attacker_position).normalized()
	velocity = knockback_direction * knockback_strength
	is_stunned = true
	collision_shape.disabled = true
	set_collision_mask_value(2, false)
	

func _on_health_changed(curr: float, max: float) -> void:
	$HealthBar.update_health(curr, max)

func _on_died(location):
	queue_free()
