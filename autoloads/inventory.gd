extends Node

var attack_modules : Dictionary = {} #MODULE : is used? - true/false

func _ready() -> void:
	var new_module : AttackModuleResource = load("res://data/attack modules resources/new_weapon.tres")
	attack_modules.new_module = false
