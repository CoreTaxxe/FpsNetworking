extends Node

signal scene_ready

onready var loading_screen_scene = preload("res://scenes/loading_screen/loading_screen.tscn")
onready var current = get_tree().get_current_scene()

export var max_load_time = 10000

func change_scene(from,to,params={},functions={}):
	
	var t = OS.get_ticks_msec()
	var loader = ResourceLoader.load_interactive(to)
	
	if loader == null:
		print("loader couldnt load resouirce ",to)
		return
	
	var loading_screen = loading_screen_scene.instance()

	current.add_child(loading_screen)
	
	loading_screen.set_level_name(to)
	
	
	while true:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			__add_scene(from,resource,params,functions)
			loading_screen.queue_free()
			break
			
		elif err == OK:
			var progress = float(loader.get_stage())/loader.get_stage_count()
			loading_screen.set_loading_bar_value(progress * 100)
			
		else:
			print("Error")
			break
			
		yield(get_tree(), "idle_frame")
	
func __add_scene(from,resource,params={},functions={}):
	
	var _scene = resource.instance()
	
	_scene.connect("ready",self,"on_scene_ready")
	
	if current != null:
		get_tree().get_root().remove_child(current)
		current.queue_free()
		
	
	get_tree().get_root().add_child(_scene)
	get_tree().set_current_scene(_scene)
	

	current = get_tree().get_current_scene()
	
	for key in params:
		if key in current:
			current.set(key,params[key])
			
	for key in functions:
		if current.has_method(key):
			if typeof(functions[key]) == TYPE_ARRAY:
				current.callv(key,functions[key])
			else:
				current.call(key,functions[key])
		else:
			print(current," has no method called ",key)
	
func on_scene_ready():
	emit_signal("scene_ready")
