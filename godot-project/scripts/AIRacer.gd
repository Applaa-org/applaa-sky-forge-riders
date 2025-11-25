extends CharacterBody3D
class_name AIRacer

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var thruster_particles: GPUParticles3D = $ThrusterParticles
@onready var shoot_point: Marker3D = $ShootPoint

const SPEED: float = 280.0
const AGGRESSIVE_SPEED: float = 320.0
const TURN_SPEED: float = 1.8
const SHOOT_RANGE: float = 100.0
const HEALTH: int = 80

enum Difficulty { EASY, MEDIUM, HARD, EXTREME }
enum Behavior { RACING, AGGRESSIVE, DEFENSIVE }

var difficulty: Difficulty = Difficulty.MEDIUM
var behavior: Behavior = Behavior.RACING
var health: int = HEALTH
var current_speed: float = 0.0
var target_position: Vector3
var waypoints: Array[Vector3] = []
var current_waypoint: int = 0
var shoot_cooldown: float = 0.0
var player: SkyBike

func _ready():
	player = get_tree().get_first_node_in_group("player")
	behavior = Behavior.RACING if difficulty == Difficulty.EASY else Behavior.AGGRESSIVE

func _physics_process(delta: float):
	if shoot_cooldown > 0:
		shoot_cooldown -= delta
	
	# AI behavior based on difficulty and state
	match behavior:
		Behavior.RACING:
			race_behavior(delta)
		Behavior.AGGRESSIVE:
			aggressive_behavior(delta)
		Behavior.DEFENSIVE:
			defensive_behavior(delta)
	
	# Apply movement
	move_and_slide()

func race_behavior(delta: float):
	# Follow waypoints
	if waypoints.size

# ... continuing from above

func race_behavior(delta: float):
	# Follow waypoints
	if waypoints.size() > 0 and current_waypoint < waypoints.size():
		target_position = waypoints[current_waypoint]
		var direction = (target_position - global_position).normalized()
		
		# Look at target
		look_at(global_position + direction, Vector3.UP)
		
		# Move towards target
		var distance_to_target = global_position.distance_to(target_position)
		if distance_to_target < 10.0:
			current_waypoint = (current_waypoint + 1) % waypoints.size()
		
		# Speed based on difficulty
		var speed_multiplier = 1.0
		match difficulty:
			Difficulty.EASY:
				speed_multiplier = 0.8
			Difficulty.MEDIUM:
				speed_multiplier = 1.0
			Difficulty.HARD:
				speed_multiplier = 1.2
			Difficulty.EXTREME:
				speed_multiplier = 1.4
		
		current_speed = move_toward(current_speed, SPEED * speed_multiplier, 50.0 * delta)
		velocity = direction * current_speed

func aggressive_behavior(delta: float):
	# Chase player and shoot
	if player:
		var player_direction = (player.global_position - global_position).normalized()
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Look at player
		look_at(global_position + player_direction, Vector3.UP)
		
		# Shoot if in range
		if distance_to_player < SHOOT_RANGE and shoot_cooldown <= 0:
			shoot()
			shoot_cooldown = 1.5 if difficulty == Difficulty.EASY else 0.8
		
		# Move towards player with speed boost
		var speed_multiplier = 1.3
		match difficulty:
			Difficulty.MEDIUM:
				speed_multiplier = 1.3
			Difficulty.HARD:
				speed_multiplier = 1.5
			Difficulty.EXTREME:
				speed_multiplier = 1.7
		
		current_speed = move_toward(current_speed, AGGRESSIVE_SPEED * speed_multiplier, 60.0 * delta)
		velocity = player_direction * current_speed

func defensive_behavior(delta: float):
	# Maintain distance and evade
	if player:
		var player_direction = (player.global_position - global_position).normalized()
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Keep optimal distance
		var optimal_distance = 80.0
		if distance_to_player < optimal_distance:
			# Move away
			look_at(global_position - player_direction, Vector3.UP)
			velocity = -player_direction * SPEED
		else:
			# Resume racing
			race_behavior(delta)
		
		# Dodge occasionally
		if randf() < 0.1:
			var dodge_direction = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
			velocity += dodge_direction * 50.0

func shoot():
	var projectile = preload("res://scenes/Projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_transform = shoot_point.global_transform
	projectile.direction = -transform.basis.z
	projectile.is_ai_projectile = true

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		# AI defeated - respawn or remove
		queue_free()

func set_waypoints(new_waypoints: Array[Vector3]):
	waypoints = new_waypoints
	current_waypoint = 0

func set_difficulty(new_difficulty: Difficulty):
	difficulty = new_difficulty