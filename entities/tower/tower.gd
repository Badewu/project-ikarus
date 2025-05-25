extends Area2D
class_name Tower

signal merge_level_changed(new_value: int)

@export var data : TowerData
@export var merge_level : int = 3

#DRAG N DROP/Input
var is_hovered : bool = false
var is_dragged : bool = false:
	set(value):
		is_dragged = value
		#Activate/Deactivate Attacking
		if attack_component:
			attack_component.is_active = !value
var mouse_down_pos: Vector2 = Vector2.ZERO
var drag_threshold: float = 10.0  # Adjust this value as needed
var is_potential_click: bool = false

#LOCATING ON THE GRID
var grid_manager : GridManager
var original_position: Vector2
var inventory_ui

#Components
var attack_component : AttackComponent

#Module System
@export var module_slots : int = 1
@export var equipped_modules : Array[AttackModule] = []

func _ready() -> void:
	#Updated VARs
	attack_component = get_node("AttackComponent")
	inventory_ui = get_node("InventoryUI")
	if get_parent() is GridManager:
		grid_manager = get_parent()
	else:
		print("No GridManager found")
	
	emit_signal("merge_level_changed", merge_level)



func _process(delta: float) -> void:
	#DRAG N DROP
	if is_dragged:
		var grid_mouse_position = grid_manager.world_to_grid(get_global_mouse_position())
		var fixed_position = grid_manager.grid_to_world(grid_mouse_position)
		global_position = fixed_position + grid_manager.grid_offset


func equip_module(module : AttackModule, slot_index : int) -> void:
	if slot_index < module_slots:
		equipped_modules[slot_index] = module
		recalculate_attack_stats()


func unequip_module(slot_index : int) -> AttackModule:
	if slot_index < module_slots:
		var module = equipped_modules[slot_index]
		equipped_modules[slot_index] = null
		recalculate_attack_stats()
		return module
	return null


func recalculate_attack_stats() -> void:
	if not attack_component:
		return
	
	#Reset
	var attack_data := {
		"base_damage" : attack_component.base_damage,
		"attack_range" : attack_component.attack_range,
		"attack_speed" : attack_component.attack_speed
	}
	
	#Apply modules
	for module in equipped_modules:
		if module:
			module.apply_to_attack(attack_data)
	
	#update attack component
	attack_component.update_from_modules(attack_data)


func update_module_slots() -> void:
	#Based on merge_level
	module_slots = merge_level
	equipped_modules.resize(module_slots)
	
	if inventory_ui:
		update_module_ui()


func update_module_ui() -> void:
	var module_container = inventory_ui.get_node("VBoxContainer/UpgradeModules")
	
	# Clear old slots
	for child in module_container.get_children():
		child.queue_free()
	
	# Create new slots
	for i in module_slots:
		var slot = preload("res://entities/tower/UI/tower_modul_slot.tscn").instantiate()
		slot.slot_index = i
		slot.tower = self
		slot.custom_minimum_size = Vector2(48, 48)
		if i < equipped_modules.size() and equipped_modules[i]:
			slot.set_module(equipped_modules[i])
		module_container.add_child(slot)
	
	#module_container.hide()


func _input(event: InputEvent) -> void:
	# DRAG AND DROP WITH CLICK DETECTION
	if event is InputEventMouseButton and event.pressed:
		update_module_slots()
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
	update_module_slots()


func _on_drag_n_drop_area_mouse_entered() -> void:
	is_hovered = true
func _on_drag_n_drop_area_mouse_exited() -> void:
	is_hovered = false
