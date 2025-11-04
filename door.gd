extends Area2D
class_name Door

signal player_entered_door(direction: String)

@export var is_locked: bool = true
@export var direction: String = "north"

@onready var blocker_collision = $Blocker/CollisionShape2D

var closed_visual: TileMapLayer
var detector_collision: CollisionShape2D

var can_trigger: bool = true
var player_inside: bool = false

func _ready():
	match direction:
		"north":
			closed_visual = $ClosedNorthTileMapLayer
			detector_collision = $NorthCollisionShape2D
		"east":
			closed_visual = $ClosedEastTileMapLayer
			detector_collision = $EastCollisionShape2D
		"west":
			closed_visual = $ClosedWestTileMapLayer
			detector_collision = $WestCollisionShape2D
		"south":
			closed_visual = $ClosedSouthTileMapLayer
			detector_collision = $SouthCollisionShape2D
	closed_visual.enabled = true
	detector_collision.disabled = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_visual()

func lock(should_lock: bool):
	is_locked = should_lock
	_update_visual()

func start_cooldown(duration: float = 0.5):
	can_trigger = false
	get_tree().create_timer(duration).timeout.connect(func(): can_trigger = true)

func _update_visual():
	closed_visual.visible = is_locked
	
	if is_locked:
		closed_visual.collision_enabled = true
	else:
		closed_visual.collision_enabled = false
	
		

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
