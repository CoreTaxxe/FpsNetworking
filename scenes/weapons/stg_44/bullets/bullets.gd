extends Spatial

export var speed = 25

var target = Vector3(0,0,0)
var last = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)
	#apply_impulse(transform.basis.z,-transform.basis.z * speed)

func set_target(vec):
	look_at(vec,Vector3.UP)
	target = vec
	last = target.distance_to(global_transform.origin)
	
func _process(delta):
	global_transform.origin -= global_transform.basis.z * speed
		
	var dist = target.distance_to(global_transform.origin)
	
	if dist < last:
		last = dist
	else:
		queue_free()
	


func _on_life_timer_timeout():
	queue_free()
