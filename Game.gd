extends Node2D

const LEVELS = [
	preload("res://world/level/levels/BreakingFree.tscn"),
	preload("res://world/level/levels/Victory.tscn"),
]

onready var transition_animator = $HUDLayer/Interface/TransitionEffects/TransitionAnimator

var level = null
var level_idx = 0

func _ready():
	Globals.game = self
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
