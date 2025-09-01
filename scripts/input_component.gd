extends Node
class_name InputComponent

signal movement_input(direction: Vector2)
signal look_input(mouse_delta: Vector2)
signal jump_input()
signal sprint_input(is_sprinting: bool)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_input.emit(event.relative)

func _process(_delta: float) -> void:
	# Movement input
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		movement_input.emit(input_dir)

	# Jump input
	if Input.is_action_just_pressed("jump"):
		jump_input.emit()

	# Sprint input
	var is_sprinting: bool = Input.is_action_pressed("sprint")
	sprint_input.emit(is_sprinting)

