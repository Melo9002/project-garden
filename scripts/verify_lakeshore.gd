extends SceneTree
## Run headless for contracts; add -- --preview [west|east] [near] for GPU captures.
## Preview instances never read or write the player's save.

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var garden := load("res://scenes/garden.tscn").instantiate() as Node3D
	root.add_child(garden)
	await process_frame
	garden.paused = true
	var definition: GardenDefinition = garden.garden_definition
	var meadow: CSGPolygon3D = garden.get_node("Environment/Meadow")
	for i in range(definition.shoreline.size()):
		assert(meadow.polygon[meadow.polygon.size() - 1 - i] == definition.shoreline[i], "Visual and semantic shoreline disagree")
	assert(is_equal_approx(meadow.to_global(Vector3(0, 0, -meadow.depth)).y, definition.meadow_height), "Meadow mesh height disagrees with hover/placement")
	assert(is_equal_approx(garden.get_node("Environment/ForegroundLake").position.y, definition.water_height))
	assert(definition.surface_at(Vector2(100, 3)) == GardenDefinition.OUTSIDE)
	for x in range(-6, 7):
		var edge := definition.shore_z_at(float(x))
		assert(definition.can_place_flower(Vector2(x, edge - 0.01)))
		assert(not definition.can_place_flower(Vector2(x, edge + 0.01)))
		assert(definition.surface_at(Vector2(x, edge + 0.01)) == GardenDefinition.WATER)
	var sample_random := RandomNumberGenerator.new()
	sample_random.seed = 910
	for i in range(500):
		assert(definition.surface_at(definition.random_water_point(sample_random)) == GardenDefinition.WATER)
	var test := GardenSimulation.new(definition)
	var water := test.pixies[3]
	water.comfort = 0.4
	test.advance(1.0 / 30.0)
	assert(water.activity == "Seeking the lake")
	for tick in range(3600):
		test.advance(1.0 / 30.0)
		if water.activity == "Playing in the shallows":
			break
	assert(water.activity == "Playing in the shallows", "Water never reached its habitat")
	assert(definition.surface_at(water.position) == GardenDefinition.WATER)
	var comfort_before := water.comfort
	var energy_before := float(water.elemental_energy["Water"])
	for tick in range(150):
		test.advance(1.0 / 30.0)
	assert(water.comfort > comfort_before and float(water.elemental_energy["Water"]) > energy_before)
	var legacy_save := test.to_dictionary()
	legacy_save["flowers"] = [[0.0, 2.0]]
	var restored := GardenSimulation.new(definition)
	restored.load_dictionary(legacy_save)
	assert(definition.can_place_flower(restored.flower_positions[0]), "An old flower save restored inside the new lake")
	assert(legacy_save["flowers"][0][1] == 2.0, "Loading mutated the source save data")
	var camera_rig: GardenCamera = garden.get_node("CameraRig")
	var viewport_size := root.get_visible_rect().size
	for distance in [camera_rig.zoom_limits.x, camera_rig.zoom_limits.y]:
		for side in [camera_rig.horizontal_limits.x, camera_rig.horizontal_limits.y]:
			camera_rig.position.x = side
			camera_rig.target_distance = distance
			camera_rig._apply_pose(1.0)
			var cam := camera_rig.camera
			var lake_point := Vector3(side, definition.water_height + 0.01, definition.reachable_bounds.end.y - 0.01)
			var screen_point := cam.unproject_position(lake_point)
			assert(screen_point.y > 0 and screen_point.y < viewport_size.y - 20, "Reachable foreground water is below the camera")
			for corner in [Vector2(0, viewport_size.y), Vector2(viewport_size.x, viewport_size.y)]:
				var hit: Variant = Plane(Vector3.UP, definition.water_height).intersects_ray(cam.project_ray_origin(corner), cam.project_ray_normal(corner))
				assert(hit != null and absf(hit.x) < 60 and hit.z < 68, "Camera exposes the water mesh edge")
	print("PASS: lakeshore geometry, placement boundary, reachable water and Water affinity")
	var args := OS.get_cmdline_user_args()
	if not args.has("--preview"):
		garden.queue_free()
		await process_frame
		quit()
		return
	# A settled state makes the reachable lake and the ripple visible in screenshots.
	for tick in range(600):
		garden.simulation.advance(1.0 / 30.0)
	var rig: GardenCamera = garden.get_node("CameraRig")
	var x := rig.horizontal_limits.x if args.has("west") else (rig.horizontal_limits.y if args.has("east") else 0.0)
	rig.position.x = x
	rig.target_x = x
	rig.target_distance = rig.zoom_limits.x if args.has("near") else rig.zoom_limits.y
	rig.camera.position.z = rig.target_distance
	if args.has("clean"):
		garden.get_node("GardenUI").hide()
