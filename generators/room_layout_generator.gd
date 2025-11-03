class_name RoomLayoutGenerator
extends Node

const ROOM_WIDTH = 20
const ROOM_HEIGHT = 11
const TILE_SIZE = 32



func generate_layout(room_data: RoomData):
	"""
	Main entry point - generates layout based on room_data.layout_type
	Uses room's seed for deterministic generation
	"""
	print("DEBUG: Generating layout, seed = %d, type = %s" % [room_data.layout_seed, RoomData.LayoutType.keys()[room_data.layout_type]])
	seed(room_data.layout_seed)

	match room_data.layout_type:
		RoomData.LayoutType.EMPTY:
			_create_empty_layout(room_data)
		RoomData.LayoutType.SPARSE:
			print("DEBUG: Calling _create_sparse_layout")
			_create_sparse_layout(room_data)
			print("DEBUG: After sparse, zones = %d" % room_data.furniture_zones.size())
		RoomData.LayoutType.SCATTERED:
			_create_scattered_layout(room_data)
		RoomData.LayoutType.CORRIDORS:
			_create_corridors_layout(room_data)
		RoomData.LayoutType.ROWS:
			_create_rows_layout(room_data)
		RoomData.LayoutType.COLUMNS:
			_create_columns_layout(room_data)
		RoomData.LayoutType.CROSSES:
			_create_crosses_layout(room_data)
		RoomData.LayoutType.QUARTERS:
			_create_quarters_layout(room_data)
		RoomData.LayoutType.PILLARS:
			_create_pillars_layout(room_data)
		RoomData.LayoutType.ARENA:
			_create_arena_layout(room_data)
		RoomData.LayoutType.GAUNTLET:
			_create_gauntlet_layout(room_data)
		RoomData.LayoutType.CHECKERBOARD:
			_create_checkerboard_layout(room_data)
		RoomData.LayoutType.CLUSTERED:
			_create_clustered_layout(room_data)
		RoomData.LayoutType.CUSTOM:
			_load_custom_layout(room_data)
		_:
			_create_empty_layout(room_data)  # Fallback


# ============================================================================
# LAYOUT GENERATION FUNCTIONS
# ============================================================================

func _create_empty_layout(room_data: RoomData):
	"""
	Completely empty room - used for start rooms
	No walls, no furniture zones
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()


func _create_sparse_layout(room_data: RoomData):
	"""
	Just a few pieces of furniture scattered around
	2-4 small zones placed randomly
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	var num_zones = randi_range(2, 4)
	
	for i in range(num_zones):
		var zone_x = randi_range(3, 15)
		var zone_y = randi_range(3, 7)
		var zone_size = randi_range(2, 3)
		
		room_data.furniture_zones.append(
			Rect2i(zone_x, zone_y, zone_size, zone_size)
		)


func _create_scattered_layout(room_data: RoomData):
	"""
	Random scattering of furniture throughout room
	5-8 small zones placed randomly
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	var num_zones = randi_range(5, 8)
	
	for i in range(num_zones):
		var zone_x = randi_range(2, 16)
		var zone_y = randi_range(2, 8)
		var zone_width = randi_range(2, 3)
		var zone_height = randi_range(2, 3)
		
		# Make sure zone stays in bounds
		if zone_x + zone_width <= 18 and zone_y + zone_height <= 10:
			room_data.furniture_zones.append(
				Rect2i(zone_x, zone_y, zone_width, zone_height)
			)


func _create_corridors_layout(room_data: RoomData):
	"""
	Grid of furniture creating lanes/corridors
	Creates a 3x3 grid of furniture blocks with paths between
	"""
	print("DEBUG: _create_corridors_layout called")
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	print("DEBUG: Before loop, furniture_zones.size() = %d" % room_data.furniture_zones.size())
	
	# Create 3x3 grid of furniture blocks
	for grid_x in range(3):
		for grid_y in range(3):
			# Convert grid position to tile position
			# Leave 2 tiles between each block for corridors
			var tile_x = 3 + (grid_x * 5)
			var tile_y = 2 + (grid_y * 3)
			
			print("DEBUG: Creating zone at grid (%d, %d) -> tile (%d, %d)" % [grid_x, grid_y, tile_x, tile_y])
			
			room_data.furniture_zones.append(
				Rect2i(tile_x, tile_y, 3, 2)
			)
			
			print("DEBUG: After append, furniture_zones.size() = %d" % room_data.furniture_zones.size())
	
	print("DEBUG: Final furniture_zones.size() = %d" % room_data.furniture_zones.size())


func _create_rows_layout(room_data: RoomData):
	"""
	Horizontal rows of furniture
	3-4 rows spanning the width of the room
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	var num_rows = randi_range(3, 4)
	var row_spacing = 10 / (num_rows + 1)  # Distribute evenly
	
	for i in range(num_rows):
		var row_y = 2 + (i + 1) * row_spacing - 1
		
		# Create 2-4 furniture segments per row with gaps
		var num_segments = randi_range(2, 4)
		var segment_width = 16 / num_segments
		
		for j in range(num_segments):
			var segment_x = 2 + (j * segment_width)
			var actual_width = segment_width - 1  # Leave gap between segments
			
			if actual_width > 0:
				room_data.furniture_zones.append(
					Rect2i(segment_x, row_y, actual_width, 1)
				)


