class_name Furniture
extends RigidBody2D

var furniture_data: FurniturePieceData

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_component = $HealthComponent
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready():
	lock_rotation = true
	contact_monitor = true
	max_contacts_reported = 4
	gravity_scale = 0.0
	mass = 10.0
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.8  # High friction so it doesn't slide too much
	physics_material_override.bounce = 0.0  # No bouncing
	
	# Linear damp to slow down movement (feels more realistic)
	linear_damp = 3.0  # Higher = stops faster after being pushed
	
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
	
func _on_health_changed(current: float, max_health: float):
	if current < max_health and freeze:
		_shake_effect()

func _shake_effect():
	# Simple shake when hit
	var tween = create_tween()
	tween.tween_property(sprite, "offset:x", randf_range(-2, 2), 0.05)
	tween.tween_property(sprite, "offset:x", randf_range(-2, 2), 0.05)
	tween.tween_property(sprite, "offset:x", 0, 0.05)

func _on_died(location: Vector2):
	# TODO: Spawn particle effects, flat-pack pieces
	queue_free()
	
	
	
