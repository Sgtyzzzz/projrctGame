extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 5.0
@export var mouse_sensitivity = 0.003

var gravity = 9.8

# View Bobbing
var bob_time = 0.0
var bob_speed = 10.0
var bob_amount = 0.05

# Kamera
var third_person = false

@onready var first_person_camera: Camera3D = $"FirstPersonCamera"
@onready var third_person_camera: Camera3D = $"ThirdPersonCamera"
@onready var flashlight: SpotLight3D = $"FirstPersonCamera/Flashlight"

var camera_start_position: Vector3


func _ready():

	if first_person_camera == null:
		print("FirstPersonCamera tidak ditemukan!")
		return

	if third_person_camera == null:
		print("ThirdPersonCamera tidak ditemukan!")
		return

	first_person_camera.current = true
	third_person_camera.current = false

	# Kunci kursor mouse di tengah layar untuk kontrol kamera 3D
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	camera_start_position = first_person_camera.position

	if flashlight != null:
		flashlight.visible = true


func _physics_process(delta):

	# Gravitasi
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Lompat (Bisa pakai 'jump' atau tombol Space/'ui_accept')
	if (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("ui_accept")) and is_on_floor():
		velocity.y = jump_velocity

	# Gerak (Mendukung Input Map kustom & Input Map bawaan WASD/Panah Godot)
	var input_dir = Input.get_vector(
		"move_left" if InputMap.has_action("move_left") else "ui_left",
		"move_right" if InputMap.has_action("move_right") else "ui_right",
		"move_forward" if InputMap.has_action("move_forward") else "ui_up",
		"move_backward" if InputMap.has_action("move_backward") else "ui_down"
	)

	var direction = (
		transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	if direction:

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		if not third_person:

			bob_time += delta * bob_speed

			first_person_camera.position.y = (
				camera_start_position.y
				+ sin(bob_time) * bob_amount
			)

	else:

		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func _unhandled_input(event):

	# Rotasi kamera dengan pergerakan mouse
	if event is InputEventMouseMotion:

		rotate_y(-event.relative.x * mouse_sensitivity)

		first_person_camera.rotate_x(
			-event.relative.y * mouse_sensitivity
		)

	# Ganti kamera (Orang Pertama <-> Orang Ketiga)
	if InputMap.has_action("change_camera") and Input.is_action_just_pressed("change_camera"):

		third_person = !third_person

		first_person_camera.current = !third_person
		third_person_camera.current = third_person

	# Toggle Flashlight / Senter
	if InputMap.has_action("toggle_flashlight") and Input.is_action_just_pressed("toggle_flashlight"):

		if flashlight != null:
			flashlight.visible = !flashlight.visible
