extends CanvasLayer

@onready var health_progress_bar = $MarginContainer/VBoxContainer/HealthBar/HealthProgress

func _ready():
	PlayerData.health_changed.connect(_on_health_changed)
	
func _on_health_changed(current: float, maximum: float):
	health_progress_bar.max_value = maximum
	health_progress_bar.value = current
	
