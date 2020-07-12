extends Camera2D

var camera_speed = 4 * 16

func _physics_process(delta):
	position.x += camera_speed * delta
