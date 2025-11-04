# furniture_database.gd
extends Node
class_name FurnitureDatabase

# This will be auto-populated at runtime
var all_furniture: Array[FurniturePieceData] = []

func _ready():
	print("Loading furniture database...")
	_load_all_furniture_from_directory("res://data/furniture/")
	print("Loaded %d furniture pieces" % all_furniture.size())
	_print_furniture_summary()

func _load_all_furniture_from_directory(path: String):
	var dir = DirAccess.open(path)
	if not dir:
		push_error("Failed to open furniture directory: " + path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var furniture = load(path + file_name)
			if furniture is FurniturePieceData:
				all_furniture.append(furniture)
			else:
				push_warning("File is not FurniturePieceData: " + file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _print_furniture_summary():
	var sets = {}
	for furniture in all_furniture:
		if not furniture.furniture_set in sets:
			sets[furniture.furniture_set] = 0
		sets[furniture.furniture_set] += 1
	
	print("Furniture by set:")
	for set_name in sets.keys():
		print("  %s: %d pieces" % [set_name, sets[set_name]])

func get_random_furniture(furniture_set: String, size_filter: Vector2i = Vector2i.ZERO) -> FurniturePieceData:
	"""Get a random furniture piece, optionally filtered by size"""
	var filtered = all_furniture.filter(func(f): 
		var matches_set = f.furniture_set == furniture_set
		var matches_size = size_filter == Vector2i.ZERO or f.size_in_tiles == size_filter
		return matches_set and matches_size
	)
	
	if filtered.is_empty():
		push_warning("No furniture found for set: %s, size: %s" % [furniture_set, size_filter])
		return null
	
	# Weighted random selection
	var total_weight = 0
	for furniture in filtered:
		total_weight += furniture.weight
	
	var rand = randi() % total_weight
	var accumulated = 0
	
	for furniture in filtered:
		accumulated += furniture.weight
		if rand < accumulated:
			return furniture
	
	return filtered[0]  # Fallback

func get_furniture_by_size(furniture_set: String, size: Vector2i) -> Array[FurniturePieceData]:
	"""Get all furniture pieces of a specific size"""
	var result: Array[FurniturePieceData] = []
	for furniture in all_furniture:
		if furniture.furniture_set == furniture_set and furniture.size_in_tiles == size:
			result.append(furniture)
	return result

func get_all_sizes_in_set(furniture_set: String) -> Array[Vector2i]:
	"""Get all unique furniture sizes available in a set"""
	var sizes: Array[Vector2i] = []
	for furniture in all_furniture:
		if furniture.furniture_set == furniture_set:
			if not furniture.size_in_tiles in sizes:
				sizes.append(furniture.size_in_tiles)
	return sizes

func has_furniture_of_size(furniture_set: String, size: Vector2i) -> bool:
	"""Check if a furniture set has any pieces of the given size"""
	for furniture in all_furniture:
		if furniture.furniture_set == furniture_set and furniture.size_in_tiles == size:
			return true
	return false
