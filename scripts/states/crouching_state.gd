extends State
class_name CrouchingState

var movement_component: MovementComponent
var camera_component: CameraComponent
var player: CharacterBody3D
var current_movement_input: Vector2 = Vector2.ZERO


## Initialize the crouching state
func _init() -> void:
	super("crouching")


## Called when entering the crouching state
func enter(_previous_state: State = null) -> void:
	player = state_machine.get_owner() as CharacterBody3D
	movement_component = player.movement_component
	camera_component = player.camera_component
	
	print("Entering crouching state")
	# Set crouch speed and enable collision crouching
	movement_component.set_movement_speed(movement_component.crouch_speed)
	movement_component.set_collision_crouching(true)
	camera_component.set_crouching(true)


## Called when exiting the crouching state
func exit() -> void:
	print("Exiting crouching state")
	# Try to disable collision crouching, but respect ceiling checks
	movement_component.set_collision_crouching(false)
	camera_component.set_crouching(false)


## Called every frame while the crouching state is active
##
## @param _delta: Time elapsed since the last frame
func physics_update(_delta: float) -> void:
	# Update movement component with current input
	movement_component.set_input_direction(current_movement_input)
	
	_check_transitions()


## Handle movement input in crouching state
func handle_movement_input(direction: Vector2) -> void:
	current_movement_input = direction


## Handle jump input in crouching state (no-op, can't jump while crouching)
func handle_jump_input() -> void:
	pass


## Handle sprint start in crouching state (no-op, can't sprint while crouching)
func handle_sprint_started() -> void:
	pass


## Handle crouch start in crouching state (already crouching)
func handle_crouch_started() -> void:
	pass


## Handle sprint stop in crouching state (no-op)
func handle_sprint_stopped() -> void:
	pass


## Handle crouch stop in crouching state
func handle_crouch_stopped() -> void:
	# Transition based on current movement input
	var input_magnitude: float = current_movement_input.length()
	
	if input_magnitude <= DEADZONE_THRESHOLD:
		state_finished.emit("idle")
	else:
		state_finished.emit("walking")


## Check for state transitions when crouching
func _check_transitions() -> void:
	# Only transition when crouch is released (handled in handle_crouch_stopped)
	pass
