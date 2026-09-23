extends Node2D

@onready var button_manager: Control = find_child("Control", true, false) as Control

# Preload efek suara klik
var click_sfx: AudioStream = preload("res://sound/Click Sound Effect.wav")

func _ready() -> void:
	if not button_manager:
		button_manager = find_child("button manager", true, false) as Control
		
	# Connect semua tombol
	if button_manager:
		for button in button_manager.find_children("*", "BaseButton", true, false):
			if button is BaseButton:
				button.pressed.connect(_on_button_pressed.bind(button.name))

	# 1. Slider Musik (Sesuai nama "VolumeSlide" di scene kamu)
	var music_slider = find_child("VolumeSlide", true, false) as HSlider
	if music_slider:
		music_slider.value = db_to_linear(GlobalMusic.audio_player.volume_db)
		music_slider.value_changed.connect(_on_volume_slider_value_changed)

	# 2. Slider SFX (Sesuai nama "SfxSlider" di scene kamu)
	var sfx_slider = find_child("SfxSlider", true, false) as HSlider
	if sfx_slider:
		sfx_slider.value = db_to_linear(GlobalMusic.sfx_player.volume_db)
		sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)

func _on_button_pressed(button_name: String) -> void:
	# Bunyi klik tombol biasa
	_play_click_sound()

	var btn_name = button_name.to_lower()
	
	# Navigasi Back
	if btn_name == "back":
		get_tree().change_scene_to_file("res://main_menu.tscn")
	
	# Tes Musik (Node: Play / Stop)
	elif btn_name == "play":
		GlobalMusic.play_music()
	elif btn_name == "stop":
		GlobalMusic.stop_music()
		
	# Tes SFX (Node: PlaySFX / StopSFX)
	elif btn_name == "playsfx":
		_play_click_sound()
	elif btn_name == "stopsfx":
		GlobalMusic.sfx_player.stop()

# Volume Musik
func _on_volume_slider_value_changed(value: float) -> void:
	GlobalMusic.set_volume(value)

# Volume SFX
func _on_sfx_slider_value_changed(value: float) -> void:
	GlobalMusic.set_sfx_volume(value)

# Pemutar SFX Klik
func _play_click_sound() -> void:
	if click_sfx:
		GlobalMusic.play_sfx(click_sfx, 2.29)
