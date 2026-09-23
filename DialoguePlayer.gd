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
	# Sembunyikan elemen UI saat game baru mulai
	nine_patch_rect.visible = false
	png_player.visible = false
	name_input.visible = false
	
	# Hubungkan signal
	name_input.text_submitted.connect(_on_name_submitted)
	timer.timeout.connect(_on_timer_timeout)

func start():
	if d_active:
		return
		
	d_active = true
	nine_patch_rect.visible = true
	png_player.visible = true
	
	# Jalankan animasi tuing (pop-up) untuk box dan gambar bersamaan
	animate_popup()
	
	dialogue = load_dialogue()
	current_dialogue_id = -1
	next_script()

# Animasi pop-up tuing untuk Box Dialog dan PngPlayer bersamaan
func animate_popup():
	nine_patch_rect.scale = Vector2.ZERO
	png_player.scale = Vector2.ZERO
	
	# set_parallel(true) membuat kedua objek ter-animasi secara bersamaan
	var tween = create_tween().set_parallel(true)
	
	# Animasi Box Dialog
	tween.tween_property(nine_patch_rect, "scale", Vector2.ONE, 0.4)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
		
	# Animasi Gambar Asa
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
	# Jika dialog tidak aktif atau sedang menunggu input nama, abaikan
	if not d_active or waiting_for_input:
		return
	
	if event.is_action_pressed("ui_accept"):
		# Jika teks masih diketik, tekan Enter untuk langsung menyelesaikan teks (Skip)
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
		nine_patch_rect.visible = false
		png_player.visible = false
		return
	
	var current_data = dialogue[current_dialogue_id]
	
	# Tampilkan nama pembicara
	name_label.text = current_data["name"]
	
	# Ganti placeholder [PLAYER] dengan nama asli pemain
	var text_content = current_data["text"]
	text_content = text_content.replace("[PLAYER]", Global.player_name)
	
	# Jalankan animasi ketik teks
	animate_text(text_content)
	
	# Cek apakah baris ini meminta nama
	if current_data.has("ask_name") and current_data["ask_name"] == true:
		show_name_input()

# Animasi ketik karakter demi karakter
func animate_text(full_text: String):
	chat_label.text = full_text
	chat_label.visible_characters = 0
	
	if text_tween:
		text_tween.kill()
		
	text_tween = create_tween()
	var duration = full_text.length() * 0.03 # Kecepatan ngetik
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
