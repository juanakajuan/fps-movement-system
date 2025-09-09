## Input handling component that processes user input and emits signals
##
## InputComponent centralizes all input handling for the player, converting raw
## input events into structured signals that other components can respond to.
## Supports movement (WASD), mouse look, jumping, sprinting, and crouching.
extends Node
class_name InputComponent

signal movement_input(direction: Vector2)
signal look_input(mouse_delta: Vector2)
signal jump_pressed
signal sprint_started
signal sprint_stopped
signal crouch_started
signal crouch_stopped
signal debug_toggle_cursor


## Handles unprocessed input events, particularly mouse motion for camera look
##
## @param event The input event to process
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			look_input.emit(event.relative)
	elif event is InputEventMouseButton:
		if event.pressed and Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


var _was_sprinting: bool = false
var _was_crouching: bool = false


## Processes continuous input actions every frame
##
## @param _delta Time elapsed since last frame (unused)
func _process(_delta: float) -> void:
	# Movement input using input map actions
	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_backward"
	)
	movement_input.emit(input_dir)

	# Jump input - single press detection
	if Input.is_action_just_pressed("jump"):
		jump_pressed.emit()

	# Debug cursor toggle - escape key
	if Input.is_action_just_pressed("ui_cancel"):
		debug_toggle_cursor.emit()

	# Sprint input - detect start/stop events
	var is_sprinting: bool = Input.is_action_pressed("sprint")
	if is_sprinting and not _was_sprinting:
		sprint_started.emit()
	elif not is_sprinting and _was_sprinting:
		sprint_stopped.emit()
	_was_sprinting = is_sprinting

	# Crouch input - detect start/stop events
	var is_crouching: bool = Input.is_action_pressed("crouch")
	if is_crouching and not _was_crouching:
		crouch_started.emit()
	elif not is_crouching and _was_crouching:
		crouch_stopped.emit()
	_was_crouching = is_crouching
