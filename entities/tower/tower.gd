extends Area2D
class_name Tower

signal merge_level_changed(new_value: int)

@export var data : TowerData
@export var merge_level : int = 1

#DRAG N DROP
var is_hovered : bool = false
var is_dragged : bool = false
#LOCATING ON THE GRID
var grid_manager : GridManager
var original_position: Vector2
var inventory_ui

func _ready() -> void:
	
	if get_parent() is GridManager:
		grid_manager = get_parent()
	else:
		print("No GridManager found")
	emit_signal("merge_level_changed", merge_level)
	
	inventory_ui = get_node("InventoryUI")


func _process(delta: float) -> void:
	#DRAG N DROP
	if is_dragged:
		var grid_mouse_position = grid_manager.world_to_grid(get_global_mouse_position())
		var fixed_position = grid_manager.grid_to_world(grid_mouse_position)
		global_position = fixed_position + grid_manager.grid_offset


var mouse_down_pos: Vector2 = Vector2.ZERO
var drag_threshold: float = 10.0  # Adjust this value as needed
var is_potential_click: bool = false

func _input(event: InputEvent) -> void:
	# DRAG AND DROP WITH CLICK DETECTION
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and is_hovered:
			# Store initial press position for drag detection
			mouse_down_pos = get_global_mouse_position()
			is_potential_click = true
			is_dragged = false
			
	elif event is InputEventMouseMotion and is_potential_click:
		# If mouse moved more than threshold while pressed, it's a drag
		if mouse_down_pos.distance_to(get_global_mouse_position()) > drag_threshold:
			is_dragged = true
			is_potential_click = false
			
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_dragged:
				# Handle drag end (placing tower)
				grid_manager.try_place_tower(self, get_global_mouse_position())
				is_dragged = false
			elif is_potential_click and is_hovered:
				# This was a click, not a drag
				on_tower_clicked()
			
			is_potential_click = false


func on_tower_clicked():
	print("TOWER Clicked")


func _on_mouse_entered() -> void:
	is_hovered = true
func _on_mouse_exited() -> void:
	is_hovered = false
