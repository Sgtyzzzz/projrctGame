extends Control

@export_file("*.tscn") var next_scene: String = "res://game.tscn" # Mengarahkan ke game.tscn untuk sesi tanya nama oleh Asa
@export var typing_speed: float = 0.035

# Menyesuaikan dengan node struktur gaya dialogue.tscn
@onready var speaker_label: RichTextLabel = $NinePatchRect/Name
@onready var dialogue_label: RichTextLabel = $NinePatchRect/Chat
@onready var skip_button: Button = $SkipButton
@onready var fade_rect: ColorRect = $FadeOverlay

# Daftar dialog urut dari monolog bingung sampai ketemu Asa
var story_lines: Array[Dictionary] = [
	{
		"speaker": "Siswa Baru (Kamu)",
		"text": "Hari pertama masuk SMK..."
	},
	{
		"speaker": "Siswa Baru (Kamu)",
		"text": "Semuanya terasa begitu asing. Lorong sekolah yang ramai, seragam baru, dan wajah-wajah yang belum kukenal."
	},
	{
		"speaker": "Siswa Baru (Kamu)",
		"text": "Jujur, aku masih agak bingung harus mulai dari mana... Semoga saja aku bisa dapat teman di sini."
	},
	{
		"speaker": "Siswa Baru (Kamu)",
		"text": "eh... kaya ada yang manggil?"
	},
	{
		"speaker": "???",
		"text": "heyy kamu yang disana!"
	}
]

var current_line_index: int = 0
var is_typing: bool = false
var is_transitioning: bool = false
var typing_tween: Tween

func _ready() -> void:
	if fade_rect:
		fade_rect.color = Color(0, 0, 0, 1)
		var fade_in = create_tween()
		fade_in.tween_property(fade_rect, "color:a", 0.0, 1.0)
		await fade_in.finished
	
	if skip_button and not skip_button.pressed.is_connected(_on_skip_pressed):
		skip_button.pressed.connect(_on_skip_pressed)
		
	_show_line(current_line_index)

func _show_line(index: int) -> void:
	if index >= story_lines.size():
		_finish_cutscene()
		return

	var line = story_lines[index]
	speaker_label.text = line["speaker"]
	
	# Warna pembeda nama pembicara (Asa hijau mint, Kamu biru)
	if line["speaker"] == "Asa":
		speaker_label.add_theme_color_override("default_color", Color(0.45, 0.92, 0.72, 1.0))
	else:
		speaker_label.add_theme_color_override("default_color", Color(0.55, 0.8, 1.0, 1.0))

	is_typing = true
	dialogue_label.text = line["text"]
	dialogue_label.visible_ratio = 0.0

	if typing_tween:
		typing_tween.kill()

	var duration = line["text"].length() * typing_speed
	typing_tween = create_tween()
	typing_tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)
	typing_tween.finished.connect(_on_typing_finished)

func _on_typing_finished() -> void:
	is_typing = false

func _unhandled_input(event: InputEvent) -> void:
	if is_transitioning:
		return

	# Klik kiri atau Spasi/Enter untuk mempercepat teks atau lanjut ke baris berikutnya
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if is_typing:
			if typing_tween:
				typing_tween.kill()
			dialogue_label.visible_ratio = 1.0
			_on_typing_finished()
		else:
			current_line_index += 1
			_show_line(current_line_index)

func _on_skip_pressed() -> void:
	_finish_cutscene()

func _finish_cutscene() -> void:
	if is_transitioning:
		return
	is_transitioning = true

	var fade_out = create_tween()
	if fade_rect:
		fade_out.tween_property(fade_rect, "color:a", 1.0, 0.8)
		await fade_out.finished

	if next_scene and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		print("Cutscene selesai, tetapi file next_scene tidak ditemukan!")
