extends SceneTree
## Scene-level checks for the menu and reusable placement presentation. Never writes a save.

func _init() -> void:
	_run.call_deferred()

func _run() -> void:
	var garden: Node3D = load("res://scenes/garden.tscn").instantiate()
	root.add_child(garden)
	await process_frame
	assert(garden.menu_open and garden.paused, "Startup did not open and pause the garden menu")
	garden._new_garden()
	await process_frame
	assert(garden.active_garden and not garden.menu_open and not garden.paused)
	assert(garden.views.size() == garden.simulation.pixies.size())
	var items: Array[Dictionary] = [
		{"kind": &"resting_stone", "position": Vector2(-1.0, 0.0)},
		{"kind": &"wind_chime", "position": Vector2(1.0, 0.0)},
	]
	garden.placement.restore_items(items)
	await process_frame
	assert(garden.get_node("Interactables").get_child_count() == 2, "Saved placeable scenes were not reconstructed")
	var flower := load("res://scenes/flower_patch.tscn").instantiate() as FlowerPatch
	root.add_child(flower)
	flower.show_placement_preview(false)
	for mesh in flower.find_children("*", "MeshInstance3D"):
		if mesh != flower.get_node("ValidRing") and mesh != flower.get_node("InvalidRing"):
			assert(mesh.material_overlay == flower.invalid_preview_material, "Illegal preview did not tint the whole item")
	flower.finish_placement()
	assert(flower.get_node("Stem").material_overlay == null)
	print("PASS: garden menu, new-game reset, item reconstruction and full invalid tint")
	if OS.get_cmdline_user_args().has("--preview"):
		flower.queue_free()
		return
	quit()
