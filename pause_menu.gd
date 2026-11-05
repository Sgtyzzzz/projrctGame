extends Control

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func resume_game() -> void:
	get_tree().paused = false
	visible = false

func pause_game() -> void:
	visible = true
	get_tree().paused = true

# Fungsi sinyal tombol
func _on_resume_pressed() -> void:
	resume_game()

func _on_settings_pressed() -> void:
	print("Buka settings...")

func _on_save_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn") # sesuaikan path main menu kamu
