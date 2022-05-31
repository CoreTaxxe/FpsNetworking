extends PlayerState


var just_entered = false

func enter(_msg : =  {}):
	player.snap_vec = Vector3.DOWN
	player.current_speed = player.slide_speed
	player.velocity_vec.x = player.direction_vec.x * player.current_speed
	player.velocity_vec.z = player.direction_vec.z * player.current_speed
	
	just_entered = true
	
	if !player.is_locked and player.is_alive:
		player.animation_tree.set("parameters/run_crouch_trans/current",2)
		player.rpc("set_anim_bool","parameters/run_crouch_trans/current",2)
	
	.enter(_msg)
	
	
func state_physics_process(delta : float) -> void:
	if !player.is_local() or player.is_locked or !player.is_alive:
		return
	
	player.velocity_vec.x = player.direction_vec.x * player.current_speed
	player.velocity_vec.z = player.direction_vec.z * player.current_speed
	
	player.current_speed -= player.slide_friction * delta
	
	player.velocity_vec = player.move_and_slide_with_snap(player.velocity_vec,player.snap_vec,Vector3.UP,true)
		
		
	just_entered = false
	
		
	if not player.is_on_floor() and player.snap_vec == Vector3.DOWN:
		state_machine.transition_to("Air")
		
	elif player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {jump = true})
			
	elif player.is_on_floor() and player.current_speed <= 7 and (Input.get_action_strength("move_right") or Input.get_action_strength("move_left") ):
		state_machine.transition_to("Walk")
		
	elif is_zero_approx(player.current_speed) or player.current_speed < 3:
		state_machine.transition_to("Idle")
	
		
	
		
