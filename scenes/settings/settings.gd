extends Control

signal close_popup


onready var sensitivity_slider = get_node("TabContainer/Game Settings/VBoxContainer/HBoxContainer/sensitivity_slider")
onready var sensitivity_edit = get_node("TabContainer/Game Settings/VBoxContainer/HBoxContainer/sensitivity_edit")
onready var music_volume_slider = get_node("TabContainer/Game Settings/VBoxContainer/HBoxContainer2/volume_slide")
onready var music_volume_edit= get_node("TabContainer/Game Settings/VBoxContainer/HBoxContainer2/volume_edit")


var change_by_edit = false
var is_popup = true

func _ready():
	sensitivity_edit.text = str(Globals.mouse_sensitivity)
	sensitivity_slider.value = float(Globals.mouse_sensitivity)
	
	music_volume_edit.text = str(Globals.main_music_volume)
	music_volume_slider.value = float(Globals.main_music_volume)
	
func setup(_set_is_popup):
	is_popup = _set_is_popup

func _on_sensitivity_slider_value_changed(value):
	Globals.mouse_sensitivity = value
	if change_by_edit:
		change_by_edit = false
	else:
		sensitivity_edit.text = str(value)


func _on_sensitivity_edit_text_entered(new_text):
	if new_text.is_valid_float() or new_text.is_valid_integer():
		change_by_edit = true
		sensitivity_slider.value = float(new_text)
		


func _on_back_button_button_up():
	if is_popup:
		emit_signal("close_popup")
	else:
		SceneChanger.change_scene(self,Globals.menu_scene_path)


func _on_volume_slide_value_changed(value):
	Globals.main_music_volume = value
	
	AudioServer.set_bus_volume_db(1,value)
	
	if change_by_edit:
		change_by_edit = false
	else:
		music_volume_edit.text = str(value)
	
	
func _on_volume_edit_text_entered(new_text):
	if new_text.is_valid_float() or new_text.is_valid_integer():
		change_by_edit = true
		music_volume_slider.value = float(new_text)


