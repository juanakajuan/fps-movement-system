## A generic state machine implementation for managing state transitions and behavior.
##
## StateMachine provides a flexible system for managing different states and their transitions.
## Each state must inherit from the State class and can define its own behavior for entry, exit,
## updates, and input handling. The state machine ensures proper transitions and emits signals
## when state changes occur.
extends RefCounted
class_name StateMachine

## Emitted when the state changes from one state to another.
signal state_changed(from_state: String, to_state: String)

var _states: Dictionary = {}
var _current_state: State
var _owner: Node


## Initializes the state machine with the given owner node.
##
## @param owner The node that owns this state machine.
func _init(owner: Node) -> void:
	_owner = owner


## Adds a state to the state machine.
##
## @param state_name The unique name identifier for the state.
## @param state The State instance to add.
func add_state(state_name: String, state: State) -> void:
	state.state_machine = self
	_states[state_name] = state

	if not state.state_finished.is_connected(_on_state_finished):
		state.state_finished.connect(_on_state_finished)


## Starts the state machine with the specified initial state.
##
## @param initial_state_name The name of the state to start with.
func start(initial_state_name: String) -> void:
	if not _states.has(initial_state_name):
		push_error("State '" + initial_state_name + "' not found in state machine")
		return

	_current_state = _states[initial_state_name]
	_current_state.enter()
	state_changed.emit("", initial_state_name)


## Changes to a new state if the transition is valid.
## @param new_state_name The name of the state to transition to.
## @param force Whether to force the transition regardless of validation.
## @return true if the state change was successful, false otherwise.
func change_state(new_state_name: String, force: bool = false) -> bool:
	if not _states.has(new_state_name):
		push_error("State '" + new_state_name + "' not found in state machine")
		return false

	var new_state: State = _states[new_state_name]

	if not force and _current_state and not _current_state.can_transition_to(new_state):
		return false

	var previous_state: State = _current_state
	var previous_state_name: String = previous_state.get_state_name() if previous_state else ""

	if _current_state:
		_current_state.exit()

	_current_state = new_state
	_current_state.enter(previous_state)

	state_changed.emit(previous_state_name, new_state_name)
	return true


## Updates the current state. Should be called from _process().
##
## @param delta The time elapsed since the last frame.
func update(delta: float) -> void:
	if _current_state:
		_current_state.update(delta)


## Updates the current state for physics. Should be called from _physics_process().
##
## @param delta The physics time step.
func physics_update(delta: float) -> void:
	if _current_state:
		_current_state.physics_update(delta)


## Handles input events for the current state.
##
## @param event The input event to handle.
func handle_input(event: InputEvent) -> void:
	if _current_state:
		_current_state.handle_input(event)


## Returns the name of the current state.
##
## @return The current state name, or empty string if no state is active.
func get_current_state_name() -> String:
	return _current_state.get_state_name() if _current_state else ""


func get_owner() -> Node:
	return _owner


## Internal callback for when a state signals it has finished.
##
## @param next_state_name The name of the next state to transition to.
func _on_state_finished(next_state_name: String) -> void:
	change_state(next_state_name)
