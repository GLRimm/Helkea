class_name Furniture
extends RigidBody2D

var furniture_data: FurniturePieceData

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_component = $HealthComponent

func _ready():
	if furniture_data:
		_apply_furniture_data()
	
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_changed)

func _apply_furniture_data():
	var sprite = $Sprite2D
	sprite.texture = furniture_data.sprite_texture
	sprite.region_enabled = true
	sprite.region_rect = Rect2(
		furniture_data.atlas_coords * 32,
		furniture_data.size_in_tiles * 32
	)
	sprite.centered = false
	sprite.offset = Vector2.ZERO
	
	var collision = $CollisionShape2D
	collision.shape = furniture_data.collision_shape.duplicate()
	collision.position = (furniture_data.size_in_tiles * 32) / 2.0
	
	mass = furniture_data.size_in_tiles.x * furniture_data.size_in_tiles.y
	freeze = true
	
func _on_health_changed(current: float, max_health: float):
	if current < max_health and freeze:
		freeze = false
		apply_central_impulse(Vector2(randf_range(-100, 100), randf_range(-100, 100)))
		

func _shake_and_unfreeze():
	freeze = false
	# Add some impulse for a "wobble" effect
	apply_central_impulse(Vector2(randf_range(-50, 50), randf_range(-50, 50)))

func _on_died():
	# TODO: Spawn particle effects, flat-pack pieces
	queue_free()
	
	
	
