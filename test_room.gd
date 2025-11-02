extends Node

func _ready():
	var generator = DungeonGenerator.new()
	add_child(generator)
	
	# Generate a few dungeons
	for i in range(3):
		print("\n\n=== DUNGEON %d ===" % (i + 1))
		generator.generate_dungeon()
		generator.print_dungeon_layout()

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Space or Enter
		print("\n\n=== NEW DUNGEON ===")
		var generator = get_child(0) as DungeonGenerator
		generator.generate_dungeon()
		generator.print_dungeon_layout()
