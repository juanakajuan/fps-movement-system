## Jumping state for the player during aerial movement
##
## JumpingState handles player behavior while in the air, including air control,
## gravity application, and landing detection. Features jump buffering and smooth
## transitions back to appropriate ground states based on player input.
extends State
class_name JumpingState

const JUMP_BUFFER_DURATION: float = 0.2

var movement_component: MovementComponent
var player: CharacterBody3D
var current_movement_input: Vector2 = Vector2.ZERO
var jump_buffer_time: float = 0.0
var was_on_floor_last_frame: bool = false


## Initialize the jumping state
func _init() -> void:
	super("jumping")


## Called when entering the jumping state
func enter(_previous_state: State = null) -> void:
	player = state_machine.get_owner() as CharacterBody3D
	movement_component = player.movement_component

	# Apply jump velocity when entering from ground states
	if _previous_state and _previous_state.get_state_name() in ["idle", "walking", "running"]:
		if player.is_on_floor():
			player.velocity.y = movement_component.jump_velocity


## Called when exiting the jumping state
func exit() -> void:
	jump_buffer_time = 0.0


## Called every frame while the jumping state is active
##
## @param delta: Time elapsed since the last frame
func physics_update(delta: float) -> void:
	jump_buffer_time -= delta

	# Update movement component with current input (air movement handled by movement component)
	movement_component.set_input_direction(current_movement_input)

	_check_transitions()
	was_on_floor_last_frame = player.is_on_floor()


## Handle movement input in jumping state
func handle_movement_input(direction: Vector2) -> void:
	current_movement_input = direction


## Handle jump input in jumping state (for jump buffering)
func handle_jump_input() -> void:
	jump_buffer_time = JUMP_BUFFER_DURATION


## Handle sprint start in jumping state
func handle_sprint_started() -> void:
	pass


## Handle crouch start in jumping state
func handle_crouch_started() -> void:
	pass


## Handle sprint stop in jumping state (no-op)
func handle_sprint_stopped() -> void:
	pass


## Handle crouch stop in jumping state (no-op)
func handle_crouch_stopped() -> void:
	pass


## Check for state transitions when jumping
func _check_transitions() -> void:
	if player.is_on_floor() and player.velocity.y <= 0.0:
		_handle_landing()


## Handle landing and determine appropriate state transition
func _handle_landing() -> void:
	if jump_buffer_time > 0.0:
		player.velocity.y = movement_component.jump_velocity
		jump_buffer_time = 0.0
		return

	# Determine next state based on current input and actions
	var input_magnitude: float = current_movement_input.length()

	if Input.is_action_pressed("crouch"):
		state_finished.emit("crouching")
		return

	# Check movement state
	if input_magnitude <= DEADZONE_THRESHOLD:
		state_finished.emit("idle")
	elif Input.is_action_pressed("sprint"):
		state_finished.emit("running")
	else:
		state_finished.emit("walking")
