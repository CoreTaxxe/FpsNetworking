class_name Map
extends Spatial



onready var spawn_container = get_node_or_null("spawns_cont")


func get_spawns():
	return spawn_container.get_children()
