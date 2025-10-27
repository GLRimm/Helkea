extends HealthComponent

func increase_max_health(amount: float):
	max_health += amount
	current_health += amount  # Also heal when getting max health upgrade
	health_changed.emit(current_health, max_health)
