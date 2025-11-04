extends Node2D

func _init():
	var db = FurnitureDB
	print("\n=== Testing Furniture Database ===")
	print("Total furniture: %d" % db.all_furniture.size())
	
	# Test getting random furniture
	var random_bed = db.get_random_furniture("bedroom", Vector2i(3, 2))
	if random_bed:
		print("Got random bed: %s" % random_bed.furniture_name)
	
	var random_chair = db.get_random_furniture("kitchen", Vector2i(1, 1))
	if random_chair:
		print("Got random chair: %s" % random_chair.furniture_name)
	
	# Test checking available sizes
	var bedroom_sizes = db.get_all_sizes_in_set("bedroom")
	print("Bedroom has %d different furniture sizes" % bedroom_sizes.size())
	
func _ready():
	print("Main scene ready")
	
	
