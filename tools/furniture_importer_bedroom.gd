@tool
extends EditorScript

const BEDROOM_FURNITURE = [
	# Left column - Beds (different colors)
	{"name": "Bed Pink", "coords": Vector2i(0, 0), "size": Vector2i(3, 2), "weight": 2},
	{"name": "Bed Green", "coords": Vector2i(0, 2), "size": Vector2i(3, 2), "weight": 2},
	{"name": "Bed Orange", "coords": Vector2i(0, 4), "size": Vector2i(3, 2), "weight": 2},
	{"name": "Bed White", "coords": Vector2i(0, 6), "size": Vector2i(3, 2), "weight": 2},
	{"name": "Bed Blue", "coords": Vector2i(0, 8), "size": Vector2i(3, 2), "weight": 2},
	{"name": "Bed Pink Alt", "coords": Vector2i(0, 10), "size": Vector2i(3, 2), "weight": 2},
	{"name": "Bed Lavender", "coords": Vector2i(0, 12), "size": Vector2i(3, 2), "weight": 2},
	{"name": "Bed Beige", "coords": Vector2i(0, 14), "size": Vector2i(3, 2), "weight": 2},
	
	# Small furniture (nightstands, lamps)
	{"name": "Nightstand Dark", "coords": Vector2i(4, 0), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Nightstand Light", "coords": Vector2i(5, 0), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Mirror", "coords": Vector2i(4, 1), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Lamp", "coords": Vector2i(5, 1), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Potted Plant", "coords": Vector2i(4, 2), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Small Table", "coords": Vector2i(5, 2), "size": Vector2i(1, 1), "weight": 3},
	
	# Dressers and storage (middle-left)
	{"name": "Dresser Wood 3-Drawer", "coords": Vector2i(4, 4), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Dresser Wood 4-Drawer", "coords": Vector2i(4, 6), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Dresser White", "coords": Vector2i(4, 8), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Dresser Black", "coords": Vector2i(4, 10), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Dresser Brown", "coords": Vector2i(4, 12), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Dresser Blue", "coords": Vector2i(4, 14), "size": Vector2i(2, 2), "weight": 2},
	
	# Wardrobes and tall furniture (middle section)
	{"name": "Wardrobe Wood Top", "coords": Vector2i(6, 0), "size": Vector2i(2, 3), "weight": 1},
	{"name": "Wardrobe Wood Bottom", "coords": Vector2i(6, 3), "size": Vector2i(2, 3), "weight": 1},
	{"name": "Wardrobe Brown", "coords": Vector2i(10, 0), "size": Vector2i(2, 4), "weight": 1},
	{"name": "Dresser Tall Wood", "coords": Vector2i(5, 4), "size": Vector2i(3, 3), "weight": 1},
	{"name": "TV Stand", "coords": Vector2i(7, 3), "size": Vector2i(1, 1), "weight": 2},
	
	# More storage units
	{"name": "Bookshelf Low", "coords": Vector2i(8, 3), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Cabinet Dark", "coords": Vector2i(13, 3), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Vanity Desk", "coords": Vector2i(10, 4), "size": Vector2i(3, 2), "weight": 1},
	{"name": "Dresser 6-Drawer", "coords": Vector2i(13, 5), "size": Vector2i(3, 3), "weight": 1},
	{"name": "Wardrobe Dark", "coords": Vector2i(13, 8), "size": Vector2i(3, 3), "weight": 1},
	
	# Lockers and cabinets (right section)
	{"name": "Locker Pink", "coords": Vector2i(8, 6), "size": Vector2i(1, 2), "weight": 2},
	{"name": "Locker Purple", "coords": Vector2i(9, 6), "size": Vector2i(1, 2), "weight": 2},
	{"name": "Locker White Set", "coords": Vector2i(10, 6), "size": Vector2i(3, 2), "weight": 1},
	{"name": "Storage Cabinet Pink", "coords": Vector2i(8, 9), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Storage Cabinet Purple", "coords": Vector2i(10, 9), "size": Vector2i(2, 2), "weight": 2},
	
	# Decorative items
	{"name": "Fan", "coords": Vector2i(12, 4), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Bucket 1", "coords": Vector2i(12, 8), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Bucket 2", "coords": Vector2i(13, 8), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Trash Can", "coords": Vector2i(14, 8), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Scale", "coords": Vector2i(12, 9), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Gear Decor 1", "coords": Vector2i(13, 9), "size": Vector2i(1, 1), "weight": 3},
	{"name": "Gear Decor 2", "coords": Vector2i(14, 9), "size": Vector2i(1, 1), "weight": 3},
	
	# Rugs (bottom section)
	{"name": "Rug Round Yellow", "coords": Vector2i(6, 10), "size": Vector2i(3, 3), "weight": 2},
	{"name": "Rug Rectangle Pink", "coords": Vector2i(9, 10), "size": Vector2i(3, 2), "weight": 2},
	{"name": "Rug Blue Shag", "coords": Vector2i(6, 13), "size": Vector2i(5, 3), "weight": 1},
	{"name": "Rug Brown Stripes", "coords": Vector2i(12, 11), "size": Vector2i(2, 5), "weight": 1},
	
	# Shelving units (right side)
	{"name": "Shelf Unit Red", "coords": Vector2i(14, 10), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Shelf Unit Orange", "coords": Vector2i(14, 12), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Shelf Unit Dark", "coords": Vector2i(14, 14), "size": Vector2i(2, 2), "weight": 2},
	
	# Window (top right)
	{"name": "Window Large", "coords": Vector2i(13, 0), "size": Vector2i(3, 2), "weight": 1},
]

func _run():
	print("Starting Bedroom furniture import...")
	_import_furniture_set("bedroom", "res://assets/room_tilesets/Room.png", BEDROOM_FURNITURE)
	print("Bedroom import complete!")

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
