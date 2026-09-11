extends SceneTree
## Headless contract check: bounds, reproducibility and individual ownership.

func _init() -> void:
	var definition := load("res://first_garden_definition.tres") as GardenDefinition
	assert(definition != null)
	assert(definition.surface_at(Vector2.ZERO) == GardenDefinition.MEADOW)
	assert(definition.surface_at(definition.water_center) == GardenDefinition.WATER)
	assert(definition.surface_at(Vector2(100.0, 100.0)) == GardenDefinition.OUTSIDE)
	assert(definition.can_place_flower(Vector2.ZERO))
	assert(not definition.can_place_flower(definition.water_center))
	var first := GardenSimulation.new(definition)
	var second := GardenSimulation.new(definition)
	assert(first.pixies[0] != first.pixies[1])
	for tick in range(18000):
		first.advance(1.0 / 30.0)
		second.advance(1.0 / 30.0)
		for i in range(4):
			var pos := first.pixies[i].position
			assert(absf(pos.x) <= 7.0 and pos.y >= -2.4 and pos.y <= 2.1, "Pixie escaped movement bounds")
			assert(pos == second.pixies[i].position, "Seeded runs diverged")
	first.pixies[0].location_id = "test_location"
	assert(first.pixies[1].location_id == "first_garden", "Individual state was shared")
	var flower_position := first.pixies[0].position
	first.notice_flower(flower_position, 0.1)
	assert(first.pixies[0].reaction == "?", "Nearby pixy missed flower reaction")
	first.advance(5.1)
	assert(first.pixies[0].reaction.is_empty(), "Temporary reaction did not expire")
	for pixy in first.pixies:
		assert(pixy.energy >= 0.0 and pixy.energy <= 1.0)
		assert(pixy.comfort >= 0.0 and pixy.comfort <= 1.0)
		assert(pixy.curiosity >= 0.0 and pixy.curiosity <= 1.0)
	var saved := first.to_dictionary()
	var restored := GardenSimulation.new(definition)
	restored.load_dictionary(saved)
	assert(restored.elapsed == first.elapsed, "Elapsed time did not round-trip")
	assert(restored.random.state == first.random.state, "RNG state did not round-trip")
	assert(restored.flower_positions == first.flower_positions, "Flowers did not round-trip")
	for i in range(first.pixies.size()):
		assert(restored.pixies[i].position == first.pixies[i].position, "Pixy position did not round-trip")
		assert(restored.pixies[i].energy == first.pixies[i].energy, "Pixy needs did not round-trip")
	print("PASS: daily-life simulation and save-data contracts")
	quit()
