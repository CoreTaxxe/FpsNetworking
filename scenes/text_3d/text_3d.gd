extends Spatial


onready var text_label = get_node("Viewport/text")
onready var viewport = get_node("Viewport")


func set_text(text : String):
	text_label.text = text
	viewport.size = text_label.rect_size
	
#func _process(delta):
	#if Engine.editor_hint:
#		viewport.size = text_label.rect_size
