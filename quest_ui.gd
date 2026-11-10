extends CanvasLayer

@onready var quest_button: Button = $QuestToggleButton
@onready var quest_panel: Control = $QuestPanel
@onready var close_button: Button = $QuestPanel/MainCard/Margin/VBox/Header/CloseButton
@onready var claim_button: Button = $QuestPanel/MainCard/Margin/VBox/ClaimButton

func _ready() -> void:
	# Awalnya panel quest tertutup, hanya ikon kertas di pojok kiri atas yang muncul
	quest_panel.visible = false
	quest_button.visible = true

	quest_button.pressed.connect(_on_quest_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)
	claim_button.pressed.connect(_on_claim_button_pressed)

func _on_quest_button_pressed() -> void:
	quest_panel.visible = true
	quest_button.visible = false

func _on_close_button_pressed() -> void:
	quest_panel.visible = false
	quest_button.visible = true

func _on_claim_button_pressed() -> void:
	print("Hadiah Misi Sekolah diklaim!")
	# Tambahkan logika klaim hadiah (misal tambah poin/XP) di sini
