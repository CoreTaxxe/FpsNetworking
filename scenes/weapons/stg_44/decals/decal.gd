extends Spatial

func _ready():
	set_as_toplevel(true)

func _on_life_time_timeout():
	queue_free()
