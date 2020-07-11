extends Node2D

signal retracted()

enum States {
	EXTEND, RETRACT, HOOK
}

const EXTEND_SPEED = 28 * 16
const RETRACT_SPEED = 32 * 16
const MAX_LENGTH = 8 * 16

onready var tip = $Tip
onready var line = $Tip/Line2D
onready var raycast = $RayCast2D

var velocity := Vector2()
var state = States.EXTEND

func _ready():
	tip.set_as_toplevel(true)

func _physics_process(delta):
	match state:
		States.EXTEND:
			extend()
		States.RETRACT:
			retract()
	line.set_point_position(1, line.to_local(global_position))

func extend():
	var delta = get_physics_process_delta_time()
	tip.position += velocity * delta
	if (tip.global_position - global_position).length() >= MAX_LENGTH:
		set_state(States.RETRACT)
	raycast.cast_to = (tip.global_position - global_position)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		set_state(States.RETRACT)

func retract():
	var delta = get_physics_process_delta_time()
	var displacement = global_position - tip.global_position
	var tip_velocity = displacement.normalized() * RETRACT_SPEED
	if tip_velocity.length() * delta > displacement.length():
		tip.global_position = global_position
		emit_signal("retracted")
		queue_free()
	tip.global_position += tip_velocity * delta

func launch(direction : Vector2):
	if !direction.is_normalized():
		push_error("direction.is_normalized() != true")
	
	velocity = direction * EXTEND_SPEED
	set_state(States.EXTEND)
	tip.global_position = global_position

func set_state(value):
	state = value
