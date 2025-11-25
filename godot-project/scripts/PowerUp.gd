extends Area3D
class_name PowerUp

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum PowerUpType { SPEED_BOOST, HEALTH, ENERGY, SHIELD, EMP }

var power_type: PowerUpType = PowerUpType.SPEED_BOOST
var value: int = 10
var respawn_time: float = 5.0
var active: bool = true

func _ready():
	body_entered.connect(_on_body_entered)
	animation_player.play("float")

func _on_body_entered(body: Node3D):
	if body is SkyBike and active:
		var player = body as SkyBike
		apply_effect(player)
		collect()

func apply_effect(player: SkyBike):
	match power_type:
		PowerUpType.SPEED_BOOST:
			player.current_speed = min(player.current_speed + 100, player.BOOST_SPEED)
		PowerUpType.HEALTH:
			player.health = min(player.health + 30, player.MAX_HEALTH)
			player.health_changed.emit(player.health)
		PowerUpType.ENERGY:
			player.energy = min(player.energy + 50, 100.0)
			player.energy_changed.emit(player.energy)
		PowerUpType.SHIELD:
			player.activate_shield()
		PowerUpType.EMP:
			# EMP effect - disable nearby AI
			var ai_riders = get_tree().get_nodes_in_group("ai_racer")
			for ai in ai_riders:
				var distance = global_position.distance_to(ai.global_position)
				if distance < 50.0:
					ai.current_speed = 0

func collect():
	active = false
	mesh.visible = false
	particles.emitting = false
	Global.add_score(value)
	
	# Respawn after delay
	await get_tree().create_timer(respawn_time).timeout
	active = true
	mesh.visible = true
	particles.emitting = true