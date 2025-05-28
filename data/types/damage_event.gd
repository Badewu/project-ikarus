extends Resource
class_name DamageEvent

@export var base_damage: float = 0
@export var element: ElementSet.ElementType
@export var proficiency: float = 1.0
@export var is_critical: bool = false
@export var status_effects: Array[String] = []

# Elemental Effects
@export var dot_damage: float = 0.0
@export var dot_duration: float = 0.0
@export var slow_strength: float = 0.0
@export var stun_duration: float = 0.0 
@export var chain_count: int = 0 
