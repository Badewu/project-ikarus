class_name EnemyData
extends Resource

enum EnemyRank {MASS, NORMAL, MONSTER, DEMIGOD, GOD, TITAN}

@export var name: String
@export var idle_animation_frames: Array[Texture2D]
@export var run_animation_frames: Array[Texture2D]
@export var die_animation_frames: Array[Texture2D]

@export var rank: EnemyRank = EnemyRank.NORMAL
@export var level: int = 1
@export var experience: int = 0

@export var movement_speed: float
@export var acceleration: float
@export var movement_pattern: PackedScene

#OFFENSE
@export var weapon_proficiency: float = 1.0
@export var weapon_element: ElementSet

#DEFENSE
@export var base_health: int
@export var resistances: ElementSet
