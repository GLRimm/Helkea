extends Resource
class_name RoomData

enum LayoutType {
	EMPTY,
	SPARSE,
	SCATTERED,
	CORRIDORS,
	ROWS,
	COLUMNS,
	CROSSES,
	QUARTERS,
	PILLARS,
	ARENA,
	GAUNTLET,
	CHECKERBOARD,
	CLUSTERED,
	CUSTOM
}

# Grid position in the dungeon
@export var grid_position: Vector2i = Vector2i.ZERO

@export var room_id: int = 0

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

@export var layout_type: LayoutType
@export var floor_type: String
@export var furniture_set: String

var wall_tiles: Array[Vector2i] = []
var furniture_zones: Array[Rect2i] = []
var placed_furniture: Array[Dictionary] = []

var layout_seed: int = 0

# Optional: specific room scene to load
@export var room_scene_path: String = ""

func _init(pos: Vector2i = Vector2i.ZERO, type: String = "normal"):
	if layout_seed == 0:
		layout_seed = randi()
		
	grid_position = pos
	room_type = type
