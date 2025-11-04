@tool
extends EditorScript

const KITCHEN_FURNITURE = [
	# Top row - Counter sections with sinks
	{"name": "Counter Sink Wood", "coords": Vector2i(0, 0), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Counter Wood", "coords": Vector2i(2, 0), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Counter Sink Gray", "coords": Vector2i(3, 0), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Counter Gray", "coords": Vector2i(5, 0), "size": Vector2i(1, 1), "weight": 3},
	
	# Cabinets and storage (rows 1-2)
	{"name": "Cabinet Lower Wood", "coords": Vector2i(0, 1), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Cabinet Lower Brick Pattern", "coords": Vector2i(1, 1), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Stove Wood", "coords": Vector2i(2, 1), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Oven Black", "coords": Vector2i(3, 1), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Counter Gray Bottom", "coords": Vector2i(4, 1), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Cabinet Gray", "coords": Vector2i(5, 1), "size": Vector2i(1, 1), "weight": 3},
	
	# More counters and appliances (row 2-3)
	{"name": "Cabinet Wood Drawers", "coords": Vector2i(0, 2), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Cabinet Brick", "coords": Vector2i(1, 2), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Counter Wood End", "coords": Vector2i(2, 2), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Stove Gray", "coords": Vector2i(3, 2), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Counter White Marble", "coords": Vector2i(4, 2), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Cabinet White", "coords": Vector2i(5, 2), "size": Vector2i(1, 1), "weight": 3},
	
	# Fridge and tall appliances (top right)
	{"name": "Fridge White", "coords": Vector2i(9, 0), "size": Vector2i(1, 2), "weight": 2},
	{"name": "Fridge Gray", "coords": Vector2i(10, 0), "size": Vector2i(1, 2), "weight": 2},
	{"name": "Microwave", "coords": Vector2i(11, 0), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Cabinet Upper Orange", "coords": Vector2i(12, 0), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Cabinet Upper Brown", "coords": Vector2i(13, 0), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Cabinet Upper Cyan", "coords": Vector2i(14, 0), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Cabinet Upper Blue", "coords": Vector2i(15, 0), "size": Vector2i(1, 1), "weight": 2},
	
	# Lower cabinets (second row right side)
	{"name": "Cabinet Lower Orange", "coords": Vector2i(12, 1), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Cabinet Lower Brown", "coords": Vector2i(13, 1), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Cabinet Lower Cyan", "coords": Vector2i(14, 1), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Cabinet Lower Blue", "coords": Vector2i(15, 1), "size": Vector2i(1, 1), "weight": 2},
	
	# Stoves and pots (row 3)
	{"name": "Pot Large", "coords": Vector2i(7, 2), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Pot Medium", "coords": Vector2i(8, 2), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Pot Small", "coords": Vector2i(9, 2), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Pan", "coords": Vector2i(10, 2), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Cutting Board", "coords": Vector2i(11, 2), "size": Vector2i(1, 1), "weight": 4},
	
	# Counter sections (row 4)
	{"name": "Counter Long Wood", "coords": Vector2i(0, 4), "size": Vector2i(5, 1), "weight": 1},
	{"name": "Counter Section Marble", "coords": Vector2i(5, 4), "size": Vector2i(3, 1), "weight": 2},
	{"name": "Counter Section Dark", "coords": Vector2i(10, 4), "size": Vector2i(3, 1), "weight": 2},
	
	# Lower cabinets (row 5)
	{"name": "Cabinet Base Wood Long", "coords": Vector2i(0, 5), "size": Vector2i(5, 1), "weight": 1},
	{"name": "Fridge Black", "coords": Vector2i(10, 4), "size": Vector2i(1, 2), "weight": 2},
	{"name": "Cabinet Base Dark Long", "coords": Vector2i(13, 5), "size": Vector2i(3, 1), "weight": 1},
	
	# Island counters (row 6)
	{"name": "Kitchen Island Wood", "coords": Vector2i(0, 6), "size": Vector2i(5, 2), "weight": 1},
	
	# Windows (row 6-7)
	{"name": "Window Cyan", "coords": Vector2i(6, 6), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Window Red", "coords": Vector2i(8, 6), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Vent Hood", "coords": Vector2i(10, 6), "size": Vector2i(3, 1), "weight": 2},
	{"name": "Cabinet Upper Dark", "coords": Vector2i(13, 6), "size": Vector2i(2, 1), "weight": 2},
	
	# Dining chairs (row 8-9)
	{"name": "Chair Wood Pink", "coords": Vector2i(5, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Chair Wood Red", "coords": Vector2i(6, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Chair Wood Brown", "coords": Vector2i(7, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Chair Wood Dark", "coords": Vector2i(8, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Chair Pink", "coords": Vector2i(9, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Chair Red 1", "coords": Vector2i(10, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Chair Red 2", "coords": Vector2i(11, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Chair Magenta", "coords": Vector2i(12, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Chair Gray", "coords": Vector2i(13, 8), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Stool", "coords": Vector2i(14, 8), "size": Vector2i(1, 1), "weight": 4},
	
	# Brick oven/fireplace (row 10-11)
	{"name": "Brick Oven", "coords": Vector2i(0, 10), "size": Vector2i(5, 2), "weight": 1},
	{"name": "Oven Traditional", "coords": Vector2i(5, 10), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Counter Dark Wood", "coords": Vector2i(10, 10), "size": Vector2i(6, 1), "weight": 1},
	
	# Appliances bottom section (row 11-12)
	{"name": "Oven Face", "coords": Vector2i(6, 12), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Stove Top Orange", "coords": Vector2i(7, 12), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Oven Black Small", "coords": Vector2i(8, 12), "size": Vector2i(1, 1), "weight": 2},
	
	# Small items and utensils (left side rows 12-14)
	{"name": "Carrot", "coords": Vector2i(0, 12), "size": Vector2i(1, 1), "weight": 5},
	{"name": "Wine Bottles", "coords": Vector2i(1, 12), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Meat", "coords": Vector2i(0, 13), "size": Vector2i(1, 1), "weight": 5},
	{"name": "Knife", "coords": Vector2i(1, 13), "size": Vector2i(1, 1), "weight": 5},
	{"name": "Spoon", "coords": Vector2i(2, 13), "size": Vector2i(1, 1), "weight": 5},
	{"name": "Spatula", "coords": Vector2i(3, 13), "size": Vector2i(1, 1), "weight": 5},
	{"name": "Kettle", "coords": Vector2i(0, 14), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Blender", "coords": Vector2i(2, 14), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Plant Pot", "coords": Vector2i(3, 14), "size": Vector2i(1, 1), "weight": 4},
	
	# Crates and storage (bottom left)
	{"name": "Crate Apples", "coords": Vector2i(4, 13), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Crate Oranges", "coords": Vector2i(5, 13), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Box", "coords": Vector2i(6, 13), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Basket", "coords": Vector2i(5, 14), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Trash Bin", "coords": Vector2i(6, 14), "size": Vector2i(1, 1), "weight": 3},
	
	# Tables (bottom center-right)
	{"name": "Dining Table Round", "coords": Vector2i(10, 13), "size": Vector2i(3, 2), "weight": 1},
	{"name": "Stove Unit Complete", "coords": Vector2i(13, 12), "size": Vector2i(3, 2), "weight": 1},
	{"name": "Cabinet Dark Complete", "coords": Vector2i(14, 14), "size": Vector2i(2, 2), "weight": 1},
	
	# Dining tables and counters (far right)
	{"name": "Table Striped Red", "coords": Vector2i(14, 2), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Table Striped Pink", "coords": Vector2i(14, 4), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Table Striped Orange", "coords": Vector2i(14, 6), "size": Vector2i(2, 2), "weight": 2},
	
	# Additional appliances
	{"name": "Dishwasher", "coords": Vector2i(14, 9), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Washing Machine White", "coords": Vector2i(15, 9), "size": Vector2i(1, 1), "weight": 2},
]

func _run():
	print("Starting Kitchen furniture import...")
	_import_furniture_set("kitchen", "res://assets/room_tilesets/Kitcheen.png", KITCHEN_FURNITURE)
	print("Kitchen import complete!")

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
