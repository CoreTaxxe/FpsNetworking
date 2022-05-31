# add something to prevent nodes from sending rpc calls to clients that havent instanced that 
# client yet
class_name Player
extends KinematicBody

signal died
signal toggle_scoreboard

export var is_bot = false

export var max_health = 150

export var crouch_speed : float = 3.0
export var walk_speed : float = 6.0
export var run_speed : float = 9.0
export var tactical_sprint_speed : float = 9.0
export var slide_speed : float = 12.0

export var jump_strength : float = 12.0
export var gravity : float = 20.0
export var slide_friction : float = 8

var current_speed : float = 7.0

var velocity_vec : Vector3 = Vector3.ZERO
var snap_vec : Vector3 = Vector3.DOWN
var direction_vec : Vector3 = Vector3.ZERO

var view_vec = Vector2(0,0)

var __min_look_angle = -45
var __max_look_angle = 45

onready var camera = get_node("Character/Armature/camera_attachment/Camera")
onready var hit_scan = get_node("Character/Armature/camera_attachment/Camera/hit_scan")
onready var animation_tree = get_node("AnimationTree")
onready var player_ui = get_node("player_ui")
onready var crouch_collision = get_node("crouch_col")
onready var normal_collision = get_node("normal_col")
onready var name_tag = get_node("name_tag")
onready var hp_bar = get_node("healthbar_3d")
onready var weapon   = get_node("Character/Armature/gun_attachment/gun_corrector/stg_44")
onready var regeneration_timer : Timer = get_node("regeneration_timer")
onready var life_timer : Timer = get_node("life_timer")
onready var skeleton : Skeleton = get_node("Character/Armature")
onready var running_sound = get_node("runing_sound")
onready var death_sound = get_node("death_sound")

onready var hit_zones = {
	"head"  : [get_node("Character/Armature/head_hit_box/head_hitbox"),2.0],
	"chest" : [get_node("Character/Armature/chest_hit_box/chest_hitbox"),1.0],
	"upper_leg_L" : [get_node("Character/Armature/leg_l_hitbox_upper/leg_l_hitbox_upper"),0.75],
	"upper_leg_R" : [get_node("Character/Armature/leg_r_hitbox_upper/leg_r_hitbox_upper"),0.75],
	"lower_leg_L" : [get_node("Character/Armature/leg_l_hitbox/leg_l_hitbox"),0.5],
	"lower_leg_R" : [get_node("Character/Armature/leg_r_hitbox/leg_r_hitbox"),0.5]
}

var player_id = -1

var is_enemy = true
var is_locked = true
var is_alive = true

var is_ads = false
var can_shoot = true
var can_reload = true

var vertical_recoil = 0

var health = max_health setget set_health, get_health

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	player_ui.set_max_health(max_health)
	player_ui.set_hp(max_health)
	hp_bar.set_max_hp(max_health)
	
	player_ui.connect("on_health_regen",hp_bar,"on_set_health")
	weapon.connect("finished_reloading",self,"on_done_reloading")
	
	if is_local():
		player_ui.hide()
		name_tag.hide()
		hp_bar.hide()
		
	else:
		player_ui.hide()
		
		for area  in hit_zones.values():
			area[0].set_collision_layer_bit(2,false)
			area[0].set_collision_mask_bit(2,false)
			
			# change values to allow bullets to pass through players
			area[0].set_collision_layer_bit(3,true)
			area[0].set_collision_mask_bit(3,true)
			
			area[0].set_collision_layer_bit(4,true)
			area[0].set_collision_mask_bit(4,true)
			
	print("setup")
			
func _input(event):
	if is_bot or not is_network_master() or player_ui.is_settings_open() or !is_alive:
		return
		
	if event is InputEventMouseMotion:
		
		var _sens = Globals.mouse_sensitivity / Globals.mouse_sensitivity_modifier
		
		if is_ads:
			_sens = _sens / 2
		
		rotate_y(deg2rad(-event.relative.x * _sens))
		#camera.rotate_x(deg2rad(-event.relative.y * Globals.mouse_sensitivity/ Globals.mouse_sensitivity_modifier))
		#camera.rotation.x = clamp(camera.rotation.x,deg2rad(__min_look_angle),deg2rad(__max_look_angle))
		view_vec.x += deg2rad(-event.relative.y * _sens)
		view_vec.x = clamp(view_vec.x,-1,1)
		animation_tree.set("parameters/look/blend_position",view_vec)
		# only sets rotation when mouse is acutally moved. Avoids unneccasry calls
		if not is_locked and is_alive:
			rpc_unreliable("set_anim_bool","parameters/look/blend_position",view_vec)

func _physics_process(delta):
	

	if !is_local():
		return
		
	if global_transform.origin.y < -100:
		is_alive = false
		rpc("kill_sync",self.player_id,self.player_id,null)
		
	_process_input(delta)
	
	
	if is_locked or !is_alive:
		return
	
	camera.current = true
	
	if !is_alive:
		return
	
	player_ui.set_velocity(current_speed)
	
	if player_ui.is_settings_open():
		return
		
	_process_state_independent_input(delta)
	
	rpc_unreliable("set_transform",global_transform)
	
	
