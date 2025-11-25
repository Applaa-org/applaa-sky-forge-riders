extends Control

@onready var defeat_label: Label = $VBoxContainer/DefeatLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton
@onready var close_button: Button = $VBoxContainer/CloseButton

func _ready():
	# Display race results
	defeat_label.text = "Race Failed"
	score_label.text = "Final Score: %d" % Global.score
	
	# Connect signals
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_restart_pressed():
	Global.reset_race()
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	Global.reset_race()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_close_pressed():
	get_tree().quit()