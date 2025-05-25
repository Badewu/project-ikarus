extends Node

var owned_module : Array[AttackModule] = []
var module_selection_ui : Control

func _ready() -> void:
	generate_test_modules()


func generate_test_modules():
	var fire_module : AttackModule = ElementalModule.new()
	fire_module.module_name = "Roaring Inferno"
	fire_module.element = AttackModule.ElementType.FIRE
	fire_module.hidden_level = 1
	fire_module.quality = AttackModule.Quality.NORMAL
	fire_module.generate_stats()
	add_module(fire_module)
	
	var proj_module : AttackModule = ProjectileModule.new()
	proj_module.module_name = "Sniperino"
	proj_module.hidden_level = 1
	proj_module.quality = AttackModule.Quality.RARE
	proj_module.generate_stats()
	add_module(proj_module)
	
	var area_module : AttackModule = AreaModule.new()
	area_module.module_name = "Beefy Bumper"
	area_module.hidden_level = 1
	area_module.quality = AttackModule.Quality.NORMAL
	area_module.generate_stats()
	add_module(area_module)


func add_module(module : AttackModule) -> void:
	owned_module.append(module)


func remove_module(module : AttackModule) -> void:
	owned_module.erase(module)


func open_module_selection(slot : TextureButton) -> void:
	if not module_selection_ui:
		create_module_selection_ui()
	
	module_selection_ui.show()
	populate_module_list(slot)


func create_module_selection_ui() -> void:
	module_selection_ui = PanelContainer.new()
	module_selection_ui.custom_minimum_size = Vector2(400, 600)
	module_selection_ui.position = Vector2(get_viewport().size) / 2 - Vector2(200, 300)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	module_selection_ui.add_child(vbox)
	
	var title = Label.new()
	title.text = "Select Module"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.custom_minimum_size = Vector2(0, 500)
	vbox.add_child(scroll)
	
	var module_list = VBoxContainer.new()
	module_list.name = "ModuleList"
	scroll.add_child(module_list)
	
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(module_selection_ui.hide)
	vbox.add_child(close_btn)
	
	get_tree().root.add_child(module_selection_ui)
	module_selection_ui.hide()


func populate_module_list(target_slot : TextureButton) -> void:
	var module_list = module_selection_ui.get_node("VBoxContainer/ScrollContainer/ModuleList")
	
	#clear ols entries
	for child in module_list.get_children():
		child.queue_free()
	#populate
	for module in owned_module:
		var btn = create_module_button(module, target_slot)
		module_list.add_child(btn)


func create_module_button(module : AttackModule, target_slot : TextureButton) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(250, 80)
	
	var hbox = HBoxContainer.new()
	btn.add_child(hbox)
	
	var icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(64, 64)
	icon.texture = module.icon if module.icon else preload("res://icon.svg")
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(icon)
	
	var info_vbox = VBoxContainer.new()
	hbox.add_child(info_vbox)
	
	var name_label = Label.new()
	name_label.text = module.module_name
	name_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(name_label)
	
	var type_label = Label.new()
	type_label.text = "Type: %s | Quality: %s" % [
		["Elemental", "Projectile", "Area"][module.module_type],
		["Normal", "Rare", "Epic"][module.quality]
	]
	info_vbox.add_child(type_label)
	
	var stats_label = Label.new()
	stats_label.text = get_module_stats_text(module)
	info_vbox.add_child(stats_label)
	
	btn.pressed.connect(func():
		var old_module = target_slot.current_module
		
		target_slot.set_module(module)
		target_slot.tower.equip_module(module, target_slot.slot_index)
		remove_module(module)
		
		if old_module:
			add_module(old_module)
		
		module_selection_ui.hide()
	)
	
	return btn


func get_module_stats_text(module : AttackModule) -> String:
	if module is ElementalModule:
		return "Damage: %.1f | DoT %.1f/s for %.1fs" % [
			module.initial_damage,
			module.dot_damage,
			module.dot_duration
		]
	elif module is ProjectileModule:
		return "Damage: %.1f | Range: +%.0f | Speed: %.0f" % [
			module.damage,
			module.range_bonus,
			module.projectile_speed
		]
	elif module is AreaModule:
		return "Radius: %.0f | Attack Speed: x%.1f" % [
			module.radius,
			module.attack_speed_modifier
		]
	return "Inkown module type"
