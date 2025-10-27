extends Area2D

signal player_entered_door

@export var is_locked: bool = true
@onready var blocker_collision = $Blocker/CollisionShape2D

func _ready():
	body_entered.connect(_on_body_entered)
	update_visual()
	
func lock(should_lock: bool):
	print("got here")
	is_locked = should_lock
	blocker_collision.disabled = false if is_locked else true
	update_visual()
	
func update_visual():
	$ColorRect.color = Color.hex(0xff00007f) if is_locked else Color.hex(0x00ff007f)

func _on_body_entered(body: Node2D):
	print("player touched door")
	if body.is_in_group("player") and not is_locked:
		print("Player entered door")
		player_entered_door.emit()
