extends AttackModule
class_name ElementalModule

@export var element: ElementType = ElementType.FIRE
@export var initial_damage: float = 10.0
@export var dot_damage: float = 5.0  # Damage over time
@export var dot_duration: float = 3.0
@export var effect_strength: float = 1.0  # For slow/stun effects

func generate_stats() -> void:
	# Ranges based on hidden level and quality
	var level_multiplier = 1.0 + (hidden_level * 0.5)
	var quality_bonus = 1.0 + (quality * 0.3)
	
	# Randomize within range
	initial_damage = randf_range(5, 25) * level_multiplier * quality_bonus
	dot_damage = randf_range(2, 15) * level_multiplier * quality_bonus
	dot_duration = randf_range(2, 8) * quality_bonus
	effect_strength = randf_range(0.5, 2.0) * quality_bonus

func apply_to_attack(attack_data: Dictionary) -> void:
	attack_data["element"] = element
	attack_data["elemental_damage"] = initial_damage
	attack_data["dot_damage"] = dot_damage
	attack_data["dot_duration"] = dot_duration
	attack_data["effect_strength"] = effect_strength
