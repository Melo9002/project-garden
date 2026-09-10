extends Node3D
## Scene assembly and input. Simulation rules live in GardenSimulation.

var simulation := GardenSimulation.new()
var views: Array[PixyView] = []
var camera: Camera3D
var paused: bool = false
var camera_index: int = 0
var accumulator: float = 0.0
var status: Label
const STEP: float = 1.0 / 30.0
const COLORS := [Color("a5bd70"), Color("ed9565"), Color("c2dfca"), Color("94badd")]

func _ready() -> void:
	build_garden()
	for i in range(simulation.pixies.size()):
		var view := PixyView.new()
		add_child(view)
		view.setup(simulation.pixies[i].element, COLORS[i], float(i))
		view.sync(simulation.pixies[i], 0.0)
		views.append(view)
	build_ui()

func _process(delta: float) -> void:
	if not paused:
		accumulator += minf(delta, 0.15)
		while accumulator >= STEP:
			simulation.advance(STEP)
			accumulator -= STEP
	for i in range(views.size()):
		views[i].sync(simulation.pixies[i], simulation.elapsed)
	status.text = "PAUSED" if paused else "OBSERVING  ·  %02d:%02d" % [int(simulation.elapsed) / 60, int(simulation.elapsed) % 60]

func block(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	node.material_override = material
	add_child(node)
	return node

func build_garden() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("24383e")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("b4c8bc")
	environment.ambient_light_energy = 0.65
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -30, 0)
	sun.light_color = Color("fff0cd")
	sun.shadow_enabled = true
	add_child(sun)
	block(Vector3(0, -0.42, 0), Vector3(9.5, 0.8, 6.4), Color("505747"))
	block(Vector3(0, 0, 0), Vector3(9.6, 0.12, 6.5), Color("718866"))
	# Pond is visual scenery in this first batch, not a simulation resource.
	block(Vector3(2.5, 0.075, -1.3), Vector3(2.1, 0.035, 1.6), Color("639ba4"))
	var decoration := RandomNumberGenerator.new()
	decoration.seed = 17
	for i in range(16):
		var x := decoration.randf_range(-4.4, 4.4)
		var z := -2.8 if i < 10 else 2.7
		var height := decoration.randf_range(0.12, 0.5)
		var rock := block(Vector3(x, height / 2.0, z), Vector3(0.35, height, 0.32), Color("98a190"))
		rock.rotation.y = decoration.randf_range(0, 3)
	for x in [-4.0, -2.8, 3.8]:
		block(Vector3(x, 0.4, -2.45), Vector3(0.13, 0.8, 0.13), Color("665e4b"))
		block(Vector3(x, 1.0, -2.45), Vector3(0.9, 0.75, 0.65), Color("4c7059"))
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.2
	add_child(camera)
	set_camera()

func set_camera() -> void:
	var positions := [Vector3(8, 8, 11), Vector3(-8, 8, 11), Vector3(0, 10, 10)]
	camera.position = positions[camera_index]
	camera.look_at(Vector3(0, 0.1, 0))

func build_ui() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var panel := PanelContainer.new()
	panel.position = Vector2(24, 24)
	canvas.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	margin.add_child(column)
	var title := Label.new()
	title.text = "PROJECT GARDEN"
	title.add_theme_font_size_override("font_size", 24)
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "First clearing · development prototype\nFour temporary inhabitants. Watch them wander."
	column.add_child(subtitle)
	status = Label.new()
	column.add_child(status)
	var pause_button := Button.new()
	pause_button.text = "Pause / resume"
	pause_button.pressed.connect(func() -> void: paused = not paused)
	column.add_child(pause_button)
	var angle_button := Button.new()
	angle_button.text = "Change viewpoint"
	angle_button.pressed.connect(func() -> void:
		camera_index = (camera_index + 1) % 3
		set_camera())
	column.add_child(angle_button)
