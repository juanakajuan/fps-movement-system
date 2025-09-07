## Idle state for the player when not moving
##
## IdleState handles the player behavior when no movement input is detected.
## It applies smooth deceleration and monitors for input to transition to other states.
extends State
class_name IdleState

const DECELERATION_RATE: float = 7.0
const DEADZONE_THRESHOLD: float = 0.1

var movement_component: MovementComponent
var player: CharacterBody3D


## Initialize the idle state
func _init() -> void:
	super("idle")


## Called when entering the idle state
func enter(_previous_state: State = null) -> void:
	player = state_machine.get_owner() as CharacterBody3D
	movement_component = player.movement_component

	# Clear any movement input when entering idle
	movement_component.set_input_direction(Vector2.ZERO)


## Called when exiting the idle state
func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	# Apply smooth deceleration when idle
	if player.is_on_floor():
		player.velocity.x = lerp(player.velocity.x, 0.0, delta * DECELERATION_RATE)
		player.velocity.z = lerp(player.velocity.z, 0.0, delta * DECELERATION_RATE)

	_check_transitions()


## Handle input events in idle state
func handle_input(event: InputEvent) -> void:
	# Jump input while idle
	if event.is_action_pressed("jump") and player.is_on_floor():
		movement_component.jump()
		state_finished.emit("jumping")


## Check for state transitions when idle
func _check_transitions() -> void:
	# Check for movement input
	var move_input: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"), Input.get_axis("move_forward", "move_backward")
	)

	if move_input.length() > DEADZONE_THRESHOLD:
		if Input.is_action_pressed("crouch"):
			state_finished.emit("crouching")
		elif Input.is_action_pressed("sprint"):
			state_finished.emit("running")
		else:
			state_finished.emit("walking")

	# Check for crouch input while idle
	if Input.is_action_pressed("crouch"):
		state_finished.emit("crouching")
