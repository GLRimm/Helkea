extends CanvasLayer

@onready var health_progress_bar = $MarginContainer/VBoxContainer/HealthBar/HealthProgress
@onready var room_label = $MarginContainer/VBoxContainer/HealthBar/RoomLabel
@onready var dungeon_manager = get_node("/root/DungeonManager")

func _ready():
	PlayerData.health_changed.connect(_on_health_changed)
	var dungeon_manager = get_tree().get_first_node_in_group("dungeon_manager")
	
	if dungeon_manager:
		print("Found dungeon manager at: ", dungeon_manager.get_path())
		dungeon_manager.entered_new_room.connect(_on_room_entered)
	else:
		print("No dungeon manager found!")
	
	PlayerData.health_changed.connect(_on_health_changed)
	
func _on_health_changed(current: float, maximum: float):
	health_progress_bar.max_value = maximum
	health_progress_bar.value = current
	
func _on_room_entered(label: String):
	print("_on_room_entered: %s" % label)
	room_label.text = label
	
