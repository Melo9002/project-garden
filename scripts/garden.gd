extends Node3D
## Connects authored scenes to the independent simulation model.

@export var pixy_scene: PackedScene
@export_range(1.0, 60.0, 1.0) var simulation_rate: float = 30.0
@export var camera_look_target: Vector3 = Vector3(0, 0.1, 0)
@onready var pixy_container: Node3D = $Pixies
@onready var spawn_container: Node3D = $PixySpawns
@onready var camera: Camera3D = $CameraRig/Camera3D
@onready var viewpoint_container: Node3D = $CameraRig/Viewpoints
@onready var ui: CanvasLayer = $GardenUI

var simulation := GardenSimulation.new()
var views: Array[PixyView] = []
var viewpoints: Array[Node3D] = []
var paused := false
var camera_index := 0
var accumulator := 0.0
const COLORS := [Color("a5bd70"), Color("ed9565"), Color("c2dfca"), Color("94badd")]

func _ready() -> void:
	assert(pixy_scene != null, "Garden requires a Pixy scene")
	viewpoints.assign(viewpoint_container.get_children())
	_apply_authored_spawn_positions()
	_spawn_pixy_views()
	ui.pause_requested.connect(_toggle_pause)
	ui.viewpoint_requested.connect(_next_viewpoint)
	_set_camera_from_viewpoint()

func _process(delta: float) -> void:
	if not paused:
		var step := 1.0 / simulation_rate
		accumulator += minf(delta, 0.15)
		while accumulator >= step:
			simulation.advance(step)
			accumulator -= step
	for i in range(views.size()):
		views[i].sync(simulation.pixies[i], simulation.elapsed)
	ui.set_status("PAUSED" if paused else "OBSERVING  ·  %02d:%02d" % [int(simulation.elapsed) / 60, int(simulation.elapsed) % 60])

func _apply_authored_spawn_positions() -> void:
	var spawn_points := spawn_container.get_children()
	assert(spawn_points.size() >= simulation.pixies.size(), "Add one Marker3D per pixy under PixySpawns")
	for i in range(simulation.pixies.size()):
		var marker := spawn_points[i] as Marker3D
		assert(marker != null, "Pixy spawn children must be Marker3D nodes")
		var ground_position := Vector2(marker.global_position.x, marker.global_position.z)
		simulation.pixies[i].position = ground_position
		simulation.pixies[i].target = ground_position

func _spawn_pixy_views() -> void:
	for i in range(simulation.pixies.size()):
		var view := pixy_scene.instantiate() as PixyView
		assert(view != null, "Configured Pixy scene must have PixyView at its root")
		pixy_container.add_child(view)
		view.setup(simulation.pixies[i].element, COLORS[i], float(i))
		view.sync(simulation.pixies[i], 0.0)
		views.append(view)

func _toggle_pause() -> void:
	paused = not paused

func _next_viewpoint() -> void:
	if viewpoints.is_empty():
		return
	camera_index = (camera_index + 1) % viewpoints.size()
	_set_camera_from_viewpoint()

func _set_camera_from_viewpoint() -> void:
	if viewpoints.is_empty():
		return
	camera.global_position = viewpoints[camera_index].global_position
	camera.look_at(camera_look_target)
