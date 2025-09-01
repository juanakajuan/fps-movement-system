extends Node
class_name MovementComponent

@export_category("Movement Speed")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5

var current_speed: float
var input_direction: Vector2
var is_sprinting: bool = false

@onready var player: CharacterBody3D = get_parent()
@onready var camera_controller: Node3D = player.get_node("CameraComponent/CameraController")


func _ready() -> void:
	current_speed = walk_speed


func set_input_direction(direction: Vector2) -> void:
	input_direction = direction


func set_sprinting(sprinting: bool) -> void:
	is_sprinting = sprinting
	current_speed = sprint_speed if sprinting else walk_speed


func jump() -> void:
	if player.is_on_floor():
		player.velocity.y = jump_velocity


func process_movement(delta: float) -> void:
	# Apply gravity
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * delta
	
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
