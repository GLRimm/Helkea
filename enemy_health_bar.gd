extends Control

var hide_timer: Timer

func _ready():
	visible = false
	hide_timer = Timer.new()
	add_child(hide_timer)
	hide_timer.timeout.connect(_on_hide_timer_timeout)
	hide_timer.one_shot = true
	
func update_health(current: float, maximum: float):
		$ProgressBar.max_value = maximum
		$ProgressBar.value = current
		
		visible = current < maximum && current > 0
		
		if visible:
			hide_timer.start(2.0)
		
func _on_hide_timer_timeout():
	visible = false
