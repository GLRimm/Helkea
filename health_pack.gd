extends Node2D
		
func pickup():
	PlayerData.heal(10)
	queue_free()
