extends Node2D

var test_enemy_path: String = "res://data/enemies/000 starting zone/sheep.tres"
var enemy_template = preload("res://scenes/tower/tower.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("ACCEPTED")
		var new_enemy = enemy_template.instantiate()
		add_child(new_enemy)
		new_enemy.global_position = Vector2(200, 200)
