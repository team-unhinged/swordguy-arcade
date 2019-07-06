extends Node2D

class_name StateMachine

var stateGraph: Dictionary
var prevState: State
var currState: State

func _can_transition(a: String, b: String) -> bool:
	if !(b in stateGraph[a]):
		return false
	return true

func setStates(initialState: String, stateGraph: Dictionary) -> void:
	self.currState = get_node("./States/" + initialState)
	self.stateGraph = stateGraph

func transitionState(s: String)-> bool:
	# Transitions the state from currState to a if possible
	# Sets prevState to currState, and currState to 'a' on success.
	# On successful transition calls the following functions: 
	#	- prevState.onExit()
	#	- a.onEnter()
	#	- a.onExec()
	# returns true for success, false otherwise.
	# @param a: State
	# @return bool
	if not _can_transition(self.currState.name, s):
		return false
		
	# get the actual state object associate with the state name
	# The states are child nodes of a StateMachine instance. 
	# They must have a script attached to them which extends the 
	# State class and overrides the methods defined in State.
	# They must also have a node name that exactly matches with their
	# key in the state graph within the state machine. 
	self.prevState = currState
	print(get_node("./States/" + s))
	self.currState = get_node("./States/" + s)
	self.prevState.onExit()
	self.currState.onEnter()
	self.currState.onExec()
	
	return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
