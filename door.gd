extends Area2D
class_name Door

signal player_entered_door(direction: String)

@export var is_locked: bool = true
@export var direction: String = "north"

@onready var blocker_collision = $Blocker/CollisionShape2D

var can_trigger: bool = true
var player_inside: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_collision()
	_update_visual()

func lock(should_lock: bool):
	is_locked = should_lock
	_update_collision()
	_update_visual()

func start_cooldown(duration: float = 0.5):
	can_trigger = false
	get_tree().create_timer(duration).timeout.connect(func(): can_trigger = true)

func _update_collision():
	if blocker_collision:
		blocker_collision.disabled = not is_locked

func _update_visual():
	if has_node("ColorRect"):
		$ColorRect.color = Color.RED if is_locked else Color.GREEN

func _on_body_entered(body: Node2D):
	if not body.is_in_group("player"):
		return
	
	if not is_locked and not player_inside and can_trigger:
		player_inside = true
		player_entered_door.emit(direction)
		start_cooldown(0.5)

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_inside = false
