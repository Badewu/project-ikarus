# data/types/attack_modules/attack_module.gd
extends Resource
class_name AttackModule

enum ModuleType { ELEMENTAL, PROJECTILE, AREA }
enum ElementType { FIRE, WATER, EARTH, AIR, ETHER }
enum Quality { NORMAL, RARE, EPIC }

@export var module_type: ModuleType
@export var module_name: String = "Basic Module"
@export var icon: Texture2D
@export var hidden_level: int = 1
@export var quality: Quality = Quality.NORMAL

# Apply module effects to attack data
func apply_to_attack(attack_data: Dictionary) -> void:
	pass  # Override in subclasses

# Generate random stats based on hidden level
func generate_stats() -> void:
	pass  # Override in subclasses
