## Input handling component that processes user input and emits signals
##
## InputComponent centralizes all input handling for the player, converting raw
## input events into structured signals that other components can respond to.
## Supports movement (WASD), mouse look, jumping, sprinting, and crouching.
extends Node
class_name InputComponent

signal movement_input(direction: Vector2)
signal look_input(mouse_delta: Vector2)
signal jump_input
signal sprint_input(is_sprinting: bool)
signal crouch_input(is_crouching: bool)


## Handles unprocessed input events, particularly mouse motion for camera look
##
## @param event The input event to process
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_input.emit(event.relative)


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
		jump_input.emit()

	# Sprint input - hold to sprint
	var is_sprinting: bool = Input.is_action_pressed("sprint")
	sprint_input.emit(is_sprinting)

	# Crouch input - hold to crouch
	var is_crouching: bool = Input.is_action_pressed("crouch")
	crouch_input.emit(is_crouching)
