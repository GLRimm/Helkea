class_name FurniturePieceData
extends Resource

@export var furniture_name: String
@export var sprite_texture: Texture2D
@export var atlas_coords: Vector2i  # Position on spritesheet
@export var size_in_tiles: Vector2i  # e.g., Vector2i(2, 1) for a 2x1 piece
@export var collision_shape: Shape2D  # Pre-configured collision
@export var furniture_set: String  # "bedroom", "kitchen", etc.
@export var weight: int = 1  # For random selection (heavier items = less common)

@export_group("Health")
@export var max_health: float = 100.0
@export var mass_multiplier: float = 1.0  # Bigger furniture = more mass
