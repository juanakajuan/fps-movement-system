## Camera component handling FPS camera controls and visual effects
##
## CameraComponent manages the first-person camera system including mouse look,
## head bobbing, dynamic FOV changes, and crouching transitions. Provides smooth
## and responsive camera movement with realistic visual feedback.
extends Node
class_name CameraComponent

@export var sensitivity: float = 0.003

@export_category("Head Bob")
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.08
var head_bob_timer: float = 0.0

@export_category("Player FOV")
@export var base_fov: float = 75.0
@export var fov_change: float = 1.5

@export_category("Crouch Camera")
@export var crouch_height_offset: float = -0.5
@export var crouch_transition_speed: float = 8.0

var is_crouching: bool = false
var standing_position: Vector3
var crouch_position: Vector3

@onready var camera_controller: Node3D = $%CameraController
@onready var camera: Camera3D = $%Camera3D
@onready var player: CharacterBody3D = get_parent()
@onready var movement_component: MovementComponent = player.get_node("MovementComponent")


## Initializes camera positions and settings
func _ready() -> void:
	standing_position = camera_controller.position
	crouch_position = standing_position + Vector3(0, crouch_height_offset, 0)

	reset_physics_interpolation()


## Processes mouse input for camera rotation with clamped vertical rotation
##
## @param mouse_delta Mouse movement delta from input events
func handle_look_input(mouse_delta: Vector2) -> void:
	camera_controller.rotate_y(-mouse_delta.x * sensitivity)
	camera.rotate_x(-mouse_delta.y * sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40.0), deg_to_rad(60.0))


## Updates all camera effects each frame
##
## @param delta Time elapsed since last frame
## @param velocity Current player velocity for effect calculations
func process_camera_effects(delta: float, velocity: Vector3) -> void:
	_update_head_bob(delta, velocity)
	_update_fov(delta, velocity)
	_update_crouch_camera(delta)


## Updates head bobbing effect based on movement
##
## @param delta Time elapsed since last frame
## @param velocity Current player velocity
func _update_head_bob(delta: float, velocity: Vector3) -> void:
	head_bob_timer += delta * velocity.length() * float(player.is_on_floor())
	camera.transform.origin = _calculate_headbob(head_bob_timer)


## Updates field of view based on movement speed
##
## @param delta Time elapsed since last frame
## @param velocity Current player velocity
func _update_fov(delta: float, velocity: Vector3) -> void:
	var velocity_clamped: float = clamp(velocity.length(), 0.5, movement_component.sprint_speed * 2)
	var target_fov: float = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


## Calculates head bob offset based on time
##
## @param time Current head bob timer value
## @return Vector3 offset for head bob effect
func _calculate_headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * bob_frequency) * bob_amplitude
	pos.x = cos(time * bob_frequency / 2) * bob_amplitude
	return pos


## Sets the crouching state and triggers camera height transition
func set_crouching(crouching: bool) -> void:
	is_crouching = crouching


## Smoothly transitions camera height based on crouch state
func _update_crouch_camera(delta: float) -> void:
	var target_position: Vector3 = crouch_position if is_crouching else standing_position
	camera_controller.position = camera_controller.position.lerp(
		target_position, delta * crouch_transition_speed
	)
