extends KinematicBody2D

const MOVE_SPEED = 10.0 * 16
const HOOK_SPEED = 32.0 * 16
const HOOK_ROTATION_SPEED = -PI * 1.5
const MIN_HOOK_DISTANCE = 1.0 * 16

onready var body = $Body
onready var collision = $CollisionShape2D
onready var mouth = $Mouth
onready var state_machine = $StateMachine

onready var jump_velocity = PhysicsHelper.calculate_velocity_from_height(-Globals.PLAYER_JUMP_HEIGHT)
var velocity := Vector2()
var is_grounded := false
var can_lick := true
var move_input
var tongue = null
var rotation_factor = 0.2
var rotation_direction = 1
var retraction_speed = 1.0 * 16
	

func _update_input():
	move_input = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")

func _update_h_velocity():
	velocity.x = lerp(velocity.x, move_input * MOVE_SPEED, get_move_weight())

func _update_hooked_velocity():
	var delta = get_physics_process_delta_time()
	var displacement = tongue.tip.global_position - mouth.global_position
	var angle = displacement.angle()
	var rotation_modifier = max(tongue.MAX_LENGTH / tongue.get_length(), 1.0)
	var rotation_speed = HOOK_ROTATION_SPEED
	var desired_angle = angle + HOOK_ROTATION_SPEED * rotation_modifier * tongue.get_anchor().direction * delta
	var retraction_delta = -retraction_speed * delta if displacement.length() > MIN_HOOK_DISTANCE else 0
	var desired_position = tongue.tip.global_position - polar2cartesian(displacement.length() \
			+ retraction_delta, desired_angle)
	velocity = (desired_position - mouth.global_position) / delta
	

func _update_hook_retract_velocity():
	var delta = get_physics_process_delta_time()
	var displacement = tongue.tip.global_position - mouth.global_position
	var desired_velocity = displacement.normalized() * HOOK_SPEED
	if desired_velocity.length() * delta >= displacement.length():
		desired_velocity = displacement / delta
	velocity = desired_velocity

func _apply_gravity():
	velocity.y += Globals.gravity * get_physics_process_delta_time()

func _apply_movement():
	var snap = Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true)
	is_grounded = is_on_floor()

func get_move_weight():
	return 0.3 if is_grounded else 0.05

func jump():
	velocity.y = jump_velocity

func lick():
	if can_lick:
		tongue = preload("res://character/Tongue.tscn").instance()
		add_child(tongue)
		tongue.position = mouth.position
		tongue.launch((get_global_mouse_position() - mouth.global_position).normalized())
		can_lick = false
		tongue.connect("retracted", self, "_on_tongue_retracted")
		tongue.connect("hooked", state_machine, "_on_Player_hooked")
		tongue.connect("hooked", self, "_on_tongue_hooked")

func _on_tongue_retracted():
	tongue = null
	can_lick = true

func remove_tongue():
	if tongue != null:
		tongue.queue_free()
		tongue = null
		can_lick = true

func _on_tongue_hooked():
	var body = tongue.raycast.get_collider()
#	if body is Anchor:
#		var displacement = body.global_position - mouth.global_position
		
	pass
