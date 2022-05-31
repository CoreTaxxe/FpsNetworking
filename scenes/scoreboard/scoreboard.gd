extends Control


onready var entry = preload("res://scenes/scoreboard/scoreboard_entry/score_board_entry.tscn")
onready var entry_container = get_node("entry_container")




func get_entry_by_id(id):
	for child in entry_container.get_children():
		if child.get_player_id() == id:
			return child
			
			
func add_entry(player_id,player_name):
	var tmp = entry.instance()
	entry_container.add_child(tmp)
	
	tmp.set_player_id(player_id)
	tmp.set_player_name(player_name)
	
	
	
func increment(id,kills,deaths,score):
	var _ent = get_entry_by_id(id)
	
	if _ent:
		_ent.increment(kills,deaths,score)
	else:
		print("id invalid ", id)
