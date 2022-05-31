extends Control

signal countdown_ended

onready var waiting_entry_scene = preload("res://scenes/shared_ui/waiting_for_players_panel/waiting_for_players_entry/waiting_for_players_entry.tscn")
onready var waiting_container = get_node("waiting_for_player_attachment/waiting_for_players_container")
onready var waiting_cont_attach = get_node("waiting_for_player_attachment")
onready var waiting_counter = get_node("waiting_counter")
onready var game_countdown_label = get_node("game_countdown_label")
onready var ticking_sound = get_node("ticking_sound")


func _process(delta):
	if waiting_counter.time_left > 0 and Network.is_server():
		if int(waiting_counter.time_left) != int(game_countdown_label.text):
			rpc("sync_countdown",int(waiting_counter.time_left))
		game_countdown_label.text = str(int(waiting_counter.time_left))


func add_entry(player_id,text):
	var _tmp = waiting_entry_scene.instance()
	
	waiting_container.add_child(_tmp)
	
	_tmp.set_target(player_id)
	_tmp.set_player_name(text)
	
	
	
func remove_entry(player_id):
	for child in waiting_container.get_children():
		if child.get_target() == player_id:
			waiting_container.remove_child(child)
			break
			
func filter_list(items : Array):
	var current_items = []
	
	for child in waiting_container.get_children():
		current_items.append(child.get_target())
		
	for item in items:
		if not item in current_items:
			add_entry(item, Network.global_player_lobby_data[item]["username"])
		current_items.erase(item)

			
	for remaining in current_items:
		remove_entry(remaining)
		


func prepare_game_start(time : int):
	waiting_cont_attach.hide()
	game_countdown_label.show()
	
	waiting_counter.wait_time = time + 1
	game_countdown_label.text = str(time)
	
	ticking_sound.play(0.33)
	
	if Network.is_server():
		waiting_counter.start()
	
puppet func sync_countdown(time ):
	game_countdown_label.text = str(time)
	

func _on_waiting_countdown_timeout():
	emit_signal("countdown_ended")
	
func cease_all():
	ticking_sound.stop()
