extends AttackModule
class_name AreaModule

@export var radius: float = 100.0
@export var attack_speed_modifier: float = 1.0  # Only for standalone
@export var projectile_radius_malus: float = 0.7  # Explosion smaller than standalone
@export var projectile_damage_malus: float = 0.6  # Explosion weaker

func generate_stats() -> void:
	var level_multiplier = 1.0 + (hidden_level * 0.5)
	var quality_bonus = 1.0 + (quality * 0.3)
	
	radius = randf_range(50, 150) * quality_bonus
	attack_speed_modifier = randf_range(0.8, 1.5) * quality_bonus
	projectile_radius_malus = randf_range(0.5, 0.8)
	projectile_damage_malus = randf_range(0.4, 0.7)

func apply_to_attack(attack_data: Dictionary) -> void:
	if attack_data.get("has_projectile", false):
		# Explosion on impact
		attack_data["explosion_radius"] = radius * projectile_radius_malus
		attack_data["damage_malus"] = projectile_damage_malus
	else:
		# Standalone area damage
		attack_data["area_radius"] = radius
		attack_data["attack_speed_modifier"] = attack_speed_modifier
		attack_data["is_area_standalone"] = true
