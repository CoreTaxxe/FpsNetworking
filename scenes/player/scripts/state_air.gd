extends PlayerState



func enter(_msg : Dictionary = {}):
	player.snap_vec = Vector3.ZERO
	player.current_speed = player.walk_speed
	
	if !player.is_locked and player.is_alive:
	
		if _msg.has("jump") and _msg.get("jump") == true:
			player.animation_tree.set("parameters/jump_oneshot/active",true)
			player.rpc("set_anim_bool","parameters/jump_oneshot/active",true)
			player.velocity_vec.y = player.jump_strength
		
	.enter(_msg)
	
	
	
func state_physics_process(delta : float) -> void:
	if player.is_locked or !player.is_alive:
		return

	player.direction_vec = Vector3.ZERO
	
	var h_rot = player.camera.global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	player.direction_vec = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	player.velocity_vec.x = player.direction_vec.x * player.current_speed
	player.velocity_vec.z = player.direction_vec.z * player.current_speed
	
	player.velocity_vec.y -= player.gravity * delta
	
	player.velocity_vec = player.move_and_slide_with_snap(player.velocity_vec,player.snap_vec,Vector3.UP,true)
	
	if player.is_on_floor() and player.snap_vec == Vector3.ZERO:
		if is_zero_approx(player.velocity_vec.x) and is_zero_approx(player.velocity_vec.z):
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Walk")
