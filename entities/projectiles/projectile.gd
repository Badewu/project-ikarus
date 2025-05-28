extends Area2D
class_name Projectile

@export var speed: float = 300.0
@export var damage: float = 10.0
@export var damage_event: DamageEvent
@export var projectile_sprite_path : String = "res://icon.svg"

var target: Enemy = null
var direction: Vector2 = Vector2.ZERO
var max_distance: float = 1000.0
var traveled_distance: float = 0.0

# Visual settings
@export var projectile_color: Color = Color.YELLOW
@export var trail_enabled: bool = true

func _ready() -> void:
	# Create projectile sprite
	var sprite = Sprite2D.new()
	sprite.texture = load(projectile_sprite_path)
	sprite.scale = Vector2(0.1, 0.1) #Change this with new Sprite!
	sprite.modulate = projectile_color
	add_child(sprite)
	
	# Create collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 5
	collision.shape = shape
	add_child(collision)
	
	# Create trail effect
	if trail_enabled:
		var trail = CPUParticles2D.new()
		trail.amount = 20
		trail.lifetime = 0.3
		trail.emission_shape = CPUParticles2D.EMISSION_SHAPE_POINT
		trail.spread = 0.0
		trail.initial_velocity_min = 0.0
		trail.initial_velocity_max = 0.0
		trail.scale_amount_min = 0.5
		trail.scale_amount_max = 1.0
		trail.color = projectile_color
		trail.color.a = 0.5
		add_child(trail)
	
	# Connect area detection
	area_entered.connect(_on_area_entered)
	
	# Set rotation based on direction
	if direction != Vector2.ZERO:
		rotation = direction.angle()

func _physics_process(delta: float) -> void:
	# Update direction to target if we have one
	if target and is_instance_valid(target) and target.is_alive:
		direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()
	
	# Move projectile
	var movement = direction * speed * delta
	position += movement
	traveled_distance += movement.length()
	
	# Remove if traveled too far
	if traveled_distance > max_distance:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area == target and area is Enemy:
		# Apply damage
		if damage_event:
			area.apply_damage_event(damage_event)
		else:
			area.apply_damage(damage)
		
		# Create hit effect
		create_hit_effect()
		
		# Remove projectile
		queue_free()

func create_hit_effect() -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 10
	particles.lifetime = 0.3
	particles.one_shot = true
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	particles.color = projectile_color
	
	get_parent().add_child(particles)
	particles.global_position = global_position
	
	# Clean up after emission
	await particles.finished
	particles.queue_free()

func set_target(new_target: Enemy, source_position: Vector2) -> void:
	target = new_target
	global_position = source_position
	if target:
		direction = (target.global_position - source_position).normalized()
		rotation = direction.angle()
