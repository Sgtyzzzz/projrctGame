extends Node2D

@onready var button_manager: Control = find_child("Control", true, false) as Control

func _ready() -> void:
	# Jika tidak ketemu node "Control", cari node "button manager"
	if not button_manager:
		button_manager = find_child("button manager", true, false) as Control
		
	if button_manager:
		for button in button_manager.find_children("*", "BaseButton", true, false):
			if button is BaseButton:
				button.pressed.connect(_on_button_pressed.bind(button.name))

func _on_button_pressed(button_name: String) -> void:
	if button_name.to_lower() == "back":
		get_tree().change_scene_to_file("res://main_menu.tscn")
