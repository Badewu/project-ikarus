extends Area2D
class_name Enemy

enum State {IDLE, MOVING, ATTACKING, DEAD}

@export var data: EnemyData

#Live Data
var current_state: State = State.MOVING
var is_alive: bool = true
var current_health : float
var max_health : float

#REFERENCE
var grid_manager : GridManager

#MODULES
var animated_sprite : AnimatedSprite2D
var movement : Node2D
var collision : CollisionShape2D 

func _ready() -> void:
	set_animation_frames()
	set_movement()
	set_rank()
	set_collision()
	set_stats()

func _process(delta: float) -> void:
	if is_alive:
		match current_state:
			State.IDLE:
				animated_sprite.animation = "idle"
				animated_sprite.play()
				movement.is_active = false
			State.MOVING:
				animated_sprite.animation = "run"
				animated_sprite.play()
				movement.is_active = true
			State.DEAD:
				is_alive = false
				collision.hide()
				animated_sprite.play("die")
				movement.is_active = false
				await animated_sprite.animation_finished
				queue_free()

#FOR DEBUG
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_accept"):
		#current_state = State.DEAD


func set_stats() -> void:
	max_health = calculate_health_from_data()
	current_health = max_health


func calculate_health_from_data() -> float:
	var health = data.base_health
	#If no reasonable Health data is present
	if health <= 0:
		health = 50 * data.level
	return health


func apply_damage(amount : float):
	current_health -= amount
	
	#Visual feedback
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		current_state = State.DEAD


func set_animation_frames():
	animated_sprite= get_node("AnimatedSprite")
	var idle_animation_frames : Array[Texture2D] = data.idle_animation_frames
	var run_animation_frames : Array[Texture2D] = data.run_animation_frames
	var die_animation_frames : Array[Texture2D] = data.die_animation_frames
	
	animated_sprite.sprite_frames = animated_sprite.sprite_frames.duplicate(true)
	
	for frame in idle_animation_frames:
		animated_sprite.sprite_frames.add_frame("idle", frame)
	for frame in run_animation_frames:
		animated_sprite.sprite_frames.add_frame("idle", frame)
	for frame in die_animation_frames:
		animated_sprite.sprite_frames.add_frame("die", frame)


func set_movement() -> void:
	movement = data.movement_pattern.instantiate()
	add_child(movement)
	movement.end_reached.connect(_on_movement_end_reached)

func _on_movement_end_reached():
	current_state = State.DEAD


func set_rank():
	match data.rank:
		EnemyData.EnemyRank.MASS:
			pass
		EnemyData.EnemyRank.NORMAL:
			pass
		EnemyData.EnemyRank.MONSTER:
			pass
		EnemyData.EnemyRank.DEMIGOD:
			pass
		EnemyData.EnemyRank.GOD:
			pass
		EnemyData.EnemyRank.TITAN:
			pass


func set_collision():
	collision = get_node("Collision")
	
	match data.rank:
		EnemyData.EnemyRank.MASS:
			pass
		EnemyData.EnemyRank.NORMAL:
			collision.shape.radius = 40
			collision.shape.height = 60
			collision.position += Vector2(0, 2)
		EnemyData.EnemyRank.MONSTER:
			pass
		EnemyData.EnemyRank.DEMIGOD:
			pass
		EnemyData.EnemyRank.GOD:
			pass
		EnemyData.EnemyRank.TITAN:
			pass
