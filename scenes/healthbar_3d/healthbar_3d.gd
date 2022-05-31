extends Spatial


onready var progress_bar = get_node("Viewport/health_progress")
onready var viewport = get_node("Viewport")

func on_set_health(value):
	set_hp(value)
	
func set_max_hp(value):
	progress_bar.max_value = value

func set_hp(hp):
	progress_bar.value = hp
	if progress_bar:
		viewport.size = progress_bar.rect_size
	
#func _process(delta):
	#if Engine.editor_hint:
	#	if progress_bar:
	#		viewport.size = progress_bar.rect_size
