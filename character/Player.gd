extends KinematicBody2D

signal killed()

const MOVE_SPEED = 16.0 * 16
const HOOK_SPEED = 32.0 * 16
const HOOK_ROTATION_SPEED = -PI * 1.5
const MIN_HOOK_DISTANCE = 1.0 * 16

onready var body = $Body
onready var collision = $CollisionShape2D
onready var mouth = $Body/Mouth
onready var state_machine = $StateMachine
onready var animation_player = $AnimationPlayer
onready var destruction_area = $DestructionArea

onready var jump_velocity = PhysicsHelper.calculate_velocity_from_height(-Globals.PLAYER_JUMP_HEIGHT)
var velocity := Vector2()
var is_grounded := false
var is_licking := false
var move_input
var tongue = null
var rotation_factor = 0.2
var rotation_direction = 1
var retraction_speed = 1.0 * 16
var facing = 1
var is_alive = true

func _update_input():
	move_input = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
	if move_input != 0:
		facing = sign(move_input)
		body.scale.x = facing

func _update_h_velocity():
	velocity.x = lerp(velocity.x, move_input * MOVE_SPEED, get_move_weight())

func _update_hooked_velocity():
	match tongue.get_anchor().type:
		Anchor.Types.MERRY:
			_update_merry_go_frog_velocity()
		Anchor.Types.PULL:
			_update_hook_retract_velocity()

func _update_merry_go_frog_velocity():
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
	if is_alive && global_position.y > 250:
		is_alive = false
		emit_signal("killed")

func _handle_destruction():
	var areas = destruction_area.get_overlapping_areas()
	for area in areas:
		if area is DestructableArea:
			area.on_collision(self, velocity)

func get_move_weight():
	if is_grounded:
		return 0.2
	else:
		if move_input == 0:
			return 0.02
		elif move_input == sign(velocity.x) && abs(velocity.x) > MOVE_SPEED:
			return 0.0
		else:
			return 0.1

func jump():
	velocity.y = jump_velocity

func lick():
	if !is_licking:
		tongue = preload("res://character/Tongue.tscn").instance()
		mouth.add_child(tongue)
		tongue.launch((get_global_mouse_position() - mouth.global_position).normalized())
		set_is_licking(true)
		tongue.connect("retracted", self, "_on_tongue_retracted")
		tongue.connect("hooked", state_machine, "_on_Player_hooked")
		tongue.connect("hooked", self, "_on_tongue_hooked")

func _on_tongue_retracted():
	tongue = null
	set_is_licking(false)

func remove_tongue():
	if tongue != null:
		tongue.queue_free()
		tongue = null
		set_is_licking(false)

func _on_tongue_hooked():
	var body = tongue.raycast.get_collider()
#	if body is Anchor:
#		var displacement = body.global_position - mouth.global_position
		
	pass

func set_is_licking(value):
	is_licking = value
	state_machine.update_animation()
#	if value: 
#		Engine.time_scale = 0.1
#	else:
#		Engine.time_scale = 1.0

func should_release() -> bool:
	if tongue.get_anchor().type == Anchor.Types.PULL:
		return true if tongue.get_length() < 2 * 16 else false
	else:
		return false
