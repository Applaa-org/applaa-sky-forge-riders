extends Area3D
class_name Projectile

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var direction: Vector3 = Vector3.FORWARD
var speed: float = 400.0
var damage: int = 20
var lifetime: float = 3.0
var is_ai_projectile: bool = false
var trail_particles: GPUParticles3D

func _ready():
	# Create trail effect
	trail_particles = GPUParticles3D.new()
	add_child(trail_particles)
	trail_particles.process_material = particles.process_material.duplicate()
	trail_particles.emitting = true
	
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float):
	# Move projectile
	global_position += direction * speed * delta
	
	# Update lifetime
	lifetime -= delta
	if lifetime <= 0:
		explode()

func _on_body_entered(body: Node3D):
	if body is SkyBike and not is_ai_projectile:
		body.take_damage(damage)
		explode()
	elif body is AIRacer and is_ai_projectile:
		body.take_damage(damage)
		explode()
	elif body.is_in_group("obstacle"):
		explode()

func explode():
	# Create explosion effect
	var explosion = preload("res://scenes/Explosion.tscn").instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	
	# Remove projectile
	queue_free()