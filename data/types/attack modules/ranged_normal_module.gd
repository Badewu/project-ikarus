extends AttackModuleResource

class_name RangedNormalModule

@export var speed : float = 300

func apply_to_attack(attack_data : Dictionary):
	attack_data.projectile_count = attack_data.get("projectile_count", 0) +1
	attack_data.projectile_speed = speed
