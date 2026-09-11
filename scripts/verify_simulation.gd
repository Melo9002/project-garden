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
	var test_flowers: Array[Vector2] = [Vector2.ZERO]
	assert(float(definition.elemental_exposure_at(Vector2.ZERO, test_flowers)["Earth"]) > 0.0)
	assert(float(definition.elemental_exposure_at(definition.water_center, test_flowers)["Water"]) == 1.0)
	assert(float(definition.elemental_exposure_at(Vector2(0.0, 1.5), test_flowers)["Wind"]) > 0.0)
	assert(float(definition.elemental_exposure_at(Vector2.ZERO, test_flowers)["Fire"]) > 0.0)
	var first := GardenSimulation.new(definition)
	var second := GardenSimulation.new(definition)
	var different := GardenSimulation.new(definition, 240911)
	assert(first.pixies[0] != first.pixies[1])
	assert(first.pixies[0].personality == second.pixies[0].personality, "Equal seeds produced different personalities")
	assert(first.pixies[0].personality != different.pixies[0].personality, "Different seeds produced the same personality")
	for pixy in first.pixies:
		for quality in pixy.personality:
			assert(float(pixy.personality[quality]) >= 0.0 and float(pixy.personality[quality]) <= 1.0)
	for tick in range(18000):
		first.advance(1.0 / 30.0)
		second.advance(1.0 / 30.0)
		for i in range(4):
			var pos := first.pixies[i].position
			assert(definition.reachable_bounds.has_point(pos), "Pixie escaped movement bounds")
			assert(pos == second.pixies[i].position, "Seeded runs diverged")
	first.pixies[0].location_id = "test_location"
	assert(first.pixies[1].location_id == "first_garden", "Individual state was shared")
	var flower_position := Vector2.ZERO
	first.pixies[0].position = flower_position
	first.pixies[0].target = flower_position
	first.notice_flower(flower_position, 0.1)
	assert(first.pixies[0].reaction == "?", "Nearby pixy missed flower reaction")
	first.advance(5.1)
	assert(first.pixies[0].reaction.is_empty(), "Temporary reaction did not expire")
	first.notice_item(&"resting_stone", Vector2(-1.0, 0.0))
	first.notice_item(&"wind_chime", Vector2(1.0, 0.0))
	var tired := first.pixies[1]
	tired.position = Vector2(-1.0, 0.0)
	tired.target = tired.position
	tired.activity = "Seeking a resting stone"
	tired.energy = 0.3
	first._arrive_and_choose(tired)
	var tired_before := tired.energy
	first.advance(1.0)
	assert(tired.energy > tired_before, "Resting stone did not restore energy")
	var playful := first.pixies[2]
	playful.position = Vector2(1.0, 0.0)
	playful.target = playful.position
	playful.activity = "Visiting the wind chime"
	playful.curiosity = 0.2
	first._arrive_and_choose(playful)
	var curiosity_before := playful.curiosity
	var wind_before := float(playful.elemental_energy["Wind"])
	first.advance(1.0)
	assert(playful.curiosity > curiosity_before and float(playful.elemental_energy["Wind"]) > wind_before, "Wind chime effects were not applied")
	var social_a := first.pixies[0]
	var social_b := first.pixies[3]
	social_a.position = Vector2.ZERO
	social_b.position = Vector2(0.5, 0.0)
	social_a.social_partner_id = social_b.id
	social_a.activity = "Going to greet Water"
	first._begin_social_visit(social_a)
	assert(social_a.relationships.has(social_b.id) and social_b.relationships.has(social_a.id), "Social visit did not create reciprocal bonds")
	social_a.remember_relationship("extra_1", 0.01, 0.0)
	social_a.remember_relationship("extra_2", 0.01, 0.0)
	social_a.remember_relationship("extra_3", 0.01, 0.0)
	assert(social_a.relationships.size() == 3, "Relationship memory exceeded its cap")
	for pixy in first.pixies:
		assert(pixy.energy >= 0.0 and pixy.energy <= 1.0)
		assert(pixy.comfort >= 0.0 and pixy.comfort <= 1.0)
		assert(pixy.curiosity >= 0.0 and pixy.curiosity <= 1.0)
		for kind in pixy.elemental_energy:
			assert(float(pixy.elemental_energy[kind]) >= 0.0 and float(pixy.elemental_energy[kind]) <= 1.0)
	for kind in first.garden_energy:
		assert(float(first.garden_energy[kind]) > 0.1 and float(first.garden_energy[kind]) <= 1.0)
	var saved := first.to_dictionary()
	var restored := GardenSimulation.new(definition)
	restored.load_dictionary(saved)
	assert(restored.elapsed == first.elapsed, "Elapsed time did not round-trip")
	assert(restored.random.state == first.random.state, "RNG state did not round-trip")
	assert(restored.flower_positions == first.flower_positions, "Flowers did not round-trip")
	assert(restored.resting_stone_positions == first.resting_stone_positions, "Resting stones did not round-trip")
	assert(restored.wind_chime_positions == first.wind_chime_positions, "Wind chimes did not round-trip")
	assert(restored.garden_energy == first.garden_energy, "Garden energy did not round-trip")
	for i in range(first.pixies.size()):
		assert(restored.pixies[i].position == first.pixies[i].position, "Pixy position did not round-trip")
		assert(restored.pixies[i].energy == first.pixies[i].energy, "Pixy needs did not round-trip")
		assert(restored.pixies[i].elemental_energy == first.pixies[i].elemental_energy, "Elemental energy did not round-trip")
		assert(restored.pixies[i].personality == first.pixies[i].personality, "Personality did not round-trip")
		assert(restored.pixies[i].relationships == first.pixies[i].relationships, "Relationships did not round-trip")
	print("PASS: daily-life simulation and save-data contracts")
	quit()
