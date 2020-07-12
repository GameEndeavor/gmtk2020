extends Node2D

func destroy():
	queue_free()


func _on_DestructableArea_broken():
	destroy()
