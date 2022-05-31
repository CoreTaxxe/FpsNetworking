extends Spatial

onready var loading_screen_scene = preload("res://scenes/loading_screen/loading_screen.tscn")
onready var player_scene = preload("res://scenes/player/player.tscn")
onready var map_attachment = get_node("map")
onready var waiting_for_players_screen = get_node("waiting_for_players")

onready var player_container = get_node("player_cont")
onready var bot_container = get_node("bot_cont")
onready var event_feed = get_node("event_feed")
onready var score_board = get_node("scoreboard")

var map = null

var __maps = {
	"cargo" : "res://scenes/maps/cargo/mp_cargo.tscn"
}

var __global_game_players_status = {}
var global_game_state = {}
var _server_ready = false


func _ready():
	print("[Main] ready.")
	score_board.hide()
	
	if Network.is_server():
		# connect waiting screen
		waiting_for_players_screen.connect("countdown_ended" , self, "on_game_countdown_ended")
		
		# create
		for player in Network.global_player_lobby_data:
			__global_game_players_status[player] = {"finished_loading" : false}
			
			
func setup(_data):
	print("[Main][Setup]")
	__load_map(_data["map"])
	
	
func __load_map(map_name):
	var loader = ResourceLoader.load_interactive(__maps[map_name])
	
	if loader == null:
		print("loader couldnt load resouirce ",__maps[map_name])
		return
	
	var loading_screen = loading_screen_scene.instance()

	add_child(loading_screen)
	
	loading_screen.set_level_name(map_name.to_upper())
	
	while true:
		#if Network.is_server():
		#	randomize()
		#	yield(get_tree().create_timer(0.1),"timeout")
		
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			map = resource.instance()
			map_attachment.add_child(map)
			loading_screen.queue_free()
			call_deferred("__map_loaded")
			break
			
		elif err == OK:
			var progress = float(loader.get_stage())/loader.get_stage_count()
			loading_screen.set_loading_bar_value(progress * 100)
			
		else:
			print("Error")
			break
			
		yield(get_tree(), "idle_frame")
	
	
	
func __map_loaded():
	print("[Main][Map] local map loaded.")
	
	if Network.is_server():
		peer_map_loaded(Network.get_local_player_id())
		request_initial_player_spawn(Network.get_local_player_id())
	else:
		# send data to server
		rpc_id(1,"peer_map_loaded", Network.get_local_player_id())
		rpc_id(1,"request_initial_player_spawn",Network.get_local_player_id())
		
		
# called on SERVER once a peer is done loadingn the map
master func peer_map_loaded(peer_id):
	print("[Main][Map][Server] Player loaded ",peer_id)
	
	# set peer to true
	__global_game_players_status[peer_id]["finished_loading"] = true
	
	# check other players
	var __can_start = true
	var __players_still_loading = []
	var __players_ready = []
	
	for player_id in __global_game_players_status.keys():
		if not __global_game_players_status[player_id]["finished_loading"]:
			__can_start = false
			__players_still_loading.append(player_id)
		else:
			__players_ready.append(player_id)
			
			
	if __can_start:
		print("[Main][Server] starting match countdown.",__global_game_players_status)
		rpc("start_match_countdown",Globals.game_wait_time)
	else:
		waiting_for_players_screen.filter_list(__players_still_loading)
		for player_id in __players_ready:
			if player_id != Network.get_local_player_id():
				rpc_id(player_id,"update_waiting_list",__players_still_loading)
				
		print("[Main][Server] waiting for ",__players_still_loading)
				
		
	

puppet func update_waiting_list(player_list):
	waiting_for_players_screen.filter_list(player_list)
	
	
remotesync func start_match_countdown(time : int):
	waiting_for_players_screen.prepare_game_start(time)
	
	
	
func on_game_countdown_ended():
	rpc("start_game")
	
	
remotesync func start_game():
	for player in player_container.get_children():
		player.unlock()
		
	waiting_for_players_screen.cease_all()
	waiting_for_players_screen.queue_free()
	
	
func get_spawn():
	
	randomize()
	
	var spawns : Array = map.get_spawns()
	var index =  randi() % spawns.size()
	
	print("Spawn index ", index)

	return spawns[index]
	
