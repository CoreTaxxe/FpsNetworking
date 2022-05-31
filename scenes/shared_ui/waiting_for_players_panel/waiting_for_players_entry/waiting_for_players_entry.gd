extends Control

onready var player_name = get_node("player_name")

var target = -1


func set_target(id : int):
	target = id
	
	
func get_target():
	return target


func set_player_name(text : String):
	player_name.text = text
	
