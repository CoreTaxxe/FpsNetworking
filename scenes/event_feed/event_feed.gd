extends VBoxContainer



func _ready():
	pass
	
	
remotesync func add_entry(a,b,action, type , color='red'):
	var _lbl = get_new_entry(a,b,action,type,color)
	var t = Timer.new()
	
	t.one_shot = true
	t.autostart = true
	t.wait_time = 5
	t.connect("timeout",self,"on_timer_timeout",[_lbl])
	
	add_child(_lbl)
	add_child(t)

func on_timer_timeout(lbl):
	remove_child(lbl)
	
	
func get_new_entry(a,b,action,type,color='red'):
	var _lbl = RichTextLabel.new()
	_lbl.bbcode_enabled = true
	_lbl.bbcode_text = "[right]" + str(a) + "[color="+color+"]"+action+"[/color]"+str(b) + type + "[/right]"
	_lbl.fit_content_height = true
	_lbl.rect_min_size.x = 500
	return _lbl
