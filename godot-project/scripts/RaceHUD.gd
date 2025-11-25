extends Control

@onready var speed_label: Label = $SpeedLabel
@onready var lap_label: Label = $LapLabel
@onready var position_label: Label = $PositionLabel
@onready var score_label: Label = $ScoreLabel
@onready var health_bar: ProgressBar = $HealthBar
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var minimap: TextureRect = $Minimap
@onready var weapon_ammo: Label = $WeaponAmmo

var player: SkyBike

func _ready():
	Global.score_changed.connect(_on_score_changed)
	Global.lap_changed.connect(_on_lap_changed)
	Global.position_changed.connect(_on_position_changed)
	
	# Find player
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.energy_changed.connect(_on_energy_changed)

func _process(delta: float):
	if player:
		# Update speed display
		var speed_kmh = int(player.current_speed * 3.6)
		speed_label.text = "%d km/h" % speed_kmh
		
		# Update weapon ammo
		if player.shoot_cooldown > 0:
			weapon_ammo.text = "Reloading..."
		else:
			weapon_ammo.text = "Ready"

func _on_score_changed(new_score: int):
	score_label.text = "Score: %d" % new_score

func _on_lap_changed(new_lap: int):
	lap_label.text = "Lap %d/%d" % [new_lap, Global.total_laps]

func _on_position_changed(new_position: int):
	position_label.text = "Position: %d" % new_position

func _on_health_changed(new_health: int):
	health_bar.value = new_health

func _on_energy_changed(new_energy: float):
	energy_bar.value = new_energy