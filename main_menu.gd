extends Node2D

@onready var button_manager: Control = find_child("button manager", true, false) as Control
@onready var music_player: AudioStreamPlayer = find_child("MusicPlayer", true, false) as AudioStreamPlayer

# Pastikan nama file di bawah ini SAMA PERSIS dengan yang ada di panel FileSystem
var click_sfx: AudioStream = preload("res://sound/Click Sound Effect.wav")

func _ready() -> void:
	if music_player and not music_player.playing:
		music_player.play()
	
	if button_manager:
		for button in button_manager.find_children("*", "BaseButton", true, false):
			if button is BaseButton:
				button.pressed.connect(_on_button_pressed.bind(button.name))

func _on_button_pressed(button_name: String) -> void:
	_play_click_sound()

	match button_name.to_lower():
		"start":
			get_tree().change_scene_to_file("res://game.tscn")
		"options":
			get_tree().change_scene_to_file("res://options.tscn")
		"credit":
			get_tree().change_scene_to_file("res://credit.tscn")
		"back":
			get_tree().change_scene_to_file("res://main_menu.tscn")
		"quit":
			get_tree().quit()

func _play_click_sound() -> void:
	if click_sfx:
		var temp_player = AudioStreamPlayer.new()
		temp_player.stream = click_sfx
		get_tree().root.add_child(temp_player)
		
		# Memutar dari titik 2.29 detik
		temp_player.play(2.29)
		
		temp_player.finished.connect(temp_player.queue_free)
