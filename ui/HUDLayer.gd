extends CanvasLayer

const SCORE_TEXT = "SCORE: %s"

onready var score_label = $Interface/ScoreLabel

func update_score(value):
	score_label.text = SCORE_TEXT % value
