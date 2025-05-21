extends Node2D

signal end_reached

@export var acceleration: float = 1.0
@export var speed: float = 100.0

var grid_manager: GridManager
var is_active: bool = true
var target_position := Vector2(1000, 0)
var current_grid_pos: Vector2i
var next_grid_pos: Vector2i
var has_registered_tiles: bool = false

func _ready() -> void:
	# Load speed from enemy data if available
	if get_parent() is Enemy:
		var data: EnemyData = get_parent().data
		speed = data.movement_speed
		acceleration = data.acceleration
	
	grid_manager = get_parent().grid_manager
	
	# Determine starting position and direction
	current_grid_pos = grid_manager.world_to_grid(get_parent().global_position)
	if grid_manager.flow_directions.has(current_grid_pos):
		var direction: Vector2i = grid_manager.flow_directions.get(current_grid_pos, Vector2i.ZERO)
		next_grid_pos = current_grid_pos + direction
		target_position = grid_manager.grid_to_world(next_grid_pos)
		
		# Mark starting tiles as occupied - only for Enemy class
		if get_parent() is Enemy:
			mark_tile_as_occupied(current_grid_pos)
			mark_tile_as_occupied(next_grid_pos)
			has_registered_tiles = true

# This method is called when the object exits the scene
func _exit_tree() -> void:
	# Only clean up tiles if we're an Enemy and have registered tiles
	if has_registered_tiles and is_instance_valid(grid_manager) and get_parent() is Enemy:
		unmark_tile_as_occupied(current_grid_pos)
		unmark_tile_as_occupied(next_grid_pos)
		has_registered_tiles = false

func _physics_process(delta: float) -> void:
	if not is_active or not is_instance_valid(grid_manager):
		return
	
	var parent = get_parent()
	if not is_instance_valid(parent):
		return
		
	var current_pos: Vector2 = parent.global_position
	var new_grid_pos: Vector2i = grid_manager.world_to_grid(current_pos)
	
	# Check if the target has been reached
	if new_grid_pos == Vector2i(0, 0):
		# Only clean up tiles if we're an Enemy
		if has_registered_tiles and parent is Enemy:
			unmark_tile_as_occupied(current_grid_pos)
			unmark_tile_as_occupied(next_grid_pos)
			has_registered_tiles = false
		is_active = false
		emit_signal("end_reached")
		return
	
	# Movement towards the target
	if current_pos.distance_to(target_position) > 5.0:
		var direction: Vector2 = (target_position - current_pos).normalized()
		parent.global_position += direction * speed * delta
	else:
		# We've completely crossed a grid field
		# The old current_grid_pos is no longer occupied
		if has_registered_tiles and parent is Enemy:
			unmark_tile_as_occupied(current_grid_pos)
		
		# Update current position
		current_grid_pos = next_grid_pos
		
		if grid_manager.flow_directions.has(current_grid_pos):
			var direction_vec: Vector2i = grid_manager.flow_directions[current_grid_pos]
			next_grid_pos = current_grid_pos + direction_vec
			target_position = grid_manager.grid_to_world(next_grid_pos)
			
			# Mark the new field as occupied - only for Enemy class
			if parent is Enemy:
				mark_tile_as_occupied(next_grid_pos)
		else:
			# No path available, stop
			is_active = false

# Mark a tile as occupied by this enemy
func mark_tile_as_occupied(tile: Vector2i) -> void:
	# Skip if this is not an Enemy
	if not get_parent() is Enemy:
		return
		
	if grid_manager.occupied_by_enemy.has(tile):
		grid_manager.occupied_by_enemy[tile] += 1
	else:
		grid_manager.occupied_by_enemy[tile] = 1
	has_registered_tiles = true

# Remove this enemy's occupation from a tile
func unmark_tile_as_occupied(tile: Vector2i) -> void:
	# Skip if this is not an Enemy
	if not get_parent() is Enemy:
		return
		
	if grid_manager.occupied_by_enemy.has(tile):
		grid_manager.occupied_by_enemy[tile] -= 1
		if grid_manager.occupied_by_enemy[tile] <= 0:
			grid_manager.occupied_by_enemy.erase(tile)
