extends KinematicBody2D

const MOVE_SPEED = 8.0 * 24

onready var jump_velocity = PhysicsHelper.calculate_velocity_from_height(-Globals.PLAYER_JUMP_HEIGHT)
var velocity := Vector2()
var is_grounded = false

func _unhandled_input(event):
	if event.is_action_pressed("jump") && is_grounded:
		jump()

func _physics_process(delta):
	var move_input = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
	velocity.x = move_input * MOVE_SPEED
	
	velocity.y += Globals.gravity * delta
	var snap = Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true)
	is_grounded = is_on_floor()

func jump():
	velocity.y = jump_velocity
