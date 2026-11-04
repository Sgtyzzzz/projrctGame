extends PathFollow3D

@export var speed: float = 2.0
var moving_forward: bool = true

func _process(delta: float):
	if moving_forward:
		progress += speed * delta
		if progress_ratio >= 1.0:
			moving_forward = false
	else:
		progress -= speed * delta
		if progress_ratio <= 0.0:
			moving_forward = true
