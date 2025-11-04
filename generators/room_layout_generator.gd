class_name RoomLayoutGenerator
extends RefCounted

class FurniturePlacement:
	var position: Vector2i
	var size_requirement: Vector2i  # e.g., Vector2i(2, 1) - request specific size
	var rotation: float = 0.0  # 0, 90, 180, 270
	var furniture_type: String = ""  # "bed", "table", "chair", etc. (optional filtering)

static func generate_layout(room_data: RoomData) -> Dictionary:
	var result = {
		"wall_tiles": [],
		"furniture_placements": []  # Array[FurniturePlacement]
	}
	
	match room_data.layout_type:
		RoomData.LayoutType.ROWS:
			result.furniture_placements = _generate_row_layout()
		RoomData.LayoutType.COLUMNS:
			result.furniture_placements = _generate_column_layout()
		RoomData.LayoutType.SHOWROOM:
			result.furniture_placements = _generate_showroom_layout()
		RoomData.LayoutType.GRID:
			result.furniture_placements = _generate_grid_layout()
		RoomData.LayoutType.PERIMETER:
			result.furniture_placements = _generate_perimeter_layout()
		RoomData.LayoutType.MAZE:
			result.furniture_placements = _generate_maze_layout()
	
	return result

static func _generate_row_layout() -> Array[FurniturePlacement]:
	var placements: Array[FurniturePlacement] = []
	var y_positions = [3, 7, 11, 15]  # Four horizontal rows (more space!)
	
	for y in y_positions:
		var x = 3
		while x < 17:  # Leave margins
			var placement = FurniturePlacement.new()
			placement.position = Vector2i(x, y)
			placement.size_requirement = Vector2i(2, 1)
			placement.rotation = 0.0
			placements.append(placement)
			x += 3  # 2 tiles furniture + 1 tile gap
	
	return placements

static func _generate_column_layout() -> Array[FurniturePlacement]:
	var placements: Array[FurniturePlacement] = []
	var x_positions = [4, 8, 12, 16]  # Four vertical columns
	
	for x in x_positions:
		var y = 3
		while y < 17:  # Much more vertical space now!
			var placement = FurniturePlacement.new()
			placement.position = Vector2i(x, y)
			placement.size_requirement = Vector2i(1, 2)
			placement.rotation = 90.0
			placements.append(placement)
			y += 3
	
	return placements

static func _generate_showroom_layout() -> Array[FurniturePlacement]:
	"""IKEA-style vignettes - now with 4 quadrants!"""
	var placements: Array[FurniturePlacement] = []
	
	# TOP-LEFT quadrant: Bedroom vignette
	placements.append(_create_placement(Vector2i(3, 3), Vector2i(3, 2)))   # Bed
	placements.append(_create_placement(Vector2i(2, 3), Vector2i(1, 1)))   # Nightstand L
	placements.append(_create_placement(Vector2i(6, 3), Vector2i(1, 1)))   # Nightstand R
	placements.append(_create_placement(Vector2i(4, 6), Vector2i(2, 2)))   # Dresser
	
	# TOP-RIGHT quadrant: Dining room vignette
	placements.append(_create_placement(Vector2i(13, 4), Vector2i(3, 2)))  # Dining table
	placements.append(_create_placement(Vector2i(12, 6), Vector2i(1, 1)))  # Chair 1
	placements.append(_create_placement(Vector2i(16, 6), Vector2i(1, 1)))  # Chair 2
	placements.append(_create_placement(Vector2i(12, 3), Vector2i(1, 1)))  # Chair 3
	placements.append(_create_placement(Vector2i(16, 3), Vector2i(1, 1)))  # Chair 4
	placements.append(_create_placement(Vector2i(17, 7), Vector2i(1, 2)))  # China cabinet
	
	# BOTTOM-LEFT quadrant: Living room vignette
	placements.append(_create_placement(Vector2i(3, 12), Vector2i(4, 2)))  # Large sofa
	placements.append(_create_placement(Vector2i(5, 15), Vector2i(2, 2)))  # Coffee table
	placements.append(_create_placement(Vector2i(2, 15), Vector2i(1, 1)))  # Side table
	placements.append(_create_placement(Vector2i(3, 17), Vector2i(2, 1)))  # TV stand
	
	# BOTTOM-RIGHT quadrant: Office/study vignette
	placements.append(_create_placement(Vector2i(13, 12), Vector2i(3, 2))) # Desk
	placements.append(_create_placement(Vector2i(14, 14), Vector2i(1, 1))) # Office chair
	placements.append(_create_placement(Vector2i(16, 11), Vector2i(2, 3))) # Bookshelf
	placements.append(_create_placement(Vector2i(12, 16), Vector2i(2, 2))) # Filing cabinet
	
	return placements

static func _generate_grid_layout() -> Array[FurniturePlacement]:
	"""Warehouse-style organized grid - more items now!"""
	var placements: Array[FurniturePlacement] = []
	
	for y in range(3, 18, 4):  # Every 4 tiles vertically
		for x in range(3, 18, 4):  # Every 4 tiles horizontally
			var placement = FurniturePlacement.new()
			placement.position = Vector2i(x, y)
			placement.size_requirement = Vector2i(2, 2)  # 2x2 furniture
			placements.append(placement)
	
	return placements

static func _generate_perimeter_layout() -> Array[FurniturePlacement]:
	"""Furniture along the walls, larger open center"""
	var placements: Array[FurniturePlacement] = []
	
	# Top wall
	for x in range(3, 17, 3):
		placements.append(_create_placement(Vector2i(x, 2), Vector2i(2, 1), 0.0))
	
	# Bottom wall
	for x in range(3, 17, 3):
		placements.append(_create_placement(Vector2i(x, 17), Vector2i(2, 1), 180.0))
	
	# Left wall
	for y in range(4, 16, 3):
		placements.append(_create_placement(Vector2i(2, y), Vector2i(1, 2), 270.0))
	
	# Right wall
	for y in range(4, 16, 3):
		placements.append(_create_placement(Vector2i(17, y), Vector2i(1, 2), 90.0))
	
	return placements

static func _generate_maze_layout() -> Array[FurniturePlacement]:
	"""Winding IKEA path - forces player through the "showroom" """
	var placements: Array[FurniturePlacement] = []
	
	# Vertical barriers creating a winding path
	# Left side barrier
	for y in range(3, 10):
		placements.append(_create_placement(Vector2i(6, y), Vector2i(2, 1), 0.0))
	
	# Middle barrier
	for y in range(8, 17):
		placements.append(_create_placement(Vector2i(10, y), Vector2i(2, 1), 0.0))
	
	# Right side barrier
	for y in range(3, 12):
		placements.append(_create_placement(Vector2i(14, y), Vector2i(2, 1), 0.0))
	
	# Add furniture along the path
	placements.append(_create_placement(Vector2i(3, 5), Vector2i(2, 2), 0.0))
	placements.append(_create_placement(Vector2i(8, 5), Vector2i(2, 2), 0.0))
	placements.append(_create_placement(Vector2i(12, 14), Vector2i(2, 2), 0.0))
	placements.append(_create_placement(Vector2i(16, 9), Vector2i(2, 2), 0.0))
	
	return placements

static func _create_placement(pos: Vector2i, size: Vector2i, rot: float = 0.0) -> FurniturePlacement:
	var p = FurniturePlacement.new()
	p.position = pos
	p.size_requirement = size
	p.rotation = rot
	return p
