extends CharacterBody3D
class_name PlayerController

@onready var movement_component: MovementComponent = $MovementComponent
@onready var camera_component = $CameraComponent
@onready var input_component = $InputComponent


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Connect components
	input_component.movement_input.connect(_on_movement_input)
	input_component.look_input.connect(_on_look_input)
	input_component.jump_input.connect(_on_jump_input)
	input_component.sprint_input.connect(_on_sprint_input)
	input_component.crouch_input.connect(_on_crouch_input)


func _physics_process(delta: float) -> void:
	movement_component.process_movement(delta)
	camera_component.process_camera_effects(delta, velocity)
	move_and_slide()


func _on_movement_input(direction: Vector2) -> void:
	movement_component.set_input_direction(direction)


func _on_look_input(mouse_delta: Vector2) -> void:
	camera_component.handle_look_input(mouse_delta)


func _on_jump_input() -> void:
	if is_on_floor():
		movement_component.jump()


func _on_sprint_input(is_sprinting: bool) -> void:
	movement_component.set_sprinting(is_sprinting)


func _on_crouch_input(is_crouching: bool) -> void:
	movement_component.set_crouching(is_crouching)
	# Only update camera if crouch state actually changed
	if movement_component.is_crouching == is_crouching:
		camera_component.set_crouching(is_crouching)
