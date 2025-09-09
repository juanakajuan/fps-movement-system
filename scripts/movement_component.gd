## Movement component that handles all player movement mechanics
##
## MovementComponent provides a complete FPS movement system including walking,
## sprinting, crouching, jumping, and dynamic collision handling. Features smooth
## transitions between movement states and realistic physics-based movement.
extends Node
class_name MovementComponent

@export_category("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var jump_velocity: float = 7.0
@export var gravity: float = 20.0

@export_category("Collision Settings")
@export var standing_height: float = 2.0
@export var crouch_height: float = 1.0
@export var collision_transition_speed: float = 8.0

var current_speed: float
var input_direction: Vector2
var _collision_is_crouching: bool = false
var _wants_to_stand: bool = false

@onready var player: CharacterBody3D = get_parent()
@onready var camera_controller: Node3D = player.get_node("CameraComponent/CameraController")
@onready var collision_shape: CollisionShape3D = player.get_node("StandingCollision")
@onready var capsule_shape: CapsuleShape3D = collision_shape.shape

var standing_capsule_height: float
var crouch_capsule_height: float
var standing_collision_position: Vector3
var crouch_collision_position: Vector3


## Initializes movement parameters and collision dimensions
func _ready() -> void:
	current_speed = walk_speed
	_setup_collision_dimensions()


## Sets the input direction for movement calculation
##
## @param direction Normalized direction vector from input
func set_input_direction(direction: Vector2) -> void:
	input_direction = direction


## Sets the movement speed directly (called by states)
##
## @param speed The desired movement speed
func set_movement_speed(speed: float) -> void:
	current_speed = speed


## Gets current movement state information
##
## @return Dictionary with movement state data
func get_movement_state() -> Dictionary:
	return {
		"speed": current_speed,
		"velocity": player.velocity,
		"is_on_floor": player.is_on_floor(),
		"input_direction": input_direction
	}


## Sets up the initial collision dimensions for standing and crouching
func _setup_collision_dimensions() -> void:
	standing_capsule_height = standing_height
	crouch_capsule_height = crouch_height
	standing_collision_position = collision_shape.position
	crouch_collision_position = Vector3(
		standing_collision_position.x,
		standing_collision_position.y - (standing_height - crouch_height) * 0.5,
		standing_collision_position.z
	)


## Smoothly updates the collision capsule size and position based on crouch state
func _update_collision_capsule(delta: float) -> void:
	var target_height: float = crouch_capsule_height if _collision_is_crouching else standing_capsule_height
	var target_position: Vector3 = (
		crouch_collision_position if _collision_is_crouching else standing_collision_position
	)

	# Smoothly interpolate capsule height
	capsule_shape.height = lerp(
		capsule_shape.height, target_height, delta * collision_transition_speed
	)

	# Smoothly interpolate collision position
	collision_shape.position = collision_shape.position.lerp(
		target_position, delta * collision_transition_speed
	)


## Checks if the player can stand up from crouching position
func _can_stand_up() -> bool:
	if not _collision_is_crouching:
		return true

	# Create a temporary shape query for standing collision
	var space_state: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	var temp_shape: CapsuleShape3D = CapsuleShape3D.new()
	temp_shape.height = standing_capsule_height
	temp_shape.radius = capsule_shape.radius

	query.shape = temp_shape
	query.transform = Transform3D(
		Basis.IDENTITY, player.global_position + standing_collision_position
	)
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]

	var result: Array[Dictionary] = space_state.intersect_shape(query)
	var can_stand: bool = result.is_empty()
	
	print("Can stand up check: ", can_stand, " (found ", result.size(), " collisions)")
	if not can_stand and result.size() > 0:
		print("Collision objects: ", result)
	
	return can_stand


## Makes the player jump if on the floor and not crouching
## Makes the player jump if conditions are met
## Only allows jumping when on floor and not crouching
func jump() -> void:
	if player.is_on_floor() and not _collision_is_crouching:
		player.velocity.y = jump_velocity


## Forces the collision state without ceiling checks (used for state transitions)
##
## @param crouching Whether the player should be in crouch collision mode
func force_collision_crouching(crouching: bool) -> void:
	print("Forcing collision crouching to: ", crouching)
	_collision_is_crouching = crouching


## Sets the crouching collision state (called by states)
##
## @param crouching Whether the player should be in crouch collision mode
func set_collision_crouching(crouching: bool) -> void:
	print("Setting collision crouching to: ", crouching, " (was: ", _collision_is_crouching, ")")
	
	# If trying to stand up, check for ceiling collision
	if _collision_is_crouching and not crouching:
		_wants_to_stand = true
		if not _can_stand_up():
			print("Cannot stand up - blocked by ceiling, collision stays crouched")
			# Don't change the collision state, will retry each frame
			return
		else:
			print("Clear to stand up")
			_wants_to_stand = false
	else:
		_wants_to_stand = false
	
	_collision_is_crouching = crouching
	print("Collision crouching now: ", _collision_is_crouching)


## Main movement processing function called every physics frame
## Handles collision updates, gravity, and movement calculations
##
## @param delta Physics time step
func process_movement(delta: float) -> void:
	# Check if we can stand up when we want to but couldn't before
	if _wants_to_stand and _collision_is_crouching and _can_stand_up():
		print("Can now stand up - ceiling clear!")
		_collision_is_crouching = false
		_wants_to_stand = false
	
	# Update collision capsule based on crouch state
	_update_collision_capsule(delta)

	# Apply gravity when airborne
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta

	# Calculate movement direction in world space relative to camera
	var direction: Vector3 = (
		(camera_controller.transform.basis * Vector3(input_direction.x, 0, input_direction.y))
		. normalized()
	)

	# Apply different movement behaviors based on ground contact
	if player.is_on_floor():
		# Ground movement with immediate response or smooth deceleration
		if direction:
			player.velocity.x = direction.x * current_speed
			player.velocity.z = direction.z * current_speed
		else:
			# Smooth deceleration when no input
			player.velocity.x = lerp(player.velocity.x, direction.x * current_speed, delta * 7.0)
			player.velocity.z = lerp(player.velocity.z, direction.z * current_speed, delta * 7.0)
	else:
		# Air control with reduced responsiveness
		player.velocity.x = lerp(player.velocity.x, direction.x * current_speed, delta * 3.0)
		player.velocity.z = lerp(player.velocity.z, direction.z * current_speed, delta * 3.0)
