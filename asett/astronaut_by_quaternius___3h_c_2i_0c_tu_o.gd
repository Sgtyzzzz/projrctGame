extends Node3D

@export var speed: float = 3.0
@export var markers_folder: Node3D # Drag node 'Markers' ke inspector

var markers: Array = []
var current_marker_index: int = 0

func _ready() -> void:
	if markers_folder:
		markers = markers_folder.get_children()

func _process(delta: float) -> void:
	if markers.size() == 0:
		return
		
	var target_marker: Node3D = markers[current_marker_index]
	var target_position: Vector3 = target_marker.global_position
	
	# Hitung arah ke marker
	var direction: Vector3 = (target_position - global_position).normalized()
	
	# Gerakkan NPC ke arah marker
	global_position += direction * speed * delta
	
	# Buat NPC menghadap ke arah jalan (opsional)
	if direction.length() > 0:
		look_at(Vector3(target_position.x, global_position.y, target_position.z), Vector3.UP)
	
	# Jika sudah dekat dengan marker (jarak < 0.5 unit), ganti ke marker berikutnya
	if global_position.distance_to(target_position) < 0.5:
		current_marker_index = (current_marker_index + 1) % markers.size()
