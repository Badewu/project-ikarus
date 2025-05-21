class_name ElementSet
extends Resource

enum ElementType {FIRE, WATER, EARTH, AIR, ETHER}

@export var fire: float = 1.0
@export var water: float = 1.0
@export var earth: float = 1.0
@export var air: float = 1.0
@export var ether: float = 1.0

func get_element_modifier(element: ElementType) -> float:
	match element:
		ElementType.FIRE:
			return fire
		
		ElementType.WATER:
			return water
		
		ElementType.EARTH:
			return earth
		
		ElementType.AIR:
			return air
		
		ElementType.ETHER:
			return ether
		
		_:
			print("No valid element in ElementSet to get a value from")
			return 1.0

func set_element_modifier(element: ElementType, value: float) -> void:
	match element:
		ElementType.FIRE:
			fire = value
		
		ElementType.WATER:
			water = value
		
		ElementType.EARTH:
			earth = value
		
		ElementType.AIR:
			air = value
		
		ElementType.ETHER:
			ether = value
		
		_:
			print("No valid Element in ElementSet to set a value to")
