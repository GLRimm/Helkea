extends TileMapLayer
##
##
#func _ready():
	#_save_pattern(Vector2i(8, -3), Vector2i(11, -1), "res://patterns/open_north_door.tres")
	#_save_pattern(Vector2i(0, -3), Vector2i(3, -1), "res://patterns/closed_north_door.tres")
	#_save_pattern(Vector2i(-1, 6), Vector2i(-1, 11), "res://patterns/open_west_door.tres")
	#_save_pattern(Vector2i(-1, 12), Vector2i(-1, 17), "res://patterns/closed_west_door.tres")
	#_save_pattern(Vector2i(20, 6), Vector2i(20, 11), "res://patterns/open_east_door.tres")
	#_save_pattern(Vector2i(20, 12), Vector2i(20, 17), "res://patterns/closed_east_door.tres")
	#_save_pattern(Vector2i(8, 19), Vector2i(11, 19), "res://patterns/open_south_door.tres")
	#_save_pattern(Vector2i(0, 19), Vector2i(3, 19), "res://patterns/closed_south_door.tres")
#
#
#func _save_pattern(start: Vector2i, end: Vector2i, path: String):
	#var pattern = get_pattern([start, end])
	#ResourceSaver.save(pattern, path)
