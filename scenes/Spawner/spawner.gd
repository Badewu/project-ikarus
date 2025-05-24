extends Area2D

class_name Spawner

var test_enemy_path: String = "res://data/enemies/000 starting zone/sheep.tres"
var enemy_template
var wanderer_template = preload("res://scenes/Spawner/wanderer.tscn")
var grid_manager : GridManager
var original_position : Vector2

#DRAG N DROP
var is_dragged : bool = false
var is_hovered: bool = false

func _ready() -> void:
	enemy_template = load("res://entities/enemies/enemy.tscn")
	grid_manager = get_parent().get_parent()
	get_node("DragNDropCollision").shape.size = Vector2(grid_manager.grid_size, grid_manager.grid_size)


func _process(delta: float) -> void:
	#DRAG N DROP
	if is_dragged:
		var grid_mouse_position = grid_manager.world_to_grid(get_global_mouse_position())
		var fixed_position = grid_manager.grid_to_world(grid_mouse_position)
		global_position = fixed_position + grid_manager.grid_offset


func _input(event: InputEvent) -> void:
	#DRAG N DROP
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and is_hovered:
			is_dragged = true
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_dragged:
				grid_manager.try_place_spawner(self, get_global_mouse_position())
				pass
			is_dragged = false



func _on_wanderer_timer_timeout() -> void:
	var new_wanderer : Wanderer = wanderer_template.instantiate()
	
	new_wanderer.grid_manager = grid_manager
	var grid_coord : Vector2i = grid_manager.world_to_grid(global_position)
	var coord : Vector2 = grid_manager.grid_to_world(grid_coord)
	new_wanderer.global_position = coord
	get_tree().current_scene.add_child(new_wanderer)


func _on_spawn_timer_timeout() -> void:
	var new_enemy : Enemy = enemy_template.instantiate()
	
	new_enemy.grid_manager = grid_manager
	var grid_coord : Vector2i = grid_manager.world_to_grid(global_position)
	var coord : Vector2 = grid_manager.grid_to_world(grid_coord)
	new_enemy.global_position = coord
	get_tree().current_scene.add_child(new_enemy)


func _on_mouse_entered() -> void:
	is_hovered = true


func _on_mouse_exited() -> void:
	is_hovered = false