func _process_input(delta):
	if Input.is_action_just_pressed("escape"):
		if player_ui.is_settings_open():
			player_ui.on_close_settings_popup()
		else:
			player_ui.open_settings_popup()
			
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		
func  _process_state_independent_input(delta : float) -> void:
	if Input.is_action_pressed("primary"):
		if can_shoot and weapon.can_fire():
			primary_fire()
			rpc_unreliable("primary_fire")
			
		elif can_reload and not weapon.is_reloading() and weapon.empty():
			reload(2)
			rpc("reload",2)
			
	else:
		vertical_recoil = 0
		
	if Input.is_action_pressed("secondary") and not weapon.is_reloading():
		is_ads = true
		player_ui.hide_crosshair()
		weapon.ads()
	else:
		is_ads = false
		player_ui.show_crosshair()
		weapon.leave_ads()
		
	if Input.is_action_just_pressed("reload") and can_reload and not weapon.is_reloading():
		reload(2)
		rpc("reload",2)
		
	if Input.is_action_just_pressed("scoreboard"):
		emit_signal("toggle_scoreboard",true)
		
	if Input.is_action_just_released("scoreboard"):
		emit_signal("toggle_scoreboard",false)
		
	if Input.is_action_just_pressed("kill"):
		rpc("kill_sync",self.player_id,self.player_id,null)
	
func unlock():
	is_locked = false
	if is_local():
		camera.current = true
		player_ui.show()
	
func is_local():
	return !is_bot and is_network_master()
	
func set_name_tag(text : String):
	name_tag.set_text(text)
	
	
func set_health(value):
	health = value
	player_ui.set_hp(health)
	
func get_health():
	return health
	
func disable_area_collision():
	for area in hit_zones:
		pass
		
func on_done_reloading():
	player_ui.set_ammo(weapon.get_current_ammo(),weapon.get_max_ammo())
		
puppet func primary_fire():
	if not hit_scan:
		return
	

		
	animation_tree.set("parameters/shooting_oneshot/active",true)
		
	var _tmp_hit_scan = hit_scan
	

	if is_ads:
		_tmp_hit_scan = weapon.get_hit_scan()
	
	if is_network_master():
		var horizontal_recoil = rand_range(-1,1)
		var recoil = rand_range(5,10)
		
		vertical_recoil += (recoil / 100.0)
		
		if vertical_recoil >= 1:
			vertical_recoil = 1
			
		if is_ads:
			_tmp_hit_scan = weapon.get_hit_scan()
			vertical_recoil = vertical_recoil / 2
			horizontal_recoil = 0.05
			
		rotate_y(deg2rad(horizontal_recoil))
		view_vec.x = view_vec.x + deg2rad(vertical_recoil)
		view_vec.x = clamp(view_vec.x,-1,1)
		
		animation_tree.set("parameters/look/blend_position",view_vec)
		# only sets rotation when mouse is acutally moved. Avoids unneccasry calls
		if not is_locked and is_alive:
			rpc_unreliable("set_anim_bool","parameters/look/blend_position",view_vec)


		
	if _tmp_hit_scan.is_colliding():	
		weapon.fire(_tmp_hit_scan.get_collision_point())
		
		var _collider = _tmp_hit_scan.get_collider()
		
		if _collider.owner:
			if _collider.owner.is_in_group("player"):
				if is_network_master():
					_collider.owner.map_damage(_collider, self, weapon)
					
					player_ui.show_hitmarker()
			else:
				weapon.add_decal(_tmp_hit_scan)
		
	else:
		weapon.fire(_tmp_hit_scan.to_global(_tmp_hit_scan.cast_to))
		
		
	player_ui.set_ammo(weapon.get_current_ammo(),weapon.get_max_ammo())
	

func map_damage(area, dealer, dealer_weapon):
	for zone in hit_zones.keys():
		if area == hit_zones[zone][0]:
			var _zone = hit_zones[zone]
			
			#rpc_id(player_id,"apply_damage",_zone[1])
			rpc_id(player_id,"apply_damage",int(dealer_weapon.get_damage() * _zone[1]), dealer.player_id,dealer_weapon.tag)

remote func apply_damage(damage, dealer, dealer_weapon):
			
	self.health -= damage
	
	player_ui.play_being_hit()
	
	player_ui.stop_regeneration(self.health)
	regeneration_timer.start()
	
	if is_alive:
		rpc("synchronize_health",self.health)
	
	if health <= 0:
		is_alive = false
		rpc("kill_sync",self.player_id,dealer,dealer_weapon)
		#rpc_id(self.player_id,"kill_local",self.player_id,dealer.player_id,dealer_weapon.tag)
	
			
func _on_regeneration_timer_timeout():
	player_ui.regenerate_health(self.health)
	self.health = max_health
	
func _on_life_timer_timeout():
	queue_free()
	
remotesync func kill_sync(victim,dealer,dealer_weapon):
	name = "dead_"+ name
	
	is_alive = false
	#set_network_master(-1)
	
	regeneration_timer.stop()
	running_sound.stop()
	player_ui.hide()
	hp_bar.hide()
	name_tag.hide()
	death_sound.play()
	
	skeleton.physical_bones_start_simulation()
	
	life_timer.start()
	
	crouch_collision.disabled = true
	normal_collision.disabled = true
	
	for area in hit_zones.values():
		area[0].get_child(0).disabled = true
		
	emit_signal("died",victim,dealer,dealer_weapon)
	

remotesync func kill(victim,dealer,dealer_weapon):
	is_alive = false
	
	emit_signal("died",victim,dealer,dealer_weapon)
	


remote func synchronize_health(value):
	self.health = value
	player_ui.stop_regeneration(self.health)
	regeneration_timer.start()
	
puppet func reload(speed = 1):
	weapon.reload(speed)
	

			
puppet func set_anim(path,lerp_target,lerp_weight):
	print("WARNING INTERPOLATION CLALLED")
	set_anim_bool(path,lerp_target)
	
	return
	
	animation_tree.set(
		path, lerp(animation_tree.get(path),lerp_target,lerp_weight)
	)
	
puppet func set_anim_bool(path,value):
	animation_tree.set(
		path, value
	)
	
puppet func set_transform(remote_transform : Transform):
	global_transform = remote_transform
		




