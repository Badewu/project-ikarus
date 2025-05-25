extends TextureButton

signal module_changed(new_module : AttackModule)

var slot_index : int = 0
var tower : Tower 
var current_module : AttackModule = null

func _ready() -> void:
	custom_minimum_size = Vector2(48, 48)
	texture_normal = preload("res://icon.svg")
	modulate = Color(0.5, 0.5, 0.5) #Dark empty slot


func set_module(module : AttackModule) -> void:
	current_module = module
	if module:
		if module.icon:
			texture_normal = module.icon
		modulate = Color.WHITE
		#Eventually Tooltip text
	
	module_changed.emit(module)

func _on_pressed() -> void:
	var module_inventory = get_node("/root/ModuleInventory")
	if module_inventory:
		module_inventory.open_module_selection(self) #Look into this


func can_accept_module(module : AttackModule) -> bool:
	#For now always true, may change with synergies
	return true


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.has("module"):
		return can_accept_module(data.module)
	return false


func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.has("module"):
		var old_module = current_module
		set_module(data.module)
		tower.equip_module(data.module, slot_index)
	
		if old_module:
			var inventory = get_node("/root/ModuleInventory")
			inventory.add_module(old_module)
