@tool
extends EditorScript

const LIVING_ROOM_FURNITURE = [
	# Row 1 (top)
	{"name": "Aquarium", "coords": Vector2i(0, 0), "size": Vector2i(3, 3), "weight": 1},
	{"name": "Brown Couch", "coords": Vector2i(3, 0), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Pink Ottoman", "coords": Vector2i(5, 0), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Laundry Basket", "coords": Vector2i(6, 0), "size": Vector2i(1, 1), "weight": 2},
	{"name": "Large Bookshelf", "coords": Vector2i(9, 0), "size": Vector2i(3, 3), "weight": 1},
	{"name": "Small Bookshelf", "coords": Vector2i(12, 0), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Coffee Table", "coords": Vector2i(13, 1), "size": Vector2i(2, 1), "weight": 3},
	
	# Row 2
	{"name": "Entertainment Center", "coords": Vector2i(3, 2), "size": Vector2i(5, 2), "weight": 1},
	{"name": "Wall Art 1", "coords": Vector2i(6, 2), "size": Vector2i(2, 1), "weight": 3},
	{"name": "Wall Art 2", "coords": Vector2i(6, 3), "size": Vector2i(2, 1), "weight": 3},
	
	# Row 3
	{"name": "Toy Chest", "coords": Vector2i(1, 4), "size": Vector2i(2, 1), "weight": 2},
	{"name": "Long Dresser", "coords": Vector2i(3, 4), "size": Vector2i(4, 2), "weight": 1},
	{"name": "Plant Tall", "coords": Vector2i(8, 4), "size": Vector2i(1, 2), "weight": 2},
	{"name": "Small Dresser", "coords": Vector2i(9, 4), "size": Vector2i(1, 2), "weight": 3},
	{"name": "Wood Shelf", "coords": Vector2i(10, 4), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Desk Setup", "coords": Vector2i(11, 4), "size": Vector2i(2, 2), "weight": 1},
	{"name": "Large Bookshelf 2", "coords": Vector2i(14, 4), "size": Vector2i(2, 3), "weight": 1},
	
	# Row 4 (lamps, plants, small items)
	{"name": "Small Lamp 1", "coords": Vector2i(2, 6), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Small Lamp 2", "coords": Vector2i(3, 6), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Small Lamp 3", "coords": Vector2i(4, 6), "size": Vector2i(1, 1), "weight": 4},
	{"name": "Clock", "coords": Vector2i(5, 6), "size": Vector2i(1, 1), "weight": 3},
	{"name": "House Plant", "coords": Vector2i(6, 6), "size": Vector2i(1, 1), "weight": 4},
	
	# Row 5 (TV area)
	{"name": "TV Stand", "coords": Vector2i(0, 7), "size": Vector2i(2, 2), "weight": 2},
	{"name": "L-Shaped Desk", "coords": Vector2i(3, 7), "size": Vector2i(4, 3), "weight": 1},
	{"name": "Computer Setup", "coords": Vector2i(7, 7), "size": Vector2i(2, 2), "weight": 1},
	{"name": "Bookshelf Medium", "coords": Vector2i(9, 7), "size": Vector2i(2, 2), "weight": 2},
	{"name": "3-Drawer Dresser", "coords": Vector2i(13, 7), "size": Vector2i(2, 3), "weight": 2},
	{"name": "Cushion TV", "coords": Vector2i(15, 7), "size": Vector2i(2, 1), "weight": 2},
	
	# Row 6
	{"name": "TV Cabinet", "coords": Vector2i(0, 9), "size": Vector2i(3, 2), "weight": 1},
	
	# Row 7 (bottom - rugs and large items)
	{"name": "Large Rug", "coords": Vector2i(0, 11), "size": Vector2i(5, 3), "weight": 1},
	{"name": "Pink Nightstand", "coords": Vector2i(5, 10), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Dark Bookshelf", "coords": Vector2i(8, 10), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Wood Bookshelf", "coords": Vector2i(10, 10), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Desk", "coords": Vector2i(11, 11), "size": Vector2i(2, 1), "weight": 2},
	
	# Row 8 (very bottom)
	{"name": "Dark Desk", "coords": Vector2i(5, 12), "size": Vector2i(3, 2), "weight": 1},
	{"name": "Heater", "coords": Vector2i(8, 13), "size": Vector2i(1, 1), "weight": 2},
	{"name": "TV", "coords": Vector2i(9, 12), "size": Vector2i(2, 1), "weight": 1},
	{"name": "Pink Nightstand 2", "coords": Vector2i(12, 12), "size": Vector2i(2, 2), "weight": 2},
	{"name": "Fish Tank", "coords": Vector2i(15, 13), "size": Vector2i(1, 1), "weight": 2},
	
	# Bottom row items
	{"name": "Brown Rug", "coords": Vector2i(0, 14), "size": Vector2i(5, 2), "weight": 1},
	{"name": "Side Table Books", "coords": Vector2i(13, 14), "size": Vector2i(2, 2), "weight": 2},
]

func _run():
	print("Starting Living Room furniture import...")
	_import_furniture_set("living_room", "res://assets/room_tilesets/Living_Room.png", LIVING_ROOM_FURNITURE)
	print("Living Room import complete!")

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
