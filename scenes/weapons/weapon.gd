class_name Weapon
extends Spatial

signal finished_reloading
signal start_reloading

export var ammo = 0
export var damage = 10
# in times per second
export var fire_rate = 15
export var tag = "Undefined Weapon"

onready var _wait_time = 1 / fire_rate
onready var _current_ammo = ammo

onready var gun_animation_player : AnimationPlayer = get_node_or_null("gun_animation_player")
onready var flash_animation_player : AnimationPlayer = get_node_or_null("muzzle/flash_animation_player")
onready var ads_attachment  : Spatial = get_node_or_null("ads_attachment")
onready var ads_camera  : Camera = get_node_or_null("ads_attachment/ads_camera")
onready var ads_hit_scan : RayCast = get_node_or_null("ads_attachment/ads_camera/hit_scan")
onready var barrel_smoke : Particles = get_node_or_null("muzzle/smoke_particles")
onready var shooting_sound : AudioStreamPlayer3D = get_node_or_null("sounds/shooting")

var _timer = 0 
var _can_fire = true
var _is_reloading = false
var _is_ads = false


var _fire_anim_modifier = 1

var _overheating_cooldown_timer = Timer.new()
var _shots_fired_timer = Timer.new()
var _shots_fired = 0

func _onready():
	print("weapon ready")
	if not gun_animation_player or not flash_animation_player:
		print("ANIMATIONPLAYER MISSING")
	else:
		gun_animation_player.connect("animation_finished",self,"on_animation_finished")
		
	_wait_time = 1.0 / fire_rate
	
	print(fire_rate)
	# (x / y - 1) * 100
	# org + ((new / old - 1) * 100) / 100 * org 
		
	var _tmp_anim = flash_animation_player.get_animation("fire")
	var _length = _tmp_anim.length
	
	#_fire_anim_modifier = __calc_fire_modifier(1,0.1,fire_rate)
	
	#print("modifier ",_fire_anim_modifier)
	
	add_child(_shots_fired_timer)
	add_child(_overheating_cooldown_timer)
	
	_shots_fired_timer.wait_time = 0.2
	_overheating_cooldown_timer.wait_time = 1
	
	_shots_fired_timer.one_shot = true
	_overheating_cooldown_timer.one_shot = true
	
	_shots_fired_timer.connect("timeout",self,"_on_shots_fired_timer_reset")
	_overheating_cooldown_timer.connect("timeout",self,"_on_weapon_cooled_down")
	
	print("fireraet ",_wait_time)
	
func get_max_ammo():
	return ammo
	
func get_damage():
	return damage

func __calc_fire_modifier(base_mod,anim_length,new_dps):
	return base_mod + ((new_dps / (1 / anim_length) - 1 ) * 100) / 100  * base_mod

func get_hit_scan():
	return ads_hit_scan
	
func is_ads():
	return _is_ads

func ads():
	_is_ads = true
	ads_camera.current = true

func leave_ads():
	_is_ads = false
	ads_camera.current = false
	
func is_reloading():
	return _is_reloading
	

func reload(speed = 1):
	
	emit_signal("start_reloading")
	
	barrel_smoke.emitting = false
	
	if _is_reloading :
		return
	
	if gun_animation_player:
		_is_reloading = true

		gun_animation_player.play("reload",-1, speed)

func set_current_ammo(bullets : int):
	_current_ammo = bullets

func get_current_ammo() -> int:
	return _current_ammo

func can_fire() -> bool:
	return _can_fire and _current_ammo > 0
	
func _process(delta):
	if not _can_fire:
		_timer += delta
		
		if _timer > _wait_time:
			_timer = 0
			_can_fire = true
	
	
func fire( pos : Vector3) -> void:

	shooting_sound.play()
	
	if _shots_fired_timer.time_left > 0:
		_shots_fired_timer.stop()
	_shots_fired_timer.start()
	
	_shots_fired += 1
	
	flash_animation_player.play("fire",-1,_fire_anim_modifier)
	
	_can_fire = false
	_current_ammo -= 1
	
func on_animation_finished(ani_name  : String):
	match ani_name:
		"reload" : 
			_is_reloading = false
			_current_ammo = ammo 
			emit_signal("finished_reloading")
			
			
func _on_weapon_cooled_down():
	barrel_smoke.emitting = false
	

func empty():
	return _current_ammo <= 0
	
func _on_shots_fired_timer_reset():
	
	var _smoke_time = _shots_fired / float(fire_rate)
	
	if _smoke_time > 0.1:
		_overheating_cooldown_timer.wait_time = _shots_fired / float(fire_rate)
		_overheating_cooldown_timer.start()
		barrel_smoke.emitting = true
		
	_shots_fired = 0

