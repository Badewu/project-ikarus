extends Node2D

var test_enemy_path: String = "res://data/enemies/000 starting zone/sheep.tres"
var tower_template = preload("res://entities/tower/tower.tscn")
var grid_manager : GridManager

func _ready() -> void:
	grid_manager = get_node("GridManager")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		print("ACCEPTED")
		var new_tower = tower_template.instantiate()
		grid_manager.add_child(new_tower)
		grid_manager.try_place_tower(new_tower, Vector2(500, 300))
		
