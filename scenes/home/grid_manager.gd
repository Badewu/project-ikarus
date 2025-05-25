extends TileMapLayer

class_name GridManager
#DRAW THE GRID
@export var debug : bool = true
var grid_color := Color(0.5, 0.5, 0.5, 0.5)  # transparent grey
var grid_size : int = 64
var grid_offset : Vector2 = Vector2(0, 0)
var pitch_size : int = 32
#GRID DATA
@export var towers_placed: Dictionary = {}
@export var blocked_tiles : Array[Vector2i] = []
@export var spawners_placed : Dictionary = {}
@export var occupied_by_enemy : Dictionary = {}

var flow_directions: Dictionary = {}
var flow_goal: Vector2i = Vector2i(0, 0)
#@export var blocked_tower_tiles : Array[Vector2i]


func _ready() -> void:
	generate_flow_field(flow_goal)


func generate_flow_field(goal: Vector2i) -> bool:
	var open = [goal]
	var visited = {goal : true}
	flow_directions.clear()
	
	while open.size() > 0:
		var current = open.pop_front()
		var neighbours = get_neighbours(current)
		
		for neighbour in neighbours:
			if visited.has(neighbour):
				continue
			if blocked_tiles.has(neighbour):
				continue
			if towers_placed.has(neighbour):
				continue
			if neighbour.x <= -pitch_size or neighbour.x >= pitch_size:
				continue
			if neighbour.y <= -pitch_size or neighbour.y >= pitch_size:
				continue
			
			#SETUP DIRECTION FROM NEIGHBOUR TO GOAL
			var v2_current : Vector2 = current
			var v2_neighbour : Vector2 = neighbour
			var direction = (v2_current - v2_neighbour).normalized()
			flow_directions[neighbour] = direction
			visited[neighbour] = true
			open.append(neighbour)
	
	flow_directions[goal] = Vector2.ZERO
	
	#SETUP DEBUG ARROWS
	if debug:
		for child in get_node("DebugArrows").get_children():
			child.queue_free()
		for direction in flow_directions:
			if direction == Vector2i(0, 0):
				continue
			var new_sprite: Sprite2D = Sprite2D.new()
			var texture = load("res://assets/Placeholder/debug/Arrow.png")
			new_sprite.texture = texture
			new_sprite.global_position = grid_to_world(direction)
			get_node("DebugArrows").add_child(new_sprite)
			var v2_direction : Vector2 = flow_directions[direction]
			new_sprite.rotation = v2_direction.angle()
			new_sprite.z_index = -10
			new_sprite.modulate = Color(1, 1, 1, 0.1)
	
	#CHECK IF VECTOR.ZERO IS REACHABLE
	if spawners_placed.size() > 0:
		for spawner in spawners_placed:
			if not visited.has(spawner):
				print("Path blocked")
				return false
		
	return true
	
	


func get_neighbours(tile: Vector2i) -> Array[Vector2i]:
	var neighbours = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var result: Array[Vector2i] = []
	
	for direction in neighbours:
		var neighbour = tile + direction
		result.append(neighbour)
	
	return result


func world_to_grid(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))


func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var tile_origin = to_global(map_to_local(grid_pos))
	return map_to_local(grid_pos)

  
func grid_to_world_pathfinding(grid_pos: Vector2i) -> Vector2:
	var tile_origin = to_global(map_to_local(grid_pos))
	return tile_origin + Vector2(grid_size, grid_size) * 0.5# Middle of Tile


