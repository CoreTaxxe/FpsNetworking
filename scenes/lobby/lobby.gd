extends Control

signal close_popup

onready var player_list = get_node("player_list")
onready var lobby_counter = get_node("lobby_counter")
onready var lobby_counter_label = get_node("VBoxContainer/lobby_counter_label")

func _ready():
	print("ready")

func set_type(type):
	print("This is ",type)


func refresh_lobby_from_data(data):
	
	print("REF",data)
	
	player_list.clear()
	
	
	for player in data.values():
		var _color
		
		if player["ready"]:
			_color = Color(0.25,1,0.25)
		else:
			_color = Color(1,0.25,0.25)
			
		player_list.add_item(player["username"],load("res://icon.png"),true)
		player_list.set_item_custom_fg_color(player_list.get_item_count()-1,_color)


func _on_ready_button_button_up():
	Network.toggle_ready_status()

func _process(delta):
	if lobby_counter.time_left > 0:
		lobby_counter_label.text = str(int(lobby_counter.time_left))


func _on_back_button_button_up():
	Network.terminate()
	emit_signal("close_popup")
	#SceneChanger.change_scene(self,Globals.create_join_game_path)

func start_lobby_timer(sec : int):
	lobby_counter.wait_time = sec + 1
	lobby_counter_label.text = str(sec)
	lobby_counter.start()
	

func _on_game_start_counter_timeout():
	
	if Network.is_server():
		start_game()
		rpc("start_game")
		
remote func  start_game():
	
#	OS.window_fullscreen = true
	
	SceneChanger.change_scene(
		self,
		Globals.main_game_scene,
		{},
		{
			"setup": {
				"map": "cargo",
			}
		}
	)
