extends ColorRect


onready var username = get_node("HBoxContainer/names")
onready var kills = get_node("HBoxContainer/kills")
onready var deaths = get_node("HBoxContainer/deaths")
onready var score = get_node("HBoxContainer/score")

var player_id = 0

func set_player_id(id):
	player_id = id
	
	
func get_player_id():
	return player_id


func set_player_name(player_name):
	username.text = player_name


func increment(_kills,_death,_score):
	kills.text = str(int(kills.text) + _kills)
	deaths.text = str(int(deaths.text) + _death)
	score.text = str(int(score.text) + _score)
