extends PlayerState


func enter(_msg : Dictionary = {}) -> void:
	player.current_speed = 0
	player.snap_vec = Vector3.DOWN
	player.velocity_vec = Vector3.ZERO
	
	if not player.is_locked and player.is_alive:
		if player.animation_tree.get("parameters/tpose/current") == 1:
			player.animation_tree.set("parameters/tpose/current",0)
			player.rpc("set_anim_bool","parameters/tpose/current",0)
		
		player.animation_tree.set("parameters/run_walk_timescale/scale",1)
		player.animation_tree.set("parameters/run/blend_position",Vector2(0,0))
		
		player.rpc("set_anim_bool","parameters/run_walk_timescale/scale",1)
		player.rpc("set_anim_bool","parameters/run/blend_position",Vector2(0,0))
		
	.enter(_msg)
	
	
	
func state_physics_process(delta : float) -> void:
	
	if player.is_locked or !player.is_alive or !player.is_local():
		return
	
		
	# allow gravity
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		
	elif Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air",{jump = true})
		
	elif Input.is_action_pressed("crouch"):
		state_machine.transition_to("Crouch")
		
	elif Input.get_action_strength("move_backward") or Input.get_action_strength("move_forward") or Input.get_action_strength("move_right") or  Input.get_action_strength("move_left"):
		state_machine.transition_to("Walk")
