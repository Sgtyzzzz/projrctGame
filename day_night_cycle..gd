extends Node3D

@export var day_speed: float = 0.05

@export var texture_pagi: Texture2D = preload("res://pagi.png")
@export var texture_siang: Texture2D = preload("res://skybox-day.png")
@export var texture_malam: Texture2D = preload("res://skybox-night.png") # pastikan nama file sesuai

@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var world_env: WorldEnvironment = $WorldEnvironment

var time: float = 0.0
var current_sky_state: String = ""
var is_transitioning: bool = false

func _ready() -> void:
	# Cek & bikin environment otomatis biar gak crash kalau belum diset di inspector
	if world_env:
		if not world_env.environment:
			world_env.environment = Environment.new()
		
		var env = world_env.environment
		env.background_mode = Environment.BG_SKY
		
		if not env.sky:
			env.sky = Sky.new()
		if not env.sky.sky_material or not (env.sky.sky_material is PanoramaSkyMaterial):
			env.sky.sky_material = PanoramaSkyMaterial.new()

func _process(delta: float) -> void:
	time += delta * day_speed
	if time >= 1.0:
		time = 0.0

	if sun:
		var sun_rotation = time * TAU
		sun.rotation.x = sun_rotation - (PI / 2)

	check_and_update_sky()

func check_and_update_sky() -> void:
	var next_state: String = ""
	var selected_texture: Texture2D = null

	if time >= 0.0 and time < 0.2:
		next_state = "pagi"
		selected_texture = texture_pagi
	elif time >= 0.2 and time < 0.6:
		next_state = "siang"
		selected_texture = texture_siang
	else:
		next_state = "malam"
		selected_texture = texture_malam

	if next_state != current_sky_state and not is_transitioning:
		transition_to_texture(next_state, selected_texture)

func transition_to_texture(new_state: String, new_texture: Texture2D) -> void:
	if not world_env or not world_env.environment:
		return

	is_transitioning = true
	var env = world_env.environment

	var tween = create_tween()
	
	# 1. Redupkan langit
	tween.tween_property(env, "background_energy_multiplier", 0.0, 0.5)
	
	# 2. Ganti gambarnya
	tween.tween_callback(func():
		current_sky_state = new_state
		if env.sky and env.sky.sky_material is PanoramaSkyMaterial:
			env.sky.sky_material.panorama = new_texture
	)
	
	# 3. Terangkan kembali langit
	tween.tween_property(env, "background_energy_multiplier", 1.0, 0.5)
	
	# Selesai transisi
	tween.tween_callback(func():
		is_transitioning = false
	)