func _create_columns_layout(room_data: RoomData):
	"""
	Vertical columns of furniture
	4-5 columns spanning the height of the room
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	var num_columns = randi_range(4, 5)
	var column_spacing = 16 / (num_columns + 1)  # Distribute evenly
	
	for i in range(num_columns):
		var column_x = 2 + (i + 1) * column_spacing
		
		# Create 2-3 furniture segments per column with gaps
		var num_segments = randi_range(2, 3)
		var segment_height = 8 / num_segments
		
		for j in range(num_segments):
			var segment_y = 2 + (j * segment_height)
			var actual_height = segment_height - 1  # Leave gap between segments
			
			if actual_height > 0:
				room_data.furniture_zones.append(
					Rect2i(column_x, segment_y, 2, actual_height)
				)


func _create_crosses_layout(room_data: RoomData):
	"""
	Grid of cross-shaped furniture arrangements
	Creates + patterns throughout the room
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	# Create 2x2 grid of crosses
	for grid_x in range(2):
		for grid_y in range(2):
			var center_x = 5 + (grid_x * 9)
			var center_y = 3 + (grid_y * 5)
			
			# Create + shape (5 zones: center, north, south, east, west)
			# Center
			room_data.furniture_zones.append(Rect2i(center_x, center_y, 2, 2))
			# North
			room_data.furniture_zones.append(Rect2i(center_x, center_y - 2, 2, 1))
			# South
			room_data.furniture_zones.append(Rect2i(center_x, center_y + 2, 2, 1))
			# West
			room_data.furniture_zones.append(Rect2i(center_x - 2, center_y, 1, 2))
			# East
			room_data.furniture_zones.append(Rect2i(center_x + 3, center_y, 1, 2))


func _create_quarters_layout(room_data: RoomData):
	"""
	One big cross in the middle dividing room into quarters
	Creates + shape in center, leaving 4 open quadrants
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	# Horizontal bar through middle
	room_data.furniture_zones.append(Rect2i(4, 5, 12, 1))
	
	# Vertical bar through middle
	room_data.furniture_zones.append(Rect2i(9, 2, 2, 7))


func _create_pillars_layout(room_data: RoomData):
	"""
	Row on top and bottom with columns in between
	Creates pillar-like structures throughout room
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	# Top row
	room_data.furniture_zones.append(Rect2i(3, 2, 14, 1))
	
	# Bottom row
	room_data.furniture_zones.append(Rect2i(3, 8, 14, 1))
	
	# Vertical pillars (4-5 columns)
	var num_pillars = randi_range(4, 5)
	var pillar_spacing = 14 / (num_pillars - 1)
	
	for i in range(num_pillars):
		var pillar_x = 3 + (i * pillar_spacing)
		room_data.furniture_zones.append(Rect2i(pillar_x, 4, 1, 3))


func _create_arena_layout(room_data: RoomData):
	"""
	Open center with furniture around perimeter - perfect for boss fights
	Ensures 60% open space in center for combat
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	# Define perimeter zones (furniture hugs the walls)
	# Top perimeter
	room_data.furniture_zones.append(Rect2i(2, 2, 16, 2))
	
	# Bottom perimeter
	room_data.furniture_zones.append(Rect2i(2, 8, 16, 2))
	
	# Left perimeter
	room_data.furniture_zones.append(Rect2i(2, 4, 3, 4))
	
	# Right perimeter
	room_data.furniture_zones.append(Rect2i(15, 4, 3, 4))
	
	# Center is completely open (no furniture zone)
	# Area from (5,4) to (15,8) stays clear for combat


func _create_gauntlet_layout(room_data: RoomData):
	"""
	Long corridor with alternating obstacles forcing zig-zag movement
	Creates a challenging path from one side to the other
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	# Create narrow walls on top and bottom to form corridor
	for x in range(2, 18):
		room_data.wall_tiles.append(Vector2i(x, 2))
		room_data.wall_tiles.append(Vector2i(x, 9))
	
	# Create alternating obstacle zones (forces zig-zag)
	# Left obstacles
	room_data.furniture_zones.append(Rect2i(3, 4, 2, 2))
	room_data.furniture_zones.append(Rect2i(3, 7, 2, 1))
	
	# Right obstacles
	room_data.furniture_zones.append(Rect2i(8, 3, 2, 2))
	room_data.furniture_zones.append(Rect2i(8, 7, 2, 2))
	
	# Left obstacles (further down)
	room_data.furniture_zones.append(Rect2i(13, 4, 2, 2))
	room_data.furniture_zones.append(Rect2i(13, 7, 2, 1))


