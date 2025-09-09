## Idle state for the player when not moving
##
## IdleState handles the player behavior when no movement input is detected.
## It applies smooth deceleration and monitors for input to transition to other states.
extends State
class_name IdleState

var movement_component: MovementComponent
var camera_component: CameraComponent
var player: CharacterBody3D
var current_movement_input: Vector2 = Vector2.ZERO


## Initialize the idle state
func _init() -> void:
	super("idle")


## Called when entering the idle state
func enter(_previous_state: State = null) -> void:
	player = state_machine.get_owner() as CharacterBody3D
	movement_component = player.movement_component
	camera_component = player.camera_component

	print("Entering idle state from: ", _previous_state.get_state_name() if _previous_state else "none")
	
	# Set idle speed and clear movement input
	movement_component.set_movement_speed(0.0)
	movement_component.set_input_direction(Vector2.ZERO)
	current_movement_input = Vector2.ZERO


## Called when exiting the idle state
func exit() -> void:
	pass


## Called every frame while the idle state is active
##
## @param _delta: Time elapsed since the last frame
func physics_update(delta: float) -> void:
	# Apply smooth deceleration when idle
	if player.is_on_floor():
		player.velocity.x = lerp(player.velocity.x, 0.0, delta * DECELERATION_RATE)
		player.velocity.z = lerp(player.velocity.z, 0.0, delta * DECELERATION_RATE)

	_check_transitions()


## Handle movement input in idle state
func handle_movement_input(direction: Vector2) -> void:
	current_movement_input = direction
	movement_component.set_input_direction(direction)


## Handle jump input in idle state
func handle_jump_input() -> void:
	if player.is_on_floor():
		movement_component.jump()
		state_finished.emit("jumping")


## Handle sprint start in idle state
func handle_sprint_started() -> void:
	if current_movement_input.length() > DEADZONE_THRESHOLD:
		state_finished.emit("running")


## Handle crouch start in idle state
func handle_crouch_started() -> void:
	state_finished.emit("crouching")


## Handle sprint stop in idle state (no-op)
func handle_sprint_stopped() -> void:
	pass


## Handle crouch stop in idle state (no-op)
func handle_crouch_stopped() -> void:
	pass


## Check for state transitions when idle
func _check_transitions() -> void:
	# Transition to walking if there's movement input
	if current_movement_input.length() > DEADZONE_THRESHOLD:
		state_finished.emit("walking")
