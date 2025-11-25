extends Control

@onready var bike_list: ItemList = $VBoxContainer/BikeList
@onready var skin_list: ItemList = $VBoxContainer/SkinList
@onready var trail_list: ItemList = $VBoxContainer/TrailList
@onready var preview_mesh: MeshInstance3D = $PreviewContainer/PreviewMesh
@onready var apply_button: Button = $VBoxContainer/ApplyButton
@onready var back_button: Button = $VBoxContainer/BackButton

var bikes: Array[String] = ["Standard", "Lightweight", "Heavy", "Experimental"]
var skins: Array[String] = ["Neon Blue", "Carbon Fiber", "Fire", "Frost", "Thunder"]
var trails: Array[String] = ["Plasma", "Lightning", "Smoke", "Rainbow"]

var selected_bike: String = ""
var selected_skin: String = ""
var selected_trail: String = ""

func _ready():
	# Populate lists
	populate_list(bike_list, bikes, Global.unlocked_bikes)
	populate_list(skin_list, skins, Global.unlocked_skins)
	populate_list(trail_list, trails, Global.unlocked_trails)
	
	# Connect signals
	bike_list.item_selected.connect(_on_bike_selected)
	skin_list.item_selected.connect(_on_skin_selected)
	trail_list.item_selected.connect(_on_trail_selected)
	apply_button.pressed.connect(_on_apply_pressed)
	back_button.pressed.connect(_on_back_pressed)

func populate_list(list: ItemList, items: Array[String], unlocked: Array[String]):
	for item in items:
		var index = list.add_item(item)
		if item not in unlocked:
			list.set_item_disabled(index, true)
			list.set_item_text(index, item + " (LOCKED)")

func _on_bike_selected(index: int):
	if index < bikes.size() and bikes[index] in Global.unlocked_bikes:
		selected_bike = bikes[index]
		update_preview()

func _on_skin_selected(index: int):
	if index < skins.size() and skins[index] in Global.unlocked_skins:
		selected_skin = skins[index]
		update_preview()

func _on_trail_selected(index: int):
	if index < trails.size() and trails[index] in Global.unlocked_trails:
		selected_trail = trails[index]

func update_preview():
	# Update preview mesh based on selection
	if selected_bike != "":
		# Load and display bike model
		var bike_scene = load("res://assets/bikes/%s.tscn" % selected_bike.to_lower())
		if bike_scene:
			var bike_instance = bike_scene.instantiate()
			preview_mesh.mesh = bike_instance.get_node("MeshInstance3D").mesh

func _on_apply_pressed():
	if selected_bike != "" and selected_skin != "" and selected_trail != "":
		Global.player_bike_model = selected_bike.to_lower()
		Global.player_bike_skin = selected_skin.to_lower().replace(" ", "_")
		Global.player_trail = selected_trail.to_lower()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")