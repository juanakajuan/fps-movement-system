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

@onready var camera_controller: Node3D = $CameraController
@onready var camera: Camera3D = $CameraController/Camera3D
@onready var player: CharacterBody3D = get_parent()


func handle_look_input(mouse_delta: Vector2) -> void:
	camera_controller.rotate_y(-mouse_delta.x * sensitivity)
	camera.rotate_x(-mouse_delta.y * sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40.0), deg_to_rad(60.0))


func process_camera_effects(delta: float, velocity: Vector3) -> void:
	_update_head_bob(delta, velocity)
	_update_fov(delta, velocity)


func _update_head_bob(delta: float, velocity: Vector3) -> void:
	head_bob_timer += delta * velocity.length() * float(player.is_on_floor())
	camera.transform.origin = _calculate_headbob(head_bob_timer)


func _update_fov(delta: float, velocity: Vector3) -> void:
	var velocity_clamped = clamp(velocity.length(), 0.5, 8.0 * 2) # sprint_speed * 2
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)


func _calculate_headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_frequency) * bob_amplitude
	pos.x = cos(time * bob_frequency / 2) * bob_amplitude
	return pos
