extends Label


func _on_tower_merge_level_changed(new_value: int) -> void:
	var data : TowerData = get_parent().data
	text = str(new_value)
	data.level = new_value