func on_toggle_scoreboard(state):
	score_board.visible = state
	
	
master func request_initial_player_spawn(peer_id):
	
	var _init_data = {
		"id" : peer_id,
		"network_master" : peer_id,
		"init_position" : null,#get_spawn().global_transform.origin,
		"username" : Network.global_player_lobby_data[peer_id]["username"],
		"allow_unlock" : false,
		"is_initial" : true
	}
	# register player to player pol
	global_game_state[peer_id] = _init_data
	
	if peer_id == Network.get_local_player_id():
		bulk_spawn_players(global_game_state)
		
	else:
		rpc_id(peer_id,"bulk_spawn_players",global_game_state)
		
		
	# tell other peer to spawn player
	for player in global_game_state.keys():
		if player != peer_id:
			if player == Network.get_local_player_id():
				spawn_player(_init_data)
			else:
				rpc_id(player,"spawn_player",_init_data)
		

puppet func spawn_player(_data):
	print("[Main] Spawning player",_data)
	
	
	var _player_id = _data["id"]
	var _player_name = _data["username"]
	var _init_position = _data["init_position"]
	
	if _data["is_initial"]:
		score_board.add_entry(_player_id,_player_name)
	
	var _player_instance = player_scene.instance()
	
	# set network master
	_player_instance.set_network_master(_data["network_master"])
	
	print("Network master set")

	# set innstance name
	_player_instance.name = str(_player_id) 
	
	_player_instance.player_id = _player_id

	# add instance to the player contaienr
	player_container.add_child(_player_instance)
	# set player tag
	_player_instance.set_name_tag(_player_name)
	# set player spawn
	
	if _data["allow_unlock"]:
		_player_instance.unlock()
		
	if _player_id == Network.get_local_player_id():
		_player_instance.connect("toggle_scoreboard",self,"on_toggle_scoreboard")
		
	
	if Network.is_server():
		_player_instance.connect("died",self,"on_player_died")
		
		if not _data["allow_unlock"]:
			rpc("send_event_feed_message",_player_name," has joined.","","")
	
	if _player_id == Network.get_local_player_id():
		_player_instance.global_transform.origin = get_spawn().global_transform.origin # local - for now
	else:
		_player_instance.global_transform.origin.y = 10000
	
	
	
puppet func bulk_spawn_players(players):
	for player_id in players:
		spawn_player(players[player_id])
		
		
func on_player_died(victim ,killer,weapon):
	print("[Main][SERVER] DEAD")
	print(victim,killer,weapon)
	
	if killer== victim:
		rpc("send_event_feed_message",
			Network.global_player_lobby_data[victim]["username"],
			" fell to death"
		)
		
		rpc("update_scoreboard",victim,0,1,-100)
		
	elif weapon == null:
		rpc("send_event_feed_message",
			Network.global_player_lobby_data[victim]["username"],
			Network.global_player_lobby_data[killer]["username"],
			" killed ", "with black magic??"
		)
		rpc("update_scoreboard",victim,0,1,0)
		rpc("update_scoreboard",killer,1,0,100)
		
	else:
		rpc("send_event_feed_message",
			Network.global_player_lobby_data[victim]["username"],
			Network.global_player_lobby_data[killer]["username"],
			" killed ", " with " + weapon
		)
		rpc("update_scoreboard",victim,0,1,0)
		rpc("update_scoreboard",killer,1,0,100)
	
	
	yield(get_tree().create_timer(5),"timeout")
	
	var _init_data = {
		"id" : victim,
		"network_master" : victim,
		"init_position" : get_spawn().global_transform.origin,
		"username" : Network.global_player_lobby_data[victim]["username"],
		"allow_unlock" : true,
		"is_initial" : false
	}
	
	spawn_player(_init_data)
	rpc("spawn_player",_init_data)
	
remotesync func update_scoreboard(id,kills,deaths,score):
	score_board.increment(id,kills,deaths,score)
	
remotesync func send_event_feed_message(a,b="",action="",type="",color =  "white"):
	# a,b,action, type , color
	event_feed.add_entry(a,b,action,type,color)
	
	
	
	
