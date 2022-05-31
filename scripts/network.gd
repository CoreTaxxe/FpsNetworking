extends Node

var socket = NetworkedMultiplayerENet.new()
var max_players = 10

var local_player_lobby_data = {
	"id" : null,
	"username" : "Player",
	"ready": false 
}

var global_player_lobby_data = {}

func _ready():
	# connect signals
	get_tree().connect("network_peer_connected",self,"_on_user_connected")
	get_tree().connect("network_peer_disconnected",self,"_on_user_disconnected")
	get_tree().connect("connection_failed",self,"_on_connection_failed")
	get_tree().connect("server_disconnected",self,"_on_server_disconnected")

func set_local_player_id(player_id : int)-> void:
	local_player_lobby_data["id"] = player_id
	
func get_local_player_id() -> int:
	return get_tree().get_network_unique_id()
	
func set_local_player_username(username : String) -> void:
	local_player_lobby_data["username"] = username
	
func get_local_player_username() -> String:
	return local_player_lobby_data["username"]

func set_local_player_ready(ready : bool) -> void:
	local_player_lobby_data["ready"] = ready
	
func get_local_player_ready() -> bool:
	return local_player_lobby_data["ready"]
		
func is_server() -> bool:
	return get_tree().is_network_server()

# network signals
func _on_user_connected(user_id) -> void:
	"""
	"""
	print(user_id," connected")
	
func _on_user_disconnected(user_id) -> void:
	"""
	"""
	print(user_id," disconnected")
	
func _on_connection_failed() -> void:
	"""
	"""
	print("connection failed")
	
func _on_server_disconnected() -> void:
	"""
	"""
	print("Server disconnected")
	Network.terminate()
	
# called on the clients side
func _on_connected_to_server()-> void:
	print("connected to server")
	
	__register_local_player()
	
	# send local data to the server
	rpc_id(1,"register_remote_player",get_local_player_id(),local_player_lobby_data)
	
	refresh_lobby()
	

func create_server(_port):
	socket.create_server(_port,max_players)
	
	get_tree().set_network_peer(socket)
	
	socket.connect("peer_connected",self,"_on_user_connected")
	socket.connect("peer_disconnected",self,"_on_user_disconnected")
	
	__register_local_player()
	
	refresh_lobby()
	
func connect_to_server(_ip,_port) -> void:
	
	get_tree().connect("connected_to_server",self,"_on_connected_to_server")
	
	socket.create_client(_ip,_port)
	
	get_tree().set_network_peer(socket)
	
func terminate(to_menu=true):
	socket.close_connection(100)
	
	get_tree().set_network_peer(null)
	
	get_tree().disconnect("network_peer_connected",self,"_on_user_connected")
	get_tree().disconnect("network_peer_disconnected",self,"_on_user_disconnected")
	get_tree().disconnect("connection_failed",self,"_on_connection_failed")
	get_tree().disconnect("server_disconnected",self,"_on_server_disconnected")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if to_menu:
		SceneChanger.change_scene(self,Globals.menu_scene_path)
	
	
func __register_local_player():
	set_local_player_id(get_local_player_id())
	global_player_lobby_data[get_local_player_id()] = local_player_lobby_data.duplicate()
	
	
func toggle_ready_status():
	set_local_player_ready(!get_local_player_ready())
	
	rpc("set_ready_status",get_local_player_id(),get_local_player_ready())
	
	
func __check_game_start():
	var is_ready = true
	
	for player in global_player_lobby_data.values():
		if not player['ready']:
			is_ready = false
	
	if is_ready:
		rpc("start_game")
	
# called on every client except caller
master func register_remote_player(player_id,remote_player_data):
	print("register local player " + str(player_id) + " : " + str(remote_player_data))
	
	global_player_lobby_data[player_id] = remote_player_data 
	
	rpc_id(player_id,"update_global_player_lobby_data",global_player_lobby_data)
	rpc("update_global_player_lobby_entry",player_id,remote_player_data)
	
	refresh_lobby()
	
# should only be called if a user (RE-)Connects
puppet func update_global_player_lobby_data(remote_data):
	print("UGL FORCE ")
	global_player_lobby_data = remote_data
	refresh_lobby()
	
puppetsync func update_global_player_lobby_property(player_id,property,property_value):
	print("UGL PROP")
	
puppetsync func update_global_player_lobby_entry(player_id,remote_data):
	print("UGL ENT")
	global_player_lobby_data[player_id] = remote_data
	
	refresh_lobby()
	
		
remotesync func refresh_lobby():
	print(get_tree().get_nodes_in_group("lobby"))
	get_tree().call_group("lobby","refresh_lobby_from_data",global_player_lobby_data)
	
# only called on OTHER clients sicne caller already update the value
remotesync func set_ready_status(player_id, status : bool) -> void:
	print(player_id ," -> ", status)
	global_player_lobby_data[player_id]["ready"] = status
	
	refresh_lobby()
	
	if is_server():
		__check_game_start()
		

		
remotesync func start_game():
	get_tree().call_group("lobby","start_lobby_timer",Globals.lobby_wait_time)
	

