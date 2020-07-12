extends Node2D

const LEVELS = [
	preload("res://world/RunnerLevel.tscn"),
#	preload("res://world/level/levels/BreakingFree.tscn"),
#	preload("res://world/level/levels/Victory.tscn"),
]

onready var transition_animator = $HUDLayer/Interface/TransitionEffects/TransitionAnimator
onready var hud = $HUDLayer

var level = null
var level_idx = 0

func _ready():
	randomize()
	Globals.game = self
	Globals.connect("score_updated", hud, "update_score")
	load_level(0)

func next_level():
	var idx = level_idx + 1
	if idx < LEVELS.size():
		load_level(idx)

func load_level(idx):
	transition_animator.play("fade_black")
	yield(transition_animator, "animation_finished")
	
	if Globals.level != null:
		Globals.level.queue_free()
		yield(get_tree(), "physics_frame")
	
	Globals.level = LEVELS[idx].instance()
	level_idx = idx
	add_child(Globals.level)
	
	transition_animator.play_backwards("fade_black")
	yield(transition_animator, "animation_finished")

func restart():
	load_level(0)
	Globals.score = 0
	hud.update_score(0)
