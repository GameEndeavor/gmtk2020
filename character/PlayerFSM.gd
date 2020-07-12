extends StateMachine

const RUN_THRESHOLD = 8.0

func _ready():
	add_state("idle")
	add_state("run")
	add_state("hooked")
	add_state("jump")
	add_state("fall")
	call_deferred("set_state", states.idle)

func _unhandled_input(event):
	if event.is_action_pressed("jump"):
		if [states.idle, states.run].has(state):
			parent.jump()
		elif state == states.hooked:
			parent.remove_tongue()
			set_state(states.fall)
		
	if event.is_action_pressed("lick"):
		if [states.idle, states.run, states.jump, states.fall].has(state):
			parent.lick()

func _state_logic(delta):
	match state:
		states.idle, states.run, states.jump, states.fall:
			parent._update_input()
			parent._update_h_velocity()
			parent._apply_gravity()
			parent._apply_movement()
		states.hooked:
			parent._update_hooked_velocity()
#			parent._update_hook_retract_velocity()
			parent._apply_movement()

func _get_transition(delta):
	match state:
		states.idle:
			if parent.is_grounded:
				if abs(parent.velocity.x) >= RUN_THRESHOLD:
					return states.run
			else:
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
		states.run:
			if parent.is_grounded:
				if abs(parent.velocity.x) < RUN_THRESHOLD:
					return states.idle
			else:
				if parent.velocity.y < 0:
					return states.jump
				else:
					return states.fall
		states.jump:
			if parent.is_grounded:
				return states.idle
			else:
				if parent.velocity.y >= 0:
					return states.fall
		states.fall:
			if parent.is_grounded:
				return states.idle
			else:
				if parent.velocity.y < 0:
					return states.jump

func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass

func _on_Player_hooked():
	set_state(states.hooked)
