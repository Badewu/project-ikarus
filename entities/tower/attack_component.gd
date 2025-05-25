extends Node2D
class_name AttackComponent

@export var base_damage : float = 10.0
@export var attack_range : float = 150.0
@export var attack_speed : float = 1.0 #Attacks per Second

#Modified by Module
var current_damage : float
var current_range: float
var current_attack_speed: float
var attack_data: Dictionary = {}

var current_target: Enemy = null
var time_since_last_attack: float = 0.0
var is_active : bool = true

func _ready() -> void:
	current_damage = base_damage
	current_range = attack_range
	current_attack_speed = attack_speed
	update_range_collision()
	
	#Setup RangeCollision of Tower
	var tower : Tower = get_parent()
	if tower and tower.has_node("RangeCollision"):
		var collision_shape = tower.get_node("RangeCollision")
		collision_shape.shape.radius = attack_range
	print(attack_range)


func _process(delta: float) -> void:
	
	time_since_last_attack += delta
	if not is_active:
		current_target = null
		return
	
	if not current_target or not is_instance_valid(current_target):
		find_new_target()
	
	if current_target:
		if current_target.global_position.distance_to(get_parent().global_position) >= attack_range or !current_target.is_alive:
			find_new_target()
	
	if current_target and time_since_last_attack >= 1.0 / attack_speed:
		attack_target()
		time_since_last_attack = 0.0


func update_range_collision() -> void:
	var tower : Tower = get_parent()
	if tower and tower.has_node("RangeCollision"):
		var collision_shape = tower.get_node("RangeCollision")
		collision_shape.shape.radius = current_range


func update_from_modules(data : Dictionary) -> void:
	attack_data = data
	
	#Update stats
	current_damage = data.get("base_damage", base_damage) + data.get("projectile_damage", 0)
	current_range = attack_range + data.get("range_bonus", 0)
	current_attack_speed = attack_speed * data.get("attack_speed_modifier", 1.0)
	
	update_range_collision()


func attack_target() -> void:
	if current_target:
		print(current_target.global_position.distance_to(get_parent().global_position))
		create_projectile(current_target)


func find_new_target() -> void:
	var tower : Tower = get_parent()
	var enemies_in_range = tower.get_overlapping_areas()
	if enemies_in_range.size() <= 0:
		current_target = null
	
	for area in enemies_in_range:
		if area is Enemy and area.is_alive:
			current_target = area
			break


func create_projectile(target : Enemy) -> void:
	
	if attack_data.get("has_projectile", false):
		var projectile = create_projectile_instance(target)
	elif attack_data.get("is_area_standalone", false):
		apply_area_damage()
	else:
		apply_direct_damage(target) #I think I might want to remove this
									#because no Projectile/Area -> no Damage




func create_projectile_instance(target : Enemy) -> Node2D:
	#Implement actual projectile later
	
	apply_direct_damage(target) # Placeholder
	return null


func apply_area_damage() -> void:
	var radius = attack_data.get("area_radius", 100)
	
	#Visual
	var circle = Line2D.new()
	for i in 32:
		var angle = i * TAU / 32
		circle.add_point(Vector2(cos(angle), sin(angle)) * radius)
	circle.closed = true
	circle.width = 2.0
	circle.default_color = Color(1, 0.5, 0, 0.5)
	add_child(circle)
	
	#Enemydetection
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position
	query.collision_mask = 1 #Eventually change this to detect enemy
	
	var results = space_state.intersect_point(query, 32)
	for result in results:
		var collider = result.collider
		if collider.get_parent() is Enemy:
			var enemy : Enemy = collider.get_parent()
			var distance = enemy.global_position.distance_to(global_position)
			if distance <= radius:
				apply_direct_damage(enemy)
	await get_tree().create_timer(0.2).timeout
	circle.queue_free()

func apply_direct_damage(target : Enemy) -> void:
	#Visuals
	var line = Line2D.new()
	line.add_point(Vector2.ZERO)
	line.add_point(target.global_position - global_position)
	line.width = 2.0
	line.default_color = Color.YELLOW
	add_child(line)
	
	await  get_tree().create_timer(0.1).timeout
	line.queue_free()
	
	#Damage with elemental effects opposed to previous version
	var damage_event = DamageEvent.new()
	damage_event.base_damage = current_damage
	#Might want to remove the standard fire implementation
	damage_event.element = attack_data.get("element", ElementSet.ElementType.FIRE)
	damage_event.proficiency = 1.0 #Proof of concept modifier
	
	target.apply_damage_event(base_damage)
