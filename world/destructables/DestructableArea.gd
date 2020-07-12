extends Area2D
class_name DestructableArea

signal broken()

export var break_resistance = 1

var is_broken = false

func on_collision(body, velocity):
	if !is_broken && velocity.length() > break_resistance * 64:
		is_broken = true
		emit_signal("broken")
