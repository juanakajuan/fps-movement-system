## Walking state for the player during normal movement
##
## WalkingState handles player movement at normal walking speed when movement input
## is detected but sprint is not pressed. It manages transitions to running, idle,
## and other movement states based on player input.
extends State
class_name WalkingState

const DEADZONE_THRESHOLD: float = 0.1

var movement_component: MovementComponent
var player: CharacterBody3D
var current_movement_input: Vector2 = Vector2.ZERO


## Initialize the walking state
func _init() -> void:
	super("walking")


## Called when entering the walking state
func enter(_previous_state: State = null) -> void:
	player = state_machine.get_owner() as CharacterBody3D
	movement_component = player.movement_component
	
	# Set walking speed
	movement_component.set_movement_speed(movement_component.walk_speed)


## Called when exiting the walking state
func exit() -> void:
	pass


func physics_update(_delta: float) -> void:
	# Update movement component with current input
	movement_component.set_input_direction(current_movement_input)
	
	_check_transitions()


## Handle movement input in walking state
func handle_movement_input(direction: Vector2) -> void:
	current_movement_input = direction


## Handle jump input in walking state
func handle_jump_input() -> void:
	if player.is_on_floor():
		movement_component.jump()
		state_finished.emit("jumping")


## Handle sprint start in walking state
func handle_sprint_started() -> void:
	if current_movement_input.length() > DEADZONE_THRESHOLD:
		state_finished.emit("running")


## Handle crouch start in walking state
func handle_crouch_started() -> void:
	state_finished.emit("crouching")


## Handle sprint stop in walking state (no-op, already walking)
func handle_sprint_stopped() -> void:
	pass


## Handle crouch stop in walking state (no-op)
func handle_crouch_stopped() -> void:
	pass


## Check for state transitions when walking
func _check_transitions() -> void:
	# No movement input - go to idle
	if current_movement_input.length() <= DEADZONE_THRESHOLD:
		state_finished.emit("idle")
		return

	# Check for crouch input while moving
	if Input.is_action_pressed("crouch"):
		state_finished.emit("crouching")
		return

	# Check for sprint input while moving
	if Input.is_action_pressed("sprint"):
		state_finished.emit("running")
		return
