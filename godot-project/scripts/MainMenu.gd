extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var career_button: Button = $VBoxContainer/CareerButton
@onready var time_trials_button: Button = $VBoxContainer/TimeTrialsButton
@onready var customize_button: Button = $VBoxContainer/CustomizeButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var exit_button: Button = $VBoxContainer/ExitButton
@onready var background_animation: AnimationPlayer = $Background/AnimationPlayer

func _ready():
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	career_button.pressed.connect(_on_career_pressed)
	time_trials_button.pressed.connect(_on_time_trials_pressed)
	customize_button.pressed.connect(_on_customize_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Start background animation
	background_animation.play("rotate_bike")

func _on_start_pressed():
	Global.reset_race()
	get_tree().change_scene_to_file("res://scenes/TrackSelect.tscn")

func _on_career_pressed():
	get_tree().change_scene_to_file("res://scenes/CareerMode.tscn")

func _on_time_trials_pressed():
	get_tree().change_scene_to_file("res://scenes/TimeTrials.tscn")

func _on_customize_pressed():
	get_tree().change_scene_to_file("res://scenes/Customization.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_exit_pressed():
	get_tree().quit()