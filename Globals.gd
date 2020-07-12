extends Node

signal score_updated(value)

const UNIT_SIZE = 16
const PLAYER_JUMP_HEIGHT = -3.75 * UNIT_SIZE
const PLAYER_JUMP_DURATION = 0.35

var gravity = null
var player = null
var game = null
var level = null
var time = 0
var level_idx = 0
var score = 0 setget set_score

func _ready():
	gravity = -2 * PLAYER_JUMP_HEIGHT / pow(PLAYER_JUMP_DURATION, 2)

func _process(delta):
	time += delta

func set_score(value):
	score = value
	emit_signal("score_updated")
