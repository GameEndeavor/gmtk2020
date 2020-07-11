extends KinematicBody2D

const MOVE_SPEED = 10.0 * 16

onready var body = $Body
onready var collision = $CollisionShape2D

onready var jump_velocity = PhysicsHelper.calculate_velocity_from_height(-Globals.PLAYER_JUMP_HEIGHT)
var velocity := Vector2()
var is_grounded := false
var can_lick := true

func _unhandled_input(event):
	if event.is_action_pressed("jump") && is_grounded:
		jump()
	if event.is_action_pressed("lick"):
		lick()

func _physics_process(delta):
	var move_input = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
	velocity.x = move_input * MOVE_SPEED
	
	velocity.y += Globals.gravity * delta
	var snap = Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true)
	is_grounded = is_on_floor()

func jump():
	velocity.y = jump_velocity

func lick():
	if can_lick:
		var tongue = preload("res://character/Tongue.tscn").instance()
		add_child(tongue)
		tongue.position = collision.position
		tongue.launch((get_global_mouse_position() - global_position).normalized())
		can_lick = false
		tongue.connect("retracted", self, "set", ["can_lick", true])
