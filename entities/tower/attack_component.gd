extends Node2D
class_name AttackComponent

@export var base_damage: float = 10.0
@export var attack_range: float = 150.0
@export var attack_speed: float = 1.0 #Attacks per Second

var current_target: Enemy = null
var time_since_last_attack: float = 0.0
var is_active : bool = true

func _ready() -> void:
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
	var line = Line2D.new()
	line.add_point(Vector2.ZERO)
	line.add_point(target.global_position - global_position)
	line.width = 2.0
	line.default_color = Color.YELLOW
	add_child(line)
	
	await  get_tree().create_timer(0.1).timeout
	line.queue_free()
	
	target.apply_damage(base_damage)
