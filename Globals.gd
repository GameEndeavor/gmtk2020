extends Node

const UNIT_SIZE = 16
const PLAYER_JUMP_HEIGHT = -3.75 * UNIT_SIZE
const PLAYER_JUMP_DURATION = 0.35


var gravity = null
var player = null
var game = null
var level = null
var time = 0
var level_idx = 0

func _ready():
	gravity = -2 * PLAYER_JUMP_HEIGHT / pow(PLAYER_JUMP_DURATION, 2)

func _process(delta):
	time += delta
