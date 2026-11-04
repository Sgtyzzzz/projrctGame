extends Node3D

@export_file("*.json") var dialogue_file: String
var player_in_range: bool = false

@onready var area_3d: Area3D = $Area3D

func _ready():
	area_3d.body_entered.connect(_on_body_entered)
	area_3d.body_exited.connect(_on_body_exited)

func _unhandled_input(event):
	if player_in_range and (event.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_E)):
		start_dialogue()

func _on_body_entered(body):
	if body is CharacterBody3D:
		player_in_range = true
		print("Pemain mendekati guru, tekan E / Enter")

func _on_body_exited(body):
	if body is CharacterBody3D:
		player_in_range = false

func start_dialogue():
	# Memanggil UI Dialogue di scene
	var dialogue_ui = get_node_or_null("../Dialogue")
	if dialogue_ui:
		if dialogue_file != "":
			dialogue_ui.d_file = dialogue_file
		dialogue_ui.visible = true
		dialogue_ui.start()
