class_name GardenPlacement
extends Node3D
## One-object placement experiment. Replace numeric rules with surface data when needed.

signal flower_placed(ground_position: Vector2)

@export var flower_scene: PackedScene
@export var reachable_bounds := Rect2(-7.0, -2.4, 14.0, 4.5)
@export var water_center := Vector2(0.8, -2.7)
@export var water_radius := Vector2(2.55, 0.72)
@onready var camera: Camera3D = $"../CameraRig/Camera3D"
@onready var placed_objects: Node3D = $"../Interactables"

var preview: FlowerPatch
var placement_valid := false

func begin_flower_placement() -> void:
	cancel_placement()
	preview = flower_scene.instantiate() as FlowerPatch
	assert(preview != null, "Flower scene must use FlowerPatch at its root")
	add_child(preview)

func _process(_delta: float) -> void:
	if preview == null:
		return
	var mouse := get_viewport().get_mouse_position()
	var from := camera.project_ray_origin(mouse)
	var to := from + camera.project_ray_normal(mouse) * 50.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		preview.visible = false
		placement_valid = false
		return
	preview.visible = true
	var point: Vector3 = hit.position
	preview.global_position = Vector3(point.x, 0.12, point.z)
	placement_valid = _is_valid_ground(Vector2(point.x, point.z))
	preview.show_placement_preview(placement_valid)

func _unhandled_input(event: InputEvent) -> void:
	if preview == null:
		return
	if event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed):
		cancel_placement()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if placement_valid and preview.visible:
			_place_preview()
		get_viewport().set_input_as_handled()

func cancel_placement() -> void:
	if preview != null:
		preview.queue_free()
		preview = null

func _place_preview() -> void:
	var placed_position := Vector2(preview.position.x, preview.position.z)
	remove_child(preview)
	placed_objects.add_child(preview)
	preview.finish_placement()
	preview = null
	flower_placed.emit(placed_position)

func _is_valid_ground(point: Vector2) -> bool:
	if not reachable_bounds.has_point(point):
		return false
	var lake_distance := (point - water_center) / water_radius
	return lake_distance.length_squared() > 1.0

