class_name State
extends Node


var state_machine= null


func wait_owner_ready():
	yield(owner,"ready")


func handle_input(_event : InputEvent) -> void:
	pass
	
	
func state_process(delta : float) -> void:
	pass
	
	
func state_physics_process(delta : float) -> void:
	pass
	
	
func enter(_msg : Dictionary = {}) -> void:
	if state_machine.debug:
		print("Enter state : ",name)
	
func exit() -> void:
	if state_machine.debug:
		print("Exit state : ",name)
