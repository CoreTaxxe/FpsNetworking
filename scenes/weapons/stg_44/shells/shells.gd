extends RigidBody


export var speed_v = 3
export var speed_h = 3


func _ready():
	set_as_toplevel(true)
	
	randomize()
	
	apply_impulse(transform.basis.x,transform.basis.x * (randi() % speed_h + 7) )
	apply_impulse(transform.basis.y,transform.basis.y * (randi() % speed_v))

func _on_life_timer_timeout():
	queue_free()
