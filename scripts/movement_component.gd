extends Node
class_name MovementComponent

@export_category("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var crouch_speed: float = 2.5
@export var jump_velocity: float = 5.0
@export var gravity: float = 13.0

@export_category("Collision Settings")
@export var standing_height: float = 2.0
@export var crouch_height: float = 1.0
@export var collision_transition_speed: float = 8.0

var current_speed: float
var input_direction: Vector2
var is_sprinting: bool = false
var is_crouching: bool = false

@onready var player: CharacterBody3D = get_parent()
@onready var camera_controller: Node3D = player.get_node("CameraComponent/CameraController")
@onready var collision_shape: CollisionShape3D = player.get_node("StandingCollision")
@onready var capsule_shape: CapsuleShape3D = collision_shape.shape

var standing_capsule_height: float
var crouch_capsule_height: float
var standing_collision_position: Vector3
var crouch_collision_position: Vector3


func _ready() -> void:
	current_speed = walk_speed
	_setup_collision_dimensions()


func set_input_direction(direction: Vector2) -> void:
	input_direction = direction


## Sets the sprinting state and updates current movement speed
func set_sprinting(sprinting: bool) -> void:
	is_sprinting = sprinting
	_update_movement_speed()


## Sets the crouching state and updates current movement speed
func set_crouching(crouching: bool) -> void:
	# Only allow standing up if there's enough space
	if is_crouching and not crouching and not _can_stand_up():
		return
	
	is_crouching = crouching
	_update_movement_speed()


## Updates the current movement speed based on player state
func _update_movement_speed() -> void:
	if is_crouching:
		current_speed = crouch_speed
	elif is_sprinting:
		current_speed = sprint_speed
	else:
		current_speed = walk_speed


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
	var target_height: float = crouch_capsule_height if is_crouching else standing_capsule_height
	var target_position: Vector3 = crouch_collision_position if is_crouching else standing_collision_position
	
	# Smoothly interpolate capsule height
	capsule_shape.height = lerp(capsule_shape.height, target_height, delta * collision_transition_speed)
	
	# Smoothly interpolate collision position
	collision_shape.position = collision_shape.position.lerp(target_position, delta * collision_transition_speed)


## Checks if the player can stand up from crouching position
func _can_stand_up() -> bool:
	if not is_crouching:
		return true
	
	# Create a temporary shape query for standing collision
	var space_state = player.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var temp_shape = CapsuleShape3D.new()
	temp_shape.height = standing_capsule_height
	temp_shape.radius = capsule_shape.radius
	
	query.shape = temp_shape
	query.transform = Transform3D(Basis.IDENTITY, player.global_position + standing_collision_position)
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]
	
	var result = space_state.intersect_shape(query)
	return result.is_empty()


## Makes the player jump if on the floor and not crouching
func jump() -> void:
	if player.is_on_floor() and not is_crouching:
		player.velocity.y = jump_velocity


func process_movement(delta: float) -> void:
	# Update collision capsule based on crouch state
	_update_collision_capsule(delta)
	
	# Apply gravity
	if not player.is_on_floor():
		player.velocity.y -= gravity * delta
	
	# Calculate movement direction in world space
	var direction = (camera_controller.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	
	# Apply movement based on ground state
	if player.is_on_floor():
		if direction:
			player.velocity.x = direction.x * current_speed
			player.velocity.z = direction.z * current_speed
		else:
			player.velocity.x = lerp(player.velocity.x, direction.x * current_speed, delta * 7.0)
			player.velocity.z = lerp(player.velocity.z, direction.z * current_speed, delta * 7.0)
	else:
		# Air control
		player.velocity.x = lerp(player.velocity.x, direction.x * current_speed, delta * 3.0)
		player.velocity.z = lerp(player.velocity.z, direction.z * current_speed, delta * 3.0)
