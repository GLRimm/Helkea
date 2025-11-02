extends Resource
class_name RoomData

# Grid position in the dungeon
@export var grid_position: Vector2i = Vector2i.ZERO

# Which directions have connections (doors)
@export var connections: Dictionary = {
	"north": false,
	"south": false,
	"east": false,
	"west": false
}

# Room properties
@export var room_type: String = "normal"  # "start", "normal", "boss", "treasure", "shop"
@export var is_cleared: bool = false
@export var is_visited: bool = false

# Optional: specific room scene to load
@export var room_scene_path: String = ""

func _init(pos: Vector2i = Vector2i.ZERO, type: String = "normal"):
	grid_position = pos
	room_type = type
