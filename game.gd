extends Node2D

# Memanggil node tombol back berdasarkan hierarchy di gambar
@onready var back_button: Button = $Control/back

# Memanggil node Dialogue yang ada di dalam IntroSetup
@onready var dialogue = $IntroSetup/Dialogue

func _ready() -> void:
	# 1. Hubungkan signal tombol Back
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	# 2. Jalankan dialog otomatis saat scene game dimuat
	if dialogue:
		dialogue.start()

func _process(_delta: float) -> void:
	# 3. Cek apakah dialog sudah selesai dan nama pemain sudah terisi
	if dialogue and not dialogue.d_active and Global.player_name != "Pemain":
		# Pindah ke scene permainan utama
		get_tree().change_scene_to_file("res://world.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
