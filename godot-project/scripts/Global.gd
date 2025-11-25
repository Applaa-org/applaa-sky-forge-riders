extends Node

signal score_changed(new_score: int)
signal lap_changed(new_lap: int)
signal position_changed(new_position: int)

var score: int = 0
var current_lap: int = 1
var current_position: int = 1
var total_laps: int = 3
var race_time: float = 0.0
var best_lap_time: float = INF
var current_lap_time: float = 0.0
var checkpoint_index: int = 0
var race_finished: bool = false

var player_bike_model: String = "standard"
var player_bike_skin: String = "neon_blue"
var player_trail: String = "plasma"

var unlocked_bikes: Array[String] = ["standard"]
var unlocked_skins: Array[String] = ["neon_blue", "carbon_fiber"]
var unlocked_trails: Array[String] = ["plasma", "lightning"]

func add_score(points: int):
	score += points
	score_changed.emit(score)

func reset_race():
	score = 0
	current_lap = 1
	current_position = 1
	race_time = 0.0
	current_lap_time = 0.0
	checkpoint_index = 0
	race_finished = false
	score_changed.emit(score)
	lap_changed.emit(current_lap)
	position_changed.emit(current_position)

func next_lap():
	current_lap += 1
	if current_lap_time < best_lap_time:
		best_lap_time = current_lap_time
	current_lap_time = 0.0
	lap_changed.emit(current_lap)
	
	if current_lap > total_laps:
		race_finished = true

func unlock_bike(bike_name: String):
	if bike_name not in unlocked_bikes:
		unlocked_bikes.append(bike_name)

func unlock_skin(skin_name: String):
	if skin_name not in unlocked_skins:
		unlocked_skins.append(skin_name)

func unlock_trail(trail_name: String):
	if trail_name not in unlocked_trails:
		unlocked_trails.append(trail_name)