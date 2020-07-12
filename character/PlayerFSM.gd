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
		states.hooked:
			if parent.should_release():
				return states.fall

func _enter_state(new_state, old_state):
	update_animation()

func _exit_state(old_state, new_state):
	match old_state:
		states.hooked:
			parent.remove_tongue()

func _on_Player_hooked():
	set_state(states.hooked)

func update_animation():
	var animation = ""
	if state == states.idle:
		if !parent.is_licking:
			animation = "idle"
		else:
			animation = "idle_bleb"
	elif state == states.run:
		if !parent.is_licking:
			animation = "run"
		else:
			animation = "run_bleb"
	elif [states.fall, states.jump].has(state):
		if !parent.is_licking:
			animation = "jump"
		else:
			animation = "jump_bleb"
	elif state == states.hooked:
		if parent.is_grounded:
			animation = "idle_bleb"
		else:
			animation = "jump_bleb"
	
	if animation != "" && parent.animation_player.assigned_animation != animation:
		parent.animation_player.play(animation)
