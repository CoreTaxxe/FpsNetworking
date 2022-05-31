class_name StateMachine
extends Node


signal transitioned(state_name)

export (NodePath) onready var initial_state
export var debug : bool = false

var state



func _ready():
	yield(owner,"ready")
	
	state = get_node(initial_state)
	
	for child in get_children():
		child.state_machine = self
		
	state.enter() 
	
func _unhandled_input(event : InputEvent) -> void :
	state.handle_input(event)
	
func _process(delta : float) -> void:
	state.state_process(delta)
	
func _physics_process(delta) -> void:
	state.state_physics_process(delta)
	
func transition_to(target_state_name : String, msg : Dictionary = {}) -> void:
	if not has_node(target_state_name):
		if debug:
			print("State not found : ",target_state_name)
		return
	
	state.exit()
	state = get_node(target_state_name)
	state.enter(msg)
	
	emit_signal("transitioned",state.name)
