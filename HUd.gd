extends CanvasLayer

@onready var score_label = $Control/HealthBar
@onready var health_bar = $Control/ScoreLabel
func _ready():
	update_score(100)
	update_health(75)

func update_score(new_score: int):
	score_label.text = "Score: " + str(new_score)

func update_health(new_health: int):
	health_bar.value = new_health
