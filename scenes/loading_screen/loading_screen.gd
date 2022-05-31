extends Control

onready var loading_bar = get_node_or_null("loading_bar")
onready var level_name = get_node_or_null("level_name")


func set_level_name(text):
	level_name.text = text

func set_loading_bar_value(value : float):
	if loading_bar:
		loading_bar.value = value
	else:
		print("loading bar is null")
	
