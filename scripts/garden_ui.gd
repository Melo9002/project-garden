class_name GardenUI
extends CanvasLayer

signal pause_requested
signal viewpoint_requested
@onready var status: Label = $Panel/Margin/Column/Status

func _ready() -> void:
	$Panel/Margin/Column/PauseButton.pressed.connect(pause_requested.emit)
	$Panel/Margin/Column/ViewpointButton.pressed.connect(viewpoint_requested.emit)

func set_status(text: String) -> void:
	status.text = text

