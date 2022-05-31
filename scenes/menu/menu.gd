extends Control

onready var settings_popup = get_node("settings_popup")
onready var settings = get_node("settings_popup/settings")
onready var create_game_popup = get_node("create_game_popup")
onready var create_game = get_node("create_game_popup/create_join_game")


func _ready():
	var memory_before = OS.get_static_memory_usage()
	var obj = Vector3(999999.999999,99999.99999,99999.9999)
	var memory_used = OS.get_static_memory_usage() - memory_before
	print(memory_used)
	
	settings.connect("close_popup",self,"on_close_settings_popup")
	create_game.connect("close_popup",self,"on_game_close_popup")

func _on_player_button_button_up():
	create_game_popup.show()
	#SceneChanger.change_scene(self,Globals.create_join_game_path)
	


func _on_settings_button_button_up():
	settings_popup.show()
	#SceneChanger.change_scene(self,Globals.settings_scene_path,{},{"setup" : [false]})

func on_close_settings_popup():
	settings_popup.hide()

func on_game_close_popup():
	create_game_popup.hide()
