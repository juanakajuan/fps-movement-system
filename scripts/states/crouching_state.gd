extends State
class_name CrouchingState

## TODO: Look into making this static or global since it is used by the other states.
const DEADZONE_THRESHOLD: float = 0.1

var movement_component: MovementComponent
var player: CharacterBody3D
var current_movement_input: Vector2 = Vector2.ZERO


## Initialize the crouching state
func _init() -> void:
	super("crouching")


## Called when entering the crouching state
func enter(_previous_state: State = null) -> void:
	pass


## Called when exiting the crouching state
func exit() -> void:
	pass


## Called every frame while the crouching state is active
##
## @param _delta: Time elapsed since the last frame
func physics_update(_delta: float) -> void:
	pass


## Handle movement input in crouching state
func handle_movement_input(direction: Vector2) -> void:
	pass


## Handle jump input in crouching state
func handle_jump_input() -> void:
	pass


## Handle sprint start in crouching state
func handle_sprint_started() -> void:
	pass


## Handle crouch start in crouching state
func handle_crouch_started() -> void:
	pass


## Handle sprint stop in crouching state (no-op)
func handle_sprint_stopped() -> void:
	pass


## Handle crouch stop in crouching state (no-op)
func handle_crouch_stopped() -> void:
	pass


## Check for state transitions when crouching
func _check_transitions() -> void:
	pass
