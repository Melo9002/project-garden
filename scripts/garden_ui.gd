class_name GardenUI
extends CanvasLayer

signal pause_requested
signal viewpoint_requested
@onready var status: Label = $Panel/Margin/Column/Status
@onready var camera_marker: ColorRect = $CameraTrack/Marker
@onready var pixy_name: Label = $PixyInspector/Margin/Column/Name
@onready var pixy_details: Label = $PixyInspector/Margin/Column/Details

func _ready() -> void:
	$Panel/Margin/Column/PauseButton.pressed.connect(pause_requested.emit)
	$Panel/Margin/Column/ViewpointButton.pressed.connect(viewpoint_requested.emit)

func set_status(text: String) -> void:
	status.text = text

func set_camera_position(normalized_position: float) -> void:
	var travel := maxf(0.0, $CameraTrack.size.x - camera_marker.size.x - 16.0)
	camera_marker.position.x = 8.0 + travel * clampf(normalized_position, 0.0, 1.0)

func show_pixy(state: PixyState) -> void:
	pixy_name.text = state.element
	pixy_details.text = "Element  %s\nMood     %s\nActivity  %s" % [state.element, state.mood, state.get_activity()]

