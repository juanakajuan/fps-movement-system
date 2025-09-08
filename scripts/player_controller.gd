## Main player controller that coordinates all player components
##
## PlayerController acts as the central hub for the FPS player system, managing
## communication between the movement, camera, and input components. It handles
## the physics body and coordinates all player actions through a component-based
## architecture.
extends CharacterBody3D
class_name PlayerController

@onready var movement_component: MovementComponent = $%MovementComponent
@onready var camera_component: CameraComponent = $%CameraComponent
@onready var input_component: InputComponent = $%InputComponent
@onready var state_machine: StateMachine = StateMachine.new(self)


## Initializes the player controller and sets up component connections
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Setup state machine
	var idle_state: IdleState = IdleState.new()
	var walking_state: WalkingState = WalkingState.new()
	var running_state: RunningState = RunningState.new()
	
	state_machine.add_state("idle", idle_state)
	state_machine.add_state("walking", walking_state)
	state_machine.add_state("running", running_state)
	state_machine.start("idle")

	# Connect components
	input_component.movement_input.connect(_on_movement_input)
	input_component.look_input.connect(_on_look_input)
	input_component.jump_pressed.connect(_on_jump_pressed)
	input_component.sprint_started.connect(_on_sprint_started)
	input_component.sprint_stopped.connect(_on_sprint_stopped)
	input_component.crouch_started.connect(_on_crouch_started)
	input_component.crouch_stopped.connect(_on_crouch_stopped)


## Processes movement and camera effects every physics frame
func _physics_process(delta: float) -> void:
	state_machine.physics_update(delta)
	movement_component.process_movement(delta)
	camera_component.process_camera_effects(delta, velocity)
	move_and_slide()


## Signal handler for movement input from InputComponent
## Forwards to state machine for processing
##
## @param direction Movement direction as Vector2 (x: left/right, y: forward/back)
func _on_movement_input(direction: Vector2) -> void:
	state_machine.handle_movement_input(direction)


## Signal handler for mouse look input from InputComponent
##
## @param mouse_delta Mouse movement delta for camera rotation
func _on_look_input(mouse_delta: Vector2) -> void:
	camera_component.handle_look_input(mouse_delta)


## Signal handler for jump input from InputComponent
func _on_jump_pressed() -> void:
	state_machine.handle_jump_input()


## Signal handler for sprint started from InputComponent
func _on_sprint_started() -> void:
	state_machine.handle_sprint_started()


## Signal handler for sprint stopped from InputComponent
func _on_sprint_stopped() -> void:
	state_machine.handle_sprint_stopped()


## Signal handler for crouch started from InputComponent
func _on_crouch_started() -> void:
	state_machine.handle_crouch_started()


## Signal handler for crouch stopped from InputComponent
func _on_crouch_stopped() -> void:
	state_machine.handle_crouch_stopped()


func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)
