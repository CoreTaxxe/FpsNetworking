extends Map

func _ready():
	for spawn in get_spawns():
		spawn.hide()
