extends CharacterBody3D
class_name SkyBike

@onready var camera: Camera3D = $Camera3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var thruster_left: GPUParticles3D = $ThrusterLeft
@onready var thruster_right: GPUParticles3D = $ThrusterRight
@onready var boost_trail: GPUParticles3D = $BoostTrail
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var shoot_point: Marker3D = $ShootPoint
@onready var shield_mesh: MeshInstance3D = $ShieldMesh

const SPEED: float = 300.0
const BOOST_SPEED: float = 500.0
const ACCELERATION: float = 100.0
const TURN_SPEED: float = 2.0
const DRIFT_FACTOR: float = 1.5
const HOVER_HEIGHT: float = 2.0
const HOVER_STRENGTH: float = 50.0
const MAX_HEALTH: int = 100

var health: int = MAX_HEALTH
var energy: float = 100.0
var boost_active: bool = false
var drift_active: bool = false
var shield_active: bool = false
var current_speed: float = 0.0
var target_speed: float = 0.0
var vertical_velocity: float = 0.0
var tilt_angle: float = 0.0
var shoot_cooldown: float = 0.0
var boost_cooldown: float = 0.0
var shield_cooldown: float = 0.0

signal health_changed(new_health: int)
signal energy_changed(new_energy: float)
signal bike_hit(damage: int)

func _ready():
	shield_mesh.visible = false
	health_changed.emit(health)
	energy_changed.emit(energy)

func _physics_process(delta: float):
	# Update cooldowns
	if shoot_cooldown > 0:
		shoot_cooldown -= delta
	if boost_cooldown > 0:
		boost_cooldown -= delta
	if shield_cooldown > 0:
		shield_cooldown -= delta
	
	# Energy regeneration
	if energy < 100.0:
		energy += 20.0 * delta
		energy_changed.emit(energy)
	
	# Handle input
	handle_movement(delta)
	handle_actions(delta)
	
	# Apply hover physics
	apply_hover_physics(delta)
	
	# Update visual effects
	update_visual_effects()
	
	# Move and slide
	move_and_slide()

func handle_movement(delta: float):
	# Forward/backward movement
	var forward_input = Input.get_axis("ui_down", "ui_up")
	target_speed = forward_input * (BOOST_SPEED if boost_active else SPEED)
	
	# Smooth acceleration
	current_speed = move_toward(current_speed, target_speed, ACCELERATION * delta)
	
	# Calculate forward direction
	var forward_dir = -transform.basis.z
	velocity = forward_dir * current_speed
	
	# Turning
	var turn_input = Input.get_axis("ui_right", "ui_left")
	if turn_input != 0:
		rotate_y(turn_input * TURN_SPEED * delta)
		tilt_angle = -turn_input * 0.3
	else:
		tilt_angle = move_toward(tilt_angle, 0.0, delta * 2.0)
	
	# Drifting
	if Input.is_action_pressed("drift") and current_speed > 100:
		drift_active = true
		velocity.x *= DRIFT_FACTOR
		velocity.z *= DRIFT_FACTOR
	else:
		drift_active = false
	
	# Vertical movement
	if Input.is_action_pressed("ascend"):
		vertical_velocity = min(vertical_velocity + 50.0 * delta, 100.0)
	elif Input.is_action_pressed("descend"):
		vertical_velocity = max(vertical_velocity - 50.0 * delta, -100.0)
	else:
		vertical_velocity = move_toward(vertical_velocity, 0.0, 100.0 * delta)
	
	velocity.y = vertical_velocity

func handle_actions(delta: float):
	# Shooting
	if Input.is_action_just_pressed("shoot") and shoot_cooldown <= 0:
		shoot()
		shoot_cooldown = 0.3
	
	# Boost
	if Input.is_action_pressed("boost") and boost_cooldown <= 0 and energy >= 20:
		boost_active = true
		energy -= 30.0 * delta
		energy_changed.emit(energy)
		if energy <= 0:
			boost_active = false
			boost_cooldown = 2.0
	else:
		boost_active = false
	
	# Shield
	if Input.is_action_just_pressed("shield") and shield_cooldown <= 0 and energy >= 40:
		activate_shield()

func apply_hover_physics(delta: float):
	# Raycast down to find ground
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position - Vector3.UP * 10)
	var result = space_state.intersect_ray(query)
	
	if result:
		var distance_to_ground = global_position.distance_to(result.position)
		if distance_to_ground < HOVER_HEIGHT:
			vertical_velocity += HOVER_STRENGTH * (HOVER_HEIGHT - distance_to_ground) * delta

func shoot():
	var projectile = preload("res://scenes/Projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform = shoot_point.global_transform
	projectile.direction = -transform.basis.z

func activate_shield():
	shield_active = true
	shield_mesh.visible = true
	energy -= 40.0
	energy_changed.emit(energy)
	
	await get_tree().create_timer(3.0).timeout
	shield_active = false
	shield_mesh.visible = false
	shield_cooldown = 5.0

func take_damage(damage: int):
	if shield_active:
		damage = int(damage * 0.3)
	
	health -= damage
	health_changed.emit(health)
	bike_hit.emit(damage)
	
	if health <= 0:
		health = 0
		# Trigger defeat state
		get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")

func update_visual_effects():
	# Update thruster particles based on speed
	var emission_rate = current_speed / SPEED * 50
	thruster_left.emitting = current_speed > 10
	thruster_right.emitting = current_speed > 10
	thruster_left.process_material.emission = emission_rate
	thruster_right.process_material.emission = emission_rate
	
	# Boost trail
	boost_trail.emitting = boost_active
	
	# Camera effects
	if boost_active:
		camera.fov = move_toward(camera.fov, 85.0, 2.0)
	else:
		camera.fov = move_toward(camera.fov, 75.0, 1.0)
	
	# Bike tilt
	mesh.rotation.z = tilt_angle