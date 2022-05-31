class_name SmoothingNode
extends Spatial

export (NodePath) onready var target = get_node(target) as Spatial

var update = false
var gt_prev : Transform
var gt_current : Transform

func _ready():
	set_as_toplevel(true)
	global_transform = target.global_transform
	
	gt_prev = target.global_transform
	gt_current = target.global_transform
	
	
func update_transform():
	gt_prev = gt_current
	gt_current = target.global_transform
	
func _process(delta):
	if update:
		update_transform()
		update = false
		
	var f = clamp(Engine.get_physics_interpolation_fraction(),0,1)
	global_transform = gt_prev.interpolate_with(gt_current,f)
	
func _physics_process(delta):
	update = true