func _create_checkerboard_layout(room_data: RoomData):
	"""
	Alternating furniture/open squares like a chess board
	Creates interesting line-of-sight and movement options
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	# Create checkerboard pattern of furniture zones
	# Each "square" is 2x2 tiles
	for grid_x in range(1, 9):  # 8 columns
		for grid_y in range(1, 5):  # 4 rows
			# Only place furniture on alternating squares
			if (grid_x + grid_y) % 2 == 0:
				var tile_x = grid_x * 2
				var tile_y = grid_y * 2
				room_data.furniture_zones.append(Rect2i(tile_x, tile_y, 2, 2))


func _create_clustered_layout(room_data: RoomData):
	"""
	Furniture in random clumps with open spaces between
	Natural, organic feel - like furniture was pushed together
	"""
	room_data.wall_tiles.clear()
	room_data.furniture_zones.clear()
	
	# Create 3-5 random clusters
	var num_clusters = randi_range(3, 5)
	
	for i in range(num_clusters):
		# Random center point for cluster (avoid edges and doors)
		var center_x = randi_range(4, 16)
		var center_y = randi_range(3, 8)
		
		# Each cluster has 2-4 zones around the center
		var zones_in_cluster = randi_range(2, 4)
		
		for j in range(zones_in_cluster):
			# Offset from center (creates clump effect)
			var offset_x = randi_range(-2, 2)
			var offset_y = randi_range(-2, 2)
			
			var zone_x = clampi(center_x + offset_x, 2, 16)
			var zone_y = clampi(center_y + offset_y, 2, 8)
			
			# Varying zone sizes for organic feel
			var zone_width = randi_range(2, 4)
			var zone_height = randi_range(2, 3)
			
			# Make sure zone stays in bounds
			if zone_x + zone_width <= 18 and zone_y + zone_height <= 10:
				var new_zone = Rect2i(zone_x, zone_y, zone_width, zone_height)
				
				# Only add if it doesn't overlap too much with existing zones
				if _is_zone_valid(new_zone, room_data.furniture_zones):
					room_data.furniture_zones.append(new_zone)


func _load_custom_layout(room_data: RoomData):
	"""
	Load hand-crafted layouts from resource files
	Falls back to empty layout if no custom layouts found
	"""
	var layouts_path = "res://data/room_layouts/"
	var layout_files = []
	
	# Scan for .tres layout files
	var dir = DirAccess.open(layouts_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				layout_files.append(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	
	if layout_files.is_empty():
		print("No custom layouts found, using empty layout")
		_create_empty_layout(room_data)
		return
	
	# Load random custom layout
	var chosen_layout_file = layout_files.pick_random()
	var layout_resource = load(layouts_path + chosen_layout_file)
	
	if layout_resource:
		# Copy data from loaded resource to room_data
		room_data.wall_tiles = layout_resource.wall_tiles.duplicate()
		room_data.furniture_zones = layout_resource.furniture_zones.duplicate()
		room_data.floor_type = layout_resource.floor_type
	else:
		print("Failed to load custom layout, using empty layout")
		_create_empty_layout(room_data)


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

func _is_zone_valid(new_zone: Rect2i, existing_zones: Array[Rect2i]) -> bool:
	"""
	Helper for CLUSTERED - prevents zones from overlapping too much
	Allows slight overlap (realistic) but not complete overlap
	"""
	for zone in existing_zones:
		if new_zone.intersects(zone):
			# Calculate overlap area
			var intersection = new_zone.intersection(zone)
			var overlap_area = intersection.size.x * intersection.size.y
			var new_zone_area = new_zone.size.x * new_zone.size.y
			
			# Reject if more than 30% overlap
			if float(overlap_area) / new_zone_area > 0.3:
				return false
	
	return true


# ============================================================================
# UTILITY FUNCTIONS (for external use)
# ============================================================================

static func layout_type_to_string(layout_type: RoomData.LayoutType) -> String:
	"""Convert enum to string for serialization"""
	return RoomData.LayoutType.keys()[layout_type]


static func string_to_layout_type(layout_string: String) -> RoomData.LayoutType:
	"""Convert string to enum for deserialization"""
	var index = RoomData.LayoutType.keys().find(layout_string.to_upper())
	if index != -1:
		return RoomData.LayoutType.values()[index]
	return RoomData.LayoutType.EMPTY
