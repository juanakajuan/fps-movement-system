## Base class for all states in a finite state machine
##
## Provides the foundation for implementing state machines.
## Each state handles its own logic for entering, exiting, updating, and processing input.
## States can communicate with their parent StateMachine through signals.
extends RefCounted
class_name State

## Emitted when this state wants to transition to another state
signal state_finished(next_state_name: String)

var state_machine: StateMachine
var _name: String


## Initializes the state with a given name
func _init(state_name: String = "") -> void:
	_name = state_name


## Called when entering this state
##
## @param _previous_state: The state being transitioned from (can be null)
func enter(_previous_state: State = null) -> void:
	pass


## Called when exiting this state
func exit() -> void:
	pass


## Called every frame while this state is active
##
## @param _delta: Time elapsed since the last frame
func update(_delta: float) -> void:
	pass


## Called every physics frame while this state is active
##
## @param _delta: Time elapsed since the last physics frame
func physics_update(_delta: float) -> void:
	pass


## Called when input events occur while this state is active
##
## @param _event: The input event that occurred
func handle_input(_event: InputEvent) -> void:
	pass


## Called when movement input is received
##
## @param _direction: The movement direction vector
func handle_movement_input(_direction: Vector2) -> void:
	pass


## Called when jump input is received
func handle_jump_input() -> void:
	pass


## Called when sprint starts
func handle_sprint_started() -> void:
	pass


## Called when sprint stops
func handle_sprint_stopped() -> void:
	pass


## Called when crouch starts
func handle_crouch_started() -> void:
	pass


## Called when crouch stops
func handle_crouch_stopped() -> void:
	pass


## Determines if this state can transition to another state
##
## @param _next_state: The state we want to transition to
## @return: True if the transition is allowed, false otherwise
func can_transition_to(_next_state: State) -> bool:
	return true


func get_state_name() -> String:
	return _name
