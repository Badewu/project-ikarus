extends TextureButton

signal module_changed(new_module : AttackModule)

var slot_index : int = 0
var tower : Tower 
var current_module : AttackModule = null

var base_proj_icon : String = "res://assets/Placeholder/modules/projectile_module.png"
var base_area_icon : String = "res://assets/Placeholder/modules/area_module.png"
var base_element_icon : String = "res://assets/Placeholder/modules/elemental_module.png"

func _ready() -> void:
	custom_minimum_size = Vector2(48, 48)
	texture_normal = preload("res://icon.svg")
	modulate = Color(0.5, 0.5, 0.5) #Dark empty slot
	print("Connection ready? " + str(pressed.is_connected(_on_pressed)))


func set_module(module : AttackModule) -> void:
	current_module = module
	if module:
		var icon
		match module.module_type:
			AttackModule.ModuleType.PROJECTILE:
				icon = load(base_proj_icon)
			AttackModule.ModuleType.AREA:
				icon = load(base_area_icon)
			AttackModule.ModuleType.ELEMENTAL:
				icon = load(base_element_icon)
		
		if module.icon:
			icon = module.icon
		
		texture_normal = module.icon
		modulate = Color.WHITE
		#Eventually Tooltip text
	
	module_changed.emit(module)

func _on_pressed() -> void:
	print("slot got clicked")
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
