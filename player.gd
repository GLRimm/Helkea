extends CharacterBody2D

@export var speed = 200
@export var knockback_strength = 300
@export var is_attacking = false

const ACCEL = 10

var screen_size
var direction = "down";
var is_stunned = false

func connect_to_player_data():
	PlayerData.health_changed.connect(_on_health_changed)
	PlayerData.died.connect(_on_died)

func _ready():
	connect_to_player_data()
	screen_size = get_viewport_rect()
	$AnimationPlayer.play("idle_down")

func get_8_direction(velocity):
	if velocity == Vector2.ZERO:
		return direction
	var angle = velocity.angle()
	# Convert angle to 8 directions
	if angle > -PI/8 and angle <= PI/8:
		return "right"
	elif angle > PI/8 and angle <= 3*PI/8:
		return "down_right"
	elif angle > 3*PI/8 and angle <= 5*PI/8:
		return "down"
	elif angle > 5*PI/8 and angle <= 7*PI/8:
		return "down_left"
	elif angle > 7*PI/8 or angle <= -7*PI/8:
		return "left"
	elif angle > -7*PI/8 and angle <= -5*PI/8:
		return "up_left"
	elif angle > -5*PI/8 and angle <= -3*PI/8:
		return "up"
	else:  # angle > -3*PI/8 and angle <= -PI/8
		return "up_right"
	
	

func _physics_process(delta: float) -> void:
	if is_stunned:
		move_and_slide()
		velocity = velocity.lerp(Vector2.ZERO, 0.15)
		
		if velocity.length() < 50:
			is_stunned = false
		return
		
	var axis = Vector2.ZERO
	
	if not is_attacking:
		if Input.is_action_pressed("move_right"):
			axis.x += 1
		if Input.is_action_pressed("move_left"):
			axis.x -= 1
		if Input.is_action_pressed("move_down"):
			axis.y += 1
		if Input.is_action_pressed("move_up"):
			axis.y -= 1
		
		direction = get_8_direction(axis)
	
	if Input.is_action_pressed("attack"):
		$AnimationPlayer.play("attack_" + direction)
		move_and_slide()
		return
	if axis.length() > 0:
		axis = axis.normalized()
		var target_velocity = speed * axis
		velocity = velocity.lerp(target_velocity, ACCEL * delta)
		
		$AnimationPlayer.play("run_" + direction)
	else:
		velocity = velocity.lerp(Vector2.ZERO, ACCEL * delta)
		if is_attacking:
			pass
		elif velocity.length() < 50:
			$AnimationPlayer.play("idle_" + direction)
		else:
			$AnimationPlayer.play("run_" + direction)
		
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# If we hit furniture, push it
		if collider is RigidBody2D:
			var push_force = 300.0  # Adjust this value for push strength
			var push_direction = collision.get_normal() * -1  # Opposite of collision normal
			collider.apply_central_impulse(push_direction * push_force * delta)
	# position = position.clamp(Vector2.ZERO, screen_size)

		

func take_damage(amount: float, attacker_position: Vector2):
	PlayerData.take_damage(amount, global_position)
	var knockback_direction = (global_position - attacker_position).normalized()
	velocity = knockback_direction * knockback_strength
	is_stunned = true
	is_attacking = false
	$AnimationPlayer.play("idle_" + direction)
	
func _on_died(location):
	queue_free()


func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group('enemies'):
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(20, global_position)
			
func _on_hurtbox_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hurtbox"):
		var enemy = area.get_parent()
		if not is_stunned:
			take_damage(20, enemy.global_position)
		enemy.is_stunned = true
		var knockback_direction = (enemy.global_position - global_position).normalized()
		enemy.velocity = knockback_direction * 500
	if area.is_in_group("items"):
		area.pickup()

func _on_health_changed(curr: float, max: float) -> void:
	print("player health: %s/%s" % [curr, max])
	
