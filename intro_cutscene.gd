extends Control

@export_file("*.tscn") var next_scene: String = "res://scenes/main.tscn" # Ganti ke scene selanjutnya
@export var typing_speed: float = 0.035

@onready var speaker_label: Label = $DialogueBox/Margin/VBox/SpeakerName
@onready var dialogue_label: RichTextLabel = $DialogueBox/Margin/VBox/DialogueText
@onready var next_indicator: Label = $DialogueBox/Margin/VBox/NextIndicator
@onready var skip_button: Button = $SkipButton
@onready var fade_rect: ColorRect = $FadeOverlay

# Format: { "speaker": "Nama", "text": "Dialog" }
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
		"speaker": "Asa",
		"text": "Hei! Kamu murid baru, ya? Kelihatannya lagi bingung nyari kelas."
	},
	{
		"speaker": "Asa",
		"text": "Kenalin, aku Asa! Ayo ikut aku, biar kutunjukin arahnya."
	}
]

var current_line_index: int = 0
var is_typing: bool = false
var is_transitioning: bool = false
var typing_tween: Tween

func _ready() -> void:
	fade_rect.color = Color(0, 0, 0, 1)
	next_indicator.visible = false
	skip_button.pressed.connect(_on_skip_pressed)
	
	# Fade in dari layar hitam
	var fade_in = create_tween()
	fade_in.tween_property(fade_rect, "color:a", 0.0, 1.0)
	await fade_in.finished
	
	_show_line(current_line_index)

func _show_line(index: int) -> void:
	if index >= story_lines.size():
		_finish_cutscene()
		return

	var line = story_lines[index]
	speaker_label.text = line["speaker"]
	
	# Ubah warna nama pembicara biar jelas bedanya
	if line["speaker"] == "Asa":
		speaker_label.add_theme_color_override("font_color", Color(0.45, 0.92, 0.72, 1.0))
	else:
		speaker_label.add_theme_color_override("font_color", Color(0.55, 0.8, 1.0, 1.0))

	is_typing = true
	next_indicator.visible = false
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
	next_indicator.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if is_transitioning:
		return

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
	fade_out.tween_property(fade_rect, "color:a", 1.0, 0.8)
	await fade_out.finished

	if next_scene and ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file(next_scene)
	else:
		print("Cutscene selesai! Set 'next_scene' di Inspector untuk pindah ke scene selanjutnya.")
