extends Camera2D

const MAX_CAMERA_SPEED = 12 * 16
const CAMERA_SPEED_DELTA = 0.25 * 16

var camera_speed = 4 * 16

func _physics_process(delta):
	position.x += camera_speed * delta
	camera_speed = min(camera_speed + CAMERA_SPEED_DELTA * delta, MAX_CAMERA_SPEED)
