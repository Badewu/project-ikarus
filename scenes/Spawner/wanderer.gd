extends CPUParticles2D

class_name Wanderer

var grid_manager : GridManager


func _on_straight_movement_end_reached() -> void:
	queue_free()
