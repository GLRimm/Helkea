# tools/furniture_importer.gd
@tool
extends EditorScript

const BATHROOM_FURNITURE = [
	# Top-left: Showers and shower curtains
	{"name": "Shower Cyan", "coords": Vector2i(0, 0), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Shower Blue", "coords": Vector2i(2, 0), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Shower Curtain Closed", "coords": Vector2i(4, 0), "size": Vector2i(1, 2), "weight": 3},
	
	# Bathroom accessories
	{"name": "Soap Bottle Green", "coords": Vector2i(0, 2), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Soap Bottle Pink", "coords": Vector2i(0, 3), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Towel Rack", "coords": Vector2i(5, 0), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Toilet Paper Holder 1", "coords": Vector2i(6, 0), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Toilet Paper Holder 2", "coords": Vector2i(7, 0), "size": Vector2i(1, 1), "weight": 3},
	
	# Bathtubs
	{"name": "Bathtub White", "coords": Vector2i(1, 3), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Bathtub Cyan", "coords": Vector2i(3, 3), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Bathtub Gray", "coords": Vector2i(5, 3), "size": Vector2i(2, 1), "weight": 2},
	
	# Toilets
	{"name": "Toilet Beige", "coords": Vector2i(7, 3), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Toilet Blue", "coords": Vector2i(8, 3), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Toilet Gray", "coords": Vector2i(9, 3), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Toilet White", "coords": Vector2i(10, 3), "size": Vector2i(1, 1), "weight": 3},
	
	# Sinks and vanities
	{"name": "Sink Pedestal 1", "coords": Vector2i(11, 3), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Sink Pedestal 2", "coords": Vector2i(12, 3), "size": Vector2i(1, 1), "weight": 3},
	
	# Storage and cabinets (row 4-5)
	{"name": "Storage Box Orange", "coords": Vector2i(0, 4), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Laundry Basket", "coords": Vector2i(1, 4), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Washing Machine", "coords": Vector2i(2, 4), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Storage Purple", "coords": Vector2i(3, 5), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Storage Lavender", "coords": Vector2i(4, 5), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Storage Blue", "coords": Vector2i(5, 5), "size": Vector2i(1, 1), "weight": 3},
	
	# Vanity cabinets
	{"name": "Vanity Wood", "coords": Vector2i(6, 5), "size": Vector2i(3, 1), "weight": 2},
	{"name": "Cabinet Wood Dark 2-Wide", "coords": Vector2i(6, 6), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Cabinet Wood Dark 3-Wide", "coords": Vector2i(6, 7), "size": Vector2i(3, 1), "weight": 2},
	{"name": "Cabinet Wood Light", "coords": Vector2i(9, 7), "size": Vector2i(3, 1), "weight": 2},
	
	# Mirrors and wall items
	{"name": "Mirror Oval", "coords": Vector2i(12, 5), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Mirror Square", "coords": Vector2i(13, 5), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Mirror Fancy", "coords": Vector2i(14, 5), "size": Vector2i(1, 1), "weight": 2},
	
	# Small items row 6
	{"name": "Plunger", "coords": Vector2i(0, 6), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Toilet Brush", "coords": Vector2i(1, 6), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Scale Small", "coords": Vector2i(2, 6), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Bath Mat Pink", "coords": Vector2i(3, 6), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Bath Mat Green", "coords": Vector2i(4, 6), "size": Vector2i(1, 1), "weight": 3},
	
	# More vanities and sinks (row 8)
	{"name": "Sink Vanity Wood", "coords": Vector2i(1, 8), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Vanity Unit Cyan", "coords": Vector2i(3, 8), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Vanity Unit Blue", "coords": Vector2i(5, 8), "size": Vector2i(2, 2), "weight": 2},
	
	# Towel racks with towels
	{"name": "Towel Rack Green", "coords": Vector2i(8, 8), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Towel Rack Pink", "coords": Vector2i(9, 8), "size": Vector2i(1, 1), "weight": 3},
	
	# Bathtub variants (row 10-11)
	{"name": "Bathtub Modern Red", "coords": Vector2i(0, 10), "size": Vector2i(2, 2), "weight": 1},
	{"name": "Sink Modern", "coords": Vector2i(2, 10), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Shower Modern", "coords": Vector2i(3, 10), "size": Vector2i(2, 2), "weight": 2},
	
	# Bottom row cabinets (row 14-15)
	{"name": "Sink Cabinet Beige 2-Drawer", "coords": Vector2i(0, 14), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Sink Cabinet Beige 3-Drawer", "coords": Vector2i(2, 14), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Sink Cabinet Wood", "coords": Vector2i(6, 14), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Sink Cabinet Dark", "coords": Vector2i(8, 14), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Sink Cabinet Pink", "coords": Vector2i(10, 14), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Sink Cabinet Brown", "coords": Vector2i(12, 14), "size": Vector2i(2, 1), "weight": 2},
	
	# More mirrors (row 12-13)
	{"name": "Mirror Round Large 1", "coords": Vector2i(12, 6), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Mirror Round Large 2", "coords": Vector2i(14, 6), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Mirror Round Large 3", "coords": Vector2i(12, 13), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Mirror Round Large 4", "coords": Vector2i(14, 13), "size": Vector2i(2, 2), "weight": 2},
	
	# Shower stalls (right side)
	{"name": "Shower Stall Tile", "coords": Vector2i(15, 10), "size": Vector2i(1, 2), "weight": 2},
	{"name": "Shower Mat", "coords": Vector2i(15, 12), "size": Vector2i(1, 1), "weight": 3},
	
	# Bathmats and rugs (middle section)
	{"name": "Bath Mat Purple", "coords": Vector2i(7, 12), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Bath Mat Magenta", "coords": Vector2i(8, 12), "size": Vector2i(1, 1), "weight": 3},
	
	# Hooks and small wall items
	{"name": "Wall Hook 1", "coords": Vector2i(2, 13), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Wall Hook 2", "coords": Vector2i(3, 13), "size": Vector2i(1, 1), "weight": 4},
]

func _run():
	print("Starting Bathroom furniture import...")
	_import_furniture_set("bathroom", "res://assets/room_tilesets/Bathroom.png", BATHROOM_FURNITURE)
	print("Bathroom import complete!")

func _import_furniture_set(set_name: String, texture_path: String, furniture_list: Array):
	var texture = load(texture_path)
	if not texture:
		push_error("Could not load texture: " + texture_path)
		return
	
	# Create output directory if it doesn't exist
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")
	if not dir.dir_exists("data/furniture"):
		dir.make_dir("data/furniture")
	
	for item in furniture_list:
		var data = FurniturePieceData.new()
		
		data.furniture_name = item.name
		data.sprite_texture = texture
		data.atlas_coords = item.coords
		data.size_in_tiles = item.size
		data.furniture_set = set_name
		data.weight = item.get("weight", 1)
		data.max_health = item.size.x * item.size.y * 50.0
		data.mass_multiplier = 1.0
		
		# Create collision shape
		var shape = RectangleShape2D.new()
		shape.size = Vector2(item.size.x * 32, item.size.y * 32)
		data.collision_shape = shape
		
		# Save the resource
		var filename = "%s_%s.tres" % [set_name, item.name.to_lower().replace(" ", "_")]
		var path = "res://data/furniture/%s" % filename
		var result = ResourceSaver.save(data, path)
		
		if result == OK:
			print("  ✓ Created: " + filename)
		else:
			push_error("  ✗ Failed to save: " + filename)
