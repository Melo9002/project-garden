class_name GardenCamera
extends Node3D
## Smooth side-scrolling camera for the authored garden strip.

signal position_changed(normalized_position: float)

@export_range(0.0, 20.0, 0.1) var pan_speed: float = 5.5
@export_range(0.0, 30.0, 0.1) var smoothing: float = 10.0
@export var horizontal_limits := Vector2(-6.5, 6.5)
@export var zoom_limits := Vector2(7.2, 11.5)
@export var look_height: float = 0.45
@export_range(0.001, 0.02, 0.001) var drag_sensitivity: float = 0.008
@onready var camera: Camera3D = $Camera3D

var target_x: float = 0.0
var target_distance: float = 9.0
var dragging := false

func _ready() -> void:
	target_x = position.x
	target_distance = camera.position.z
	_apply_pose(1.0)

func _process(delta: float) -> void:
	var axis := Input.get_axis("camera_left", "camera_right")
	if not is_zero_approx(axis):
		target_x += axis * pan_speed * delta
	target_x = clampf(target_x, horizontal_limits.x, horizontal_limits.y)
	var weight := 1.0 - exp(-smoothing * delta)
	position.x = lerpf(position.x, target_x, weight)
	_apply_pose(weight)
	position_changed.emit(get_normalized_position())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			get_viewport().set_input_as_handled()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_distance = clampf(target_distance - 0.7, zoom_limits.x, zoom_limits.y)
			get_viewport().set_input_as_handled()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_distance = clampf(target_distance + 0.7, zoom_limits.x, zoom_limits.y)
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and dragging:
		target_x -= event.relative.x * target_distance * drag_sensitivity
		target_x = clampf(target_x, horizontal_limits.x, horizontal_limits.y)
		get_viewport().set_input_as_handled()

func focus_normalized(value: float) -> void:
	target_x = lerpf(horizontal_limits.x, horizontal_limits.y, clampf(value, 0.0, 1.0))

func get_normalized_position() -> float:
	return inverse_lerp(horizontal_limits.x, horizontal_limits.y, position.x)

func _apply_pose(weight: float) -> void:
	camera.position.z = lerpf(camera.position.z, target_distance, weight)
	camera.look_at(Vector3(position.x, look_height, -0.4), Vector3.UP)
