extends Control

@onready var track_list: ItemList = $VBoxContainer/TrackList
@onready var start_race_button: Button = $VBoxContainer/StartRaceButton
@onready var back_button: Button = $VBoxContainer/BackButton

var tracks: Array[String] = [
	"Azure Archipelago",
	"Ember Rift", 
	"Frostlight Peaks",
	"Neo-Sky Metropolis",
	"Celestial Garden"
]
var selected_track: String = ""

func _ready():
	# Populate track list
	for track in tracks:
		track_list.add_item(track)
	
	# Connect signals
	track_list.item_selected.connect(_on_track_selected)
	start_race_button.pressed.connect(_on_start_race_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_track_selected(index: int):
	selected_track = tracks[index]
	start_race_button.disabled = false

func _on_start_race_pressed():
	if selected_track != "":
		Global.reset_race()
		# Load selected track
		var track_scene = "res://scenes/tracks/%s.tscn" % selected_track.to_lower().replace(" ", "_")
		get_tree().change_scene_to_file(track_scene)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")