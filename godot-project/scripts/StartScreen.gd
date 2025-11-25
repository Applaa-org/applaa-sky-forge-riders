extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var close_button: Button = $VBoxContainer/CloseButton
@onready var instructions_label: RichTextLabel = $VBoxContainer/InstructionsLabel

func _ready():
	# Set up the UI
	title_label.text = "Sky Forge Riders"
	instructions_label.text = "[center]Welcome to Sky Forge Riders![/center]\n\n" + \
		"[center]Controls:[/center]\n" + \
		"[center]W/S or Up/Down - Accelerate/Brake[/center]\n" + \
		"[center]A/D or Left/Right - Turn[/center]\n" + \
		"[center]Space - Drift[/center]\n" + \
		"[center]Left Click - Shoot[/center]\n" + \
		"[center]Shift - Boost[/center]\n" + \
		"[center]E - Shield[/center]\n" + \
		"[center]Q/R - Ascend/Descend[/center]\n\n" + \
		"[center]Race through floating islands, battle opponents,[/center]\n" + \
		"[center]and become the ultimate Sky Forge Rider![/center]"
	
	# Connect signals
	start_button.pressed.connect(_on_start_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_close_pressed():
	get_tree().quit()