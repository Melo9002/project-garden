class_name GardenPlacement
extends Node3D
## One-object placement experiment. Replace numeric rules with surface data when needed.

signal flower_placed(ground_position: Vector2)

@export var flower_scene: PackedScene
@export var garden_definition: GardenDefinition
@onready var camera: Camera3D = $"../CameraRig/Camera3D"
@onready var placed_objects: Node3D = $"../Interactables"

var preview: FlowerPatch
var placement_valid := false

func begin_flower_placement() -> void:
	assert(garden_definition != null, "GardenPlacement requires a GardenDefinition")
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
	preview.global_position = Vector3(point.x, garden_definition.surface_height_at(Vector2(point.x, point.z)) + 0.06, point.z)
	placement_valid = garden_definition.can_place_flower(Vector2(point.x, point.z))
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

func restore_flowers(positions: Array[Vector2]) -> void:
	for child in placed_objects.get_children():
		if child is FlowerPatch:
			child.queue_free()
	for ground_position in positions:
		var flower := flower_scene.instantiate() as FlowerPatch
		assert(flower != null, "Flower scene must use FlowerPatch at its root")
		placed_objects.add_child(flower)
		flower.position = Vector3(ground_position.x, garden_definition.surface_height_at(ground_position) + 0.06, ground_position.y)
		flower.finish_placement()

func _place_preview() -> void:
	var placed_position := Vector2(preview.position.x, preview.position.z)
	remove_child(preview)
	placed_objects.add_child(preview)
	preview.finish_placement()
	preview = null
	flower_placed.emit(placed_position)
