## FPS counter UI component
##
## Simple UI overlay that displays the current frames per second in real-time.
extends CanvasLayer


## Initializes the FPS counter display
func _ready() -> void:
	pass


## Updates the FPS display every frame
##
## @param _delta Time elapsed since last frame (unused)
func _process(_delta: float) -> void:
	$Label.text = str(int(Engine.get_frames_per_second()))
