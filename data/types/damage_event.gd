extends Resource
class_name DamageEvent

@export var base_damage: float = 0
@export var element: ElementSet.ElementType
@export var proficiency: float = 1.0
@export var is_critical: bool = false
@export var status_effects: Array[String] = []
