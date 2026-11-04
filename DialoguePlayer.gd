extends CanvasLayer

# Path file JSON dialog yang di-export di Inspector
@export_file("*.json") var d_file: String

# Variabel sistem dialog
var dialogue = []
var current_dialogue_id = -1
var d_active = false
var waiting_for_input = false

# Node references sesuai hierarki scene
@onready var nine_patch_rect = $NinePatchRect
@onready var png_player = $PngPlayer
@onready var name_label = $NinePatchRect/Name
@onready var chat_label = $NinePatchRect/Chat
@onready var name_input = $NinePatchRect/NameInput
@onready var timer = $Timer

# Tween untuk menampung animasi ngetik
var text_tween: Tween

func _ready():
	d_active = false
	waiting_for_input = false
	current_dialogue_id = -1
	
	hide_dialogue_ui()
	
	if not name_input.text_submitted.is_connected(_on_name_submitted):
		name_input.text_submitted.connect(_on_name_submitted)
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

func hide_dialogue_ui():
	nine_patch_rect.visible = false
	png_player.visible = false
	name_input.visible = false

func start():
	if d_active:
		return
		
	d_active = true
	nine_patch_rect.visible = true
	png_player.visible = true
	
	animate_popup()
	
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()

func animate_popup():
	nine_patch_rect.scale = Vector2.ZERO
	png_player.scale = Vector2.ZERO
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(nine_patch_rect, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	tween.tween_property(png_player, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

func load_dialogue():
	if FileAccess.file_exists(d_file):
		var file = FileAccess.open(d_file, FileAccess.READ)
		var content = file.get_as_text()
		return JSON.parse_string(content)
	return []

func _input(event):
	if not d_active or waiting_for_input:
		return
	
	if event.is_action_pressed("ui_accept"):
		if text_tween and text_tween.is_running():
			text_tween.kill()
			chat_label.visible_characters = -1
		else:
			next_script()

func next_script():
	current_dialogue_id += 1
	
	# Jika dialog selesai
	if current_dialogue_id >= dialogue.size():
		timer.start()
		hide_dialogue_ui()
		return
	
	var current_data = dialogue[current_dialogue_id]
	
	name_label.text = current_data["name"]
	
	var text_content = current_data["text"]
	text_content = text_content.replace("[PLAYER]", Global.player_name)
	
	animate_text(text_content)
	
	if current_data.has("ask_name") and current_data["ask_name"] == true:
		show_name_input()

func animate_text(full_text: String):
	chat_label.text = full_text
	chat_label.visible_characters = 0
	
	if text_tween:
		text_tween.kill()
		
	text_tween = create_tween()
	var duration = full_text.length() * 0.03
	text_tween.tween_property(chat_label, "visible_characters", full_text.length(), duration)

func show_name_input():
	waiting_for_input = true
	name_input.text = ""
	name_input.visible = true
	name_input.grab_focus()

func _on_name_submitted(new_text: String):
	if new_text.strip_edges() != "":
		Global.player_name = new_text.strip_edges()
	else:
		Global.player_name = "Pemain"
	
	name_input.visible = false
	waiting_for_input = false
	next_script()

func _on_timer_timeout():
	d_active = false
	hide_dialogue_ui()
	
	# JIKA DIALOG INI ADALAH DIALOG INTRO/KENALAN DI SCENE LUAR, PINDAH KE SCENE UTAMA
	# Jika scene saat ini BUKAN node_3d, maka pindah ke node_3d.tscn
	if get_tree().current_scene.name != "Node3D":
		get_tree().change_scene_to_file("res://node_3d.tscn")
