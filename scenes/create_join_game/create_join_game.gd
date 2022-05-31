extends Control

signal close_popup 

onready var username_edit = get_node("CenterContainer/VBoxContainer/username_edit")
onready var ip_edit = get_node("CenterContainer/VBoxContainer/HBoxContainer/ip_edit")
onready var port_edit = get_node("CenterContainer/VBoxContainer/HBoxContainer/port_edit")
onready var lobby_popup = get_node("lobby_popup")
onready var lobby = get_node("lobby_popup/lobby")


func _ready():
	lobby.connect("close_popup",self,"on_lobby_popup_closed")


func _on_join_button_button_up():
	
	Network.terminate(false)
	
	_on_username_edit_text_entered(username_edit.text)
	
	var ip = ip_edit.text
	var port = port_edit.text
	
	if ip == "":
		ip = Globals.DEFAULT_IP
	
	if port == "" or not port.is_valid_integer():
		port = Globals.DEFAULT_PORT
	
	
	lobby.set_type("client")
	lobby_popup.show()
	#SceneChanger.change_scene(self,Globals.lobby_scene_path,{},{"set_type" : "client"})
	
	#yield(SceneChanger,"scene_ready")
	
	Network.connect_to_server(ip,port)


func _on_host_button_button_up():
	Network.terminate(false)
	_on_username_edit_text_entered(username_edit.text)
	var port = port_edit.text
	
	if port == "" or not port.is_valid_integer():
		port = Globals.DEFAULT_PORT
	
	lobby.set_type("server")
	lobby_popup.show()
	#SceneChanger.change_scene(self,Globals.lobby_scene_path,{},{"set_type" : "server"})
	
	#yield(SceneChanger,"scene_ready")
	
	Network.create_server(port)
	
		
func _on_username_edit_text_entered(new_text : String):
	if new_text == "" or new_text.empty() or new_text.count(" ") == new_text.length():
		new_text = "Player"
	
	Network.set_local_player_username(new_text)

func on_lobby_popup_closed():
	lobby_popup.hide()

func _on_back_button_button_up():
	emit_signal("close_popup")
	#SceneChanger.change_scene(self,Globals.menu_scene_path)
