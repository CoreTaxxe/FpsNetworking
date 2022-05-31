extends PlayerState

var just_entered = false

func enter(_msg : =  {}):
	player.current_speed = player.run_speed
	player.snap_vec = Vector3.DOWN
	just_entered = true
	player.running_sound.play()
	.enter(_msg)
	
	
func state_physics_process(delta : float) -> void:
	if !player.is_local() or player.is_locked or !player.is_alive:
		return
	
	player.direction_vec = Vector3.ZERO
	var h_rot = player.camera.global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	player.direction_vec = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	
	player.velocity_vec.x = player.direction_vec.x * player.current_speed
	player.velocity_vec.z = player.direction_vec.z * player.current_speed
	
	player.velocity_vec = player.move_and_slide_with_snap(player.velocity_vec,player.snap_vec,Vector3.UP,true)
	
	# reduce network load
	if just_entered:
		if player.animation_tree.get("parameters/run_crouch_trans/current") != 0:
			print("skipped wwalking")
		#player.animation_tree.set("parameters/run_crouch_trans/current",0)
		player.animation_tree.set("parameters/run_walk_timescale/scale",1.5)
		#player.rpc("set_anim_bool","parameters/run_crouch_trans/current",0)
		player.rpc("set_anim_bool","parameters/run_walk_timescale/scale",1.5)
	
	player.animation_tree.set("parameters/run/blend_position",Vector2(f_input,h_input))
	player.rpc_unreliable("set_anim_bool","parameters/run/blend_position",Vector2(f_input,h_input))
	
	just_entered =  false
	
	if f_input >= 0 or not Input.is_action_pressed("sprint") or player.weapon.is_reloading():
		state_machine.transition_to("Walk")
		
	elif player.is_on_floor() and Input.is_action_just_pressed("slide"):
		state_machine.transition_to("Slide", {x  =  f_input,y = h_input})
		
	elif Input.is_action_pressed("crouch"):
		state_machine.transition_to("Crouch")
	
	elif  player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air",{jump = true})
		
	elif not player.is_on_floor() and player.snap_vec == Vector3.DOWN:
		state_machine.transition_to("Air")
		
	elif is_zero_approx(f_input) and is_zero_approx(h_input):
		state_machine.transition_to("Idle")
		

func exit():
	player.running_sound.stop()
	.exit()
