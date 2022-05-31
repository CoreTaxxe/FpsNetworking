extends Control

signal on_health_regen

onready var settings_popup = get_node("settings_popup")
onready var settings = get_node("settings_popup/settings")
onready var fps_label = get_node("fps_label")
onready var velocity_label = get_node("HBoxContainer/velocity_label")
onready var crosshair = get_node("crosshair")
onready var health_indicator = get_node("health_indicator/hp_label")
onready var regeneration_tween = get_node("regeneration_tween")
onready var blood_indicator = get_node("blood_indicator")
onready var hitmarker = get_node("hitmarker")
onready var animation_player = get_node("animation_player")
onready var hitmarker_sound = get_node("hitmarker_sound")
onready var ammo_label = get_node("HBoxContainer2/ammo_label")
onready var being_hit_sound = get_node("being_hits_sound")

var max_health = 0

func _ready():
	settings.connect("close_popup",self,"on_close_settings_popup")
	
	
func _process(delta):
	fps_label.text = str(int(Engine.get_frames_per_second()))
	
func set_velocity(num):
	velocity_label.text = str(num)
	
func set_ammo(value,max_ammo = 30):
	ammo_label.text = str(value) + "/" + str(max_ammo)
	
func is_settings_open():
	return settings_popup.visible
	
func play_being_hit():
	being_hit_sound.play()

func hide_crosshair():
	crosshair.hide()
	
func show_crosshair():
	crosshair.show()
	
	
func open_settings_popup():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	settings_popup.show()
	
	
func on_close_settings_popup():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	settings_popup.hide()
	
func set_max_health(value):
	max_health = value
	
func regenerate_health(previous):
	blood_indicator.self_modulate.a8 = 255 - (255.0/max_health * previous)
	health_indicator.text = str(previous)
	
	regeneration_tween.interpolate_property(
		blood_indicator,"self_modulate",
		Color(1,1,1,blood_indicator.self_modulate.a),
		Color(1,1,1,0),1, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	regeneration_tween.start()
	
func stop_regeneration(stop_at):
	regeneration_tween.stop(blood_indicator,"self_modulate")
	set_hp(stop_at)

	
func set_hp(value):
	blood_indicator.self_modulate.a8 = 255 - (255.0/max_health * value)
	health_indicator.text = str(value) 
	emit_signal("on_health_regen",value)


func _on_regeneration_tween_tween_step(object, key, elapsed, value):
	health_indicator.text = str(int(max_health -  value.a * max_health))
	emit_signal("on_health_regen",int(max_health -  value.a * max_health))
	
	
func show_hitmarker():
	hitmarker_sound.play()
	animation_player.play("show_hitmarker")
