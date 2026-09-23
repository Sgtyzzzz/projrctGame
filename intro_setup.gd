extends Control

@onready var dialogue = $Dialogue

func _ready():
	# Jalankan dialog Asa otomatis saat scene dibuka
	dialogue.start()

func _process(_delta):
	# Jika dialog selesai dan nama pemain sudah terisi, lanjut ke game utama
	if not dialogue.d_active and Global.player_name != "Pemain":
		get_tree().change_scene_to_file("res://world.tscn") # Sesuaikan nama scene game kamu
