extends Node

class_name HealthComponent

signal health_changed(current, max_health)
signal died

@export var max_health: float = 100.0
var current_health: float

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
func take_damage(amount: float, location: Vector2):
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		died.emit(location)

func heal(amount: float):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
