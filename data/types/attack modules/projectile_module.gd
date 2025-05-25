extends AttackModule
class_name ProjectileModule

@export var damage: float = 20.0
@export var range_bonus: float = 50.0
@export var projectile_speed: float = 300.0
@export var pierce_armor: float = 0.0  # 0-1 percentage

func generate_stats() -> void:
	var level_multiplier = 1.0 + (hidden_level * 0.5)
	var quality_bonus = 1.0 + (quality * 0.3)
	
	damage = randf_range(10, 50) * level_multiplier * quality_bonus
	range_bonus = randf_range(25, 100) * quality_bonus
	projectile_speed = randf_range(200, 500) * quality_bonus
	pierce_armor = randf_range(0.0, 0.5) * quality_bonus

func apply_to_attack(attack_data: Dictionary) -> void:
	attack_data["has_projectile"] = true
	attack_data["projectile_damage"] = attack_data.get("projectile_damage", 0) + damage
	attack_data["range_bonus"] = attack_data.get("range_bonus", 0) + range_bonus
	attack_data["projectile_speed"] = projectile_speed
	attack_data["pierce_armor"] = max(attack_data.get("pierce_armor", 0), pierce_armor)
