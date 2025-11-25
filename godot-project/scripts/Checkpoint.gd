extends Area3D
class_name Checkpoint

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D

var checkpoint_index: int = 0
var is_finish_line: bool = false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body is SkyBike:
		var player = body as SkyBike
		if is_finish_line:
			Global.next_lap()
		else:
			# Update checkpoint progress
			if checkpoint_index == Global.checkpoint_index:
				Global.checkpoint_index += 1
				Global.add_score(50)
		
		# Visual feedback
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		particles.emitting = false