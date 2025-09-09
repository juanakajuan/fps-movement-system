## Running state for the player during sprint movement
##
## RunningState handles high-speed player movement when sprint input is active.
## Features sprint speed and smooth transitions to other movement states.
## Manages sprint mechanics and state-specific behaviors.
extends State
class_name RunningState

const DEADZONE_THRESHOLD: float = 0.1

var movement_component: MovementComponent
var player: CharacterBody3D
var current_movement_input: Vector2 = Vector2.ZERO


## Initialize the running state
func _init() -> void:
	super("running")


## Called when entering the running state
func enter(_previous_state: State = null) -> void:
	player = state_machine.get_owner() as CharacterBody3D
	movement_component = player.movement_component

	# Set sprint speed
	movement_component.set_movement_speed(movement_component.sprint_speed)


## Called when exiting the running state
func exit() -> void:
	pass


## Called every frame while the running state is active
##
## @param _delta: Time elapsed since the last frame
func physics_update(_delta: float) -> void:
	# Update movement component with current input
	movement_component.set_input_direction(current_movement_input)

	_check_transitions()


## Handle movement input in running state
func handle_movement_input(direction: Vector2) -> void:
	current_movement_input = direction


## Handle jump input in running state
func handle_jump_input() -> void:
	if player.is_on_floor():
		movement_component.jump()
		state_finished.emit("jumping")


## Handle sprint start in running state (no-op, already running)
func handle_sprint_started() -> void:
	pass


## Handle sprint stop in running state
func handle_sprint_stopped() -> void:
	if current_movement_input.length() > DEADZONE_THRESHOLD:
		state_finished.emit("walking")
	else:
		state_finished.emit("idle")


## Handle crouch start in running state
func handle_crouch_started() -> void:
	state_finished.emit("crouching")


## Handle crouch stop in running state (no-op)
func handle_crouch_stopped() -> void:
	pass


## Check for state transitions when running
func _check_transitions() -> void:
	# No movement input - go to idle
	if current_movement_input.length() <= DEADZONE_THRESHOLD:
		state_finished.emit("idle")
		return
