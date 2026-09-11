extends Node3D
## Connects authored scenes to the independent simulation model.

@export var pixy_scene: PackedScene
@export var garden_definition: GardenDefinition
@export_range(1.0, 60.0, 1.0) var simulation_rate: float = 30.0
@export var camera_look_target: Vector3 = Vector3(0, 0.1, 0)
@onready var pixy_container: Node3D = $Pixies
@onready var spawn_container: Node3D = $PixySpawns
@onready var camera_rig: GardenCamera = $CameraRig
@onready var ui: CanvasLayer = $GardenUI
@onready var placement: GardenPlacement = $GardenPlacement

var simulation: GardenSimulation
var views: Array[PixyView] = []
var paused := false
var camera_stop := 1
var accumulator := 0.0
var selected_index := -1
var simulation_speed := 1.0
var debug_open := false
const COLORS := [Color("a5bd70"), Color("ed9565"), Color("c2dfca"), Color("94badd")]

func _ready() -> void:
	assert(pixy_scene != null, "Garden requires a Pixy scene")
	assert(garden_definition != null, "Garden requires a GardenDefinition")
	simulation = GardenSimulation.new(garden_definition)
	_apply_authored_spawn_positions()
	_spawn_pixy_views()
	ui.pause_requested.connect(_toggle_pause)
	ui.viewpoint_requested.connect(_next_viewpoint)
	ui.flower_placement_requested.connect(placement.begin_flower_placement)
	ui.save_requested.connect(_save_garden)
	ui.load_requested.connect(_load_garden)
	ui.debug_speed_requested.connect(_set_debug_speed)
	ui.debug_step_requested.connect(_debug_step_minute)
	ui.debug_low_energy_requested.connect(_debug_set_low_energy)
	ui.debug_low_curiosity_requested.connect(_debug_set_low_curiosity)
	placement.flower_placed.connect(_on_flower_placed)
	camera_rig.position_changed.connect(ui.set_camera_position)
	camera_rig.focus_normalized(0.5)

func _process(delta: float) -> void:
	if not paused:
		var step := 1.0 / simulation_rate
		accumulator += minf(delta, 0.15) * simulation_speed
		while accumulator >= step:
			simulation.advance(step)
			accumulator -= step
	for i in range(views.size()):
		views[i].sync(simulation.pixies[i], simulation.elapsed)
	if selected_index >= 0:
		ui.show_pixy(simulation.pixies[selected_index])
	ui.set_status("PAUSED" if paused else "OBSERVING  ·  %02d:%02d" % [int(simulation.elapsed) / 60, int(simulation.elapsed) % 60])
	var selected_state: PixyState = simulation.pixies[selected_index] if selected_index >= 0 else null
	ui.update_debug(simulation.elapsed, simulation_speed, paused, selected_state)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F3 and event.pressed and not event.echo:
		debug_open = not debug_open
		ui.set_debug_visible(debug_open)
		if debug_open:
			paused = true
		get_viewport().set_input_as_handled()

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

func _save_garden() -> void:
	var error := GardenSave.write(simulation.to_dictionary())
	ui.show_notice("Garden saved" if error == OK else "Could not save garden")

func _load_garden() -> void:
	var data := GardenSave.read()
	if data.is_empty():
		ui.show_notice("No garden save found")
		return
	simulation.load_dictionary(data)
	placement.restore_flowers(simulation.flower_positions)
	ui.show_notice("Garden restored")

func _set_debug_speed(multiplier: float) -> void:
	simulation_speed = multiplier
	paused = multiplier <= 0.0

func _debug_step_minute() -> void:
	for tick in range(60 * int(simulation_rate)):
		simulation.advance(1.0 / simulation_rate)

func _debug_set_low_energy() -> void:
	if selected_index < 0:
		ui.show_notice("Select a pixy first")
		return
	var pixy := simulation.pixies[selected_index]
	pixy.energy = 0.15
	pixy.idle_remaining = 0.0
	pixy.target = pixy.position

func _debug_set_low_curiosity() -> void:
	if selected_index < 0:
		ui.show_notice("Select a pixy first")
		return
	var pixy := simulation.pixies[selected_index]
	pixy.curiosity = 0.15
	pixy.idle_remaining = 0.0
	pixy.target = pixy.position

func _toggle_pause() -> void:
	paused = not paused

func _next_viewpoint() -> void:
	camera_stop = (camera_stop + 1) % 3
	camera_rig.focus_normalized(float(camera_stop) / 2.0)
