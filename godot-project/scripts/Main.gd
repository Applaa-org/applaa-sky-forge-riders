extends Node3D

@onready var player: SkyBike = $SkyBike
@onready var ai_racers: Array = [$AIRacer1, $AIRacer2, $AIRacer3]
@onready var checkpoints: Array = [$Track/Checkpoint1, $Track/Checkpoint2, $Track/Checkpoint3]
@onready var finish_line: Checkpoint = $Track/FinishLine
@onready var race_hud: RaceHUD = $RaceHUD

var race_time: float = 0.0
var race_started: bool = false
var race_finished: bool = false

func _ready():
	# Set up AI waypoints
	var waypoints: Array[Vector3] = []
	for checkpoint in checkpoints:
		waypoints.append(checkpoint.global_position)
	waypoints.append(finish_line.global_position)
	
	for ai in ai_racers:
		ai.set_waypoints(waypoints)
		ai.set_difficulty(AIRacer.Difficulty.MEDIUM)
	
	# Set up finish line
	finish_line.is_finish_line = true
	
	# Start race countdown
	start_race_countdown()

func _process(delta: float):
	if race_started and not race_finished:
		race_time += delta
		Global.race_time = race_time
		
		# Check win condition
		if Global.race_finished:
			end_race(true)

func start_race_countdown():
	# Implement countdown before race starts
	await get_tree().create_timer(3.0).timeout
	race_started = true

func end_race(victory: bool):
	race_finished = true
	if victory:
		get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")