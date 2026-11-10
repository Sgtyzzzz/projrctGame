extends Control

@export var scroll_speed: float = 60.0 # Kecepatan auto-scroll (pixel per detik)
@export_file("*.tscn") var main_menu_scene: String = "res://scenes/main_menu.tscn"

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var v_scrollbar: VScrollBar = scroll_container.get_v_scroll_bar()

var current_scroll: float = 0.0
var is_finished: bool = false

func _ready() -> void:
	scroll_container.scroll_vertical = 0

func _process(delta: float) -> void:
	if is_finished:
		return

	# Sinkronkan dengan posisi scroll saat ini (agar tetap mulus jika user scroll manual)
	current_scroll = max(current_scroll, float(scroll_container.scroll_vertical))
	current_scroll += scroll_speed * delta
	scroll_container.scroll_vertical = int(current_scroll)

	# Cek jika sudah sampai paling bawah
	if v_scrollbar.max_value > scroll_container.size.y:
		if scroll_container.scroll_vertical >= v_scrollbar.max_value - scroll_container.size.y:
			_finish_credits()

func _unhandled_input(event: InputEvent) -> void:
	# Tekan ESC atau Spasi/Enter untuk skip credits
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		_finish_credits()

func _finish_credits() -> void:
	if is_finished:
		return
	is_finished = true

	if main_menu_scene and ResourceLoader.exists(main_menu_scene):
		get_tree().change_scene_to_file(main_menu_scene)
	else:
		get_tree().quit()
