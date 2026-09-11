class_name GardenUI
extends CanvasLayer

signal pause_requested
signal viewpoint_requested
signal flower_placement_requested
signal save_requested
signal load_requested
signal debug_speed_requested(multiplier: float)
signal debug_step_requested
signal debug_low_energy_requested
signal debug_low_curiosity_requested
@onready var status: Label = $Panel/Margin/Column/Status
@onready var camera_marker: ColorRect = $CameraTrack/Marker
@onready var pixy_name: Label = $PixyInspector/Margin/Column/Name
@onready var pixy_details: Label = $PixyInspector/Margin/Column/Details
@onready var notice: Label = $Panel/Margin/Column/Notice

func _ready() -> void:
	$Panel/Margin/Column/PauseButton.pressed.connect(pause_requested.emit)
	$Panel/Margin/Column/ViewpointButton.pressed.connect(viewpoint_requested.emit)
	$Panel/Margin/Column/FlowerButton.pressed.connect(flower_placement_requested.emit)
	$Panel/Margin/Column/SaveLoad/SaveButton.pressed.connect(save_requested.emit)
	$Panel/Margin/Column/SaveLoad/LoadButton.pressed.connect(load_requested.emit)
	for button in $DebugPanel/Margin/Column/Speeds.get_children():
		button.pressed.connect(_debug_speed_pressed.bind(float(button.get_meta("speed"))))
	$DebugPanel/Margin/Column/StepMinute.pressed.connect(debug_step_requested.emit)
	$DebugPanel/Margin/Column/SelectedTests/LowEnergy.pressed.connect(debug_low_energy_requested.emit)
	$DebugPanel/Margin/Column/SelectedTests/LowCuriosity.pressed.connect(debug_low_curiosity_requested.emit)

func set_status(text: String) -> void:
	status.text = text

func set_camera_position(normalized_position: float) -> void:
	var travel := maxf(0.0, $CameraTrack.size.x - camera_marker.size.x - 16.0)
	camera_marker.position.x = 8.0 + travel * clampf(normalized_position, 0.0, 1.0)

func show_pixy(state: PixyState) -> void:
	pixy_name.text = state.element
	pixy_details.text = "Mood       %s\nActivity    %s\nEnergy      %s\nComfort     %s\nCuriosity   %s" % [
		state.get_mood(),
		state.get_activity(),
		state.describe_need(state.energy),
		state.describe_need(state.comfort),
		state.describe_need(state.curiosity),
	]

func show_notice(text: String) -> void:
	notice.text = text

func set_debug_visible(value: bool) -> void:
	$DebugPanel.visible = value

func update_debug(elapsed: float, speed: float, paused: bool, selected: PixyState) -> void:
	var run_state := "PAUSED" if paused else "RUNNING %.0fx" % speed
	$DebugPanel/Margin/Column/RunState.text = "%s  ·  SIM %.1fs" % [run_state, elapsed]
	if selected == null:
		$DebugPanel/Margin/Column/RawValues.text = "Select a pixy to inspect exact values."
	else:
		$DebugPanel/Margin/Column/RawValues.text = "%s  E %.3f  C %.3f  Q %.3f\n%s" % [
			selected.element,
			selected.energy,
			selected.comfort,
			selected.curiosity,
			selected.activity,
		]

func _debug_speed_pressed(multiplier: float) -> void:
	debug_speed_requested.emit(multiplier)