func try_place_spawner(spawner: Spawner, target_world_pos: Vector2) -> void:
	var grid_pos = world_to_grid(target_world_pos)
	
	if blocked_tiles.has(grid_pos):
		return_tile_to_original_position(spawner)
		print("Forbidden Area")
		return
	
	if towers_placed.has(grid_pos):
		return_tile_to_original_position(spawner)
		print("Tower here!")
		return
	
	if spawners_placed.has(grid_pos):
		if spawners_placed[grid_pos] == spawner:
			print("I was already here!")
			return
	
	if not spawners_placed.has(grid_pos):
		#Tile is empty - place
		delete_previous_spawner_entry(spawner)
		spawners_placed[grid_pos] = spawner
		
		spawner.global_position = grid_to_world(grid_pos) + grid_offset
		spawner.original_position = spawner.global_position
		print("Spawner moved to !" + str(grid_pos))
		generate_flow_field(flow_goal)
		return


func try_place_tower(tower: Tower, target_world_pos: Vector2) -> void:
	var grid_pos = world_to_grid(target_world_pos)
	
	if occupied_by_enemy.has(grid_pos):
		return_tile_to_original_position(tower)
		print("Enemy in the way!")
		return
	
	if blocked_tiles.has(grid_pos):
		return_tile_to_original_position(tower)
		print("Forbidden Area!")
		return
	
	if spawners_placed.has(grid_pos):
		return_tile_to_original_position(tower)
		print("Spawner here!")
		return
	
	if not towers_placed.has(grid_pos):
		#Tile is empty - place
		delete_previous_tower_entry(tower)
		towers_placed[grid_pos] = tower
		print("IS EMPTY...")
		if not generate_flow_field(flow_goal):
			print("BUT WOULD BLOCK THE WAY")
			delete_previous_tower_entry(tower)
			generate_flow_field(flow_goal)
			var new_grid_pos = world_to_grid(tower.original_position)
			towers_placed[new_grid_pos] = tower
			return_tile_to_original_position(tower)
			return
		
		tower.global_position = grid_to_world(grid_pos) + grid_offset
		tower.original_position = tower.global_position
		print("Tower moved to !" + str(grid_pos))
		generate_flow_field(flow_goal)
		return
	
	if towers_placed[grid_pos] == tower:
		return_tile_to_original_position(tower)
		print("I was already here!")
		return
	else:
		var existing = towers_placed[grid_pos] #Get node thats on the intended tile
		
		if existing is Tower:
			try_merge_tower(tower, existing)
		else:
			return_tile_to_original_position(tower)
			print("Obstacle not a tower!")
	


func try_merge_tower(tower1: Tower, tower2: Tower):
	if tower1.merge_level == tower2.merge_level:
		var tower2_grid_pos: Vector2i = world_to_grid(tower2.global_position)
		
		delete_previous_tower_entry(tower1)
		towers_placed[tower2_grid_pos] = tower1
		
		tower1.merge_level += 1
		tower1.original_position = tower2.original_position
		tower1.emit_signal("merge_level_changed", tower1.merge_level)
		tower1.update_module_slots()
		print("Tower Merge Level Is Now " + str(tower1.merge_level))
		tower2.queue_free()
		generate_flow_field(flow_goal)
	else:
		return_tile_to_original_position(tower1)
		print("Merge Failed")


func return_tile_to_original_position(tile):
	tile.position = tile.original_position


func delete_previous_tower_entry(tower):
	for coord in towers_placed:
		if tower == towers_placed[coord]:
			towers_placed.erase(coord)

func delete_previous_spawner_entry(spawner):
	for coord in spawners_placed:
		if spawner == spawners_placed[coord]:
			spawners_placed.erase(coord)


func _draw():
	if debug:
		for x in range(-pitch_size +1, pitch_size):
			var from = Vector2(x * grid_size, -pitch_size * grid_size)# + grid_offset
			var to = Vector2(x * grid_size, pitch_size * grid_size)# + grid_offset
			draw_line(from, to, grid_color, 2.0)
		
		for y in range(-pitch_size +1, pitch_size):
			var from = Vector2(-pitch_size * grid_size, y * grid_size)# + grid_offset
			var to = Vector2(pitch_size * grid_size, y * grid_size)# + grid_offset
			draw_line(from, to, grid_color, 2.0)
