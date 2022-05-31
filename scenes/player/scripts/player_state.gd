class_name PlayerState
extends State


var player : Player


func _ready() -> void:
	wait_owner_ready()
	player = owner as Player
	assert(player != null)
	
	
