extends Node3D
## Connects authored scenes to the independent simulation model.

@export var pixy_scene: PackedScene
@export_range(1.0, 60.0, 1.0) var simulation_rate: float = 30.0
@export var camera_look_target: Vector3 = Vector3(0, 0.1, 0)
@onready var pixy_container: Node3D = $Pixies
@onready var spawn_container: Node3D = $PixySpawns
@onready var camera_rig: GardenCamera = $CameraRig
@onready var ui: CanvasLayer = $GardenUI
@onready var placement: GardenPlacement = $GardenPlacement

var simulation := GardenSimulation.new()
var views: Array[PixyView] = []
var paused := false
var camera_stop := 1
var accumulator := 0.0
var selected_index := -1
const COLORS := [Color("a5bd70"), Color("ed9565"), Color("c2dfca"), Color("94badd")]

func _ready() -> void:
	assert(pixy_scene != null, "Garden requires a Pixy scene")
	_apply_authored_spawn_positions()
	_spawn_pixy_views()
	ui.pause_requested.connect(_toggle_pause)
	ui.viewpoint_requested.connect(_next_viewpoint)
	ui.flower_placement_requested.connect(placement.begin_flower_placement)
	placement.flower_placed.connect(_on_flower_placed)
	camera_rig.position_changed.connect(ui.set_camera_position)
	camera_rig.focus_normalized(0.5)

func _process(delta: float) -> void:
	if not paused:
		var step := 1.0 / simulation_rate
		accumulator += minf(delta, 0.15)
		while accumulator >= step:
			simulation.advance(step)
			accumulator -= step
	for i in range(views.size()):
		views[i].sync(simulation.pixies[i], simulation.elapsed)
	if selected_index >= 0:
		ui.show_pixy(simulation.pixies[selected_index])
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
		view.selected.connect(_select_pixy)
		view.sync(simulation.pixies[i], 0.0)
		views.append(view)

func _select_pixy(chosen_view: PixyView) -> void:
	selected_index = views.find(chosen_view)
	for i in range(views.size()):
		views[i].set_selected(i == selected_index)
	ui.show_pixy(simulation.pixies[selected_index])

func _on_flower_placed(ground_position: Vector2) -> void:
	simulation.notice_flower(ground_position)

func _toggle_pause() -> void:
	paused = not paused

func _next_viewpoint() -> void:
	camera_stop = (camera_stop + 1) % 3
	camera_rig.focus_normalized(float(camera_stop) / 2.0)
