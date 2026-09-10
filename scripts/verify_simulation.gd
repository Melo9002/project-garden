extends SceneTree
## Headless contract check: bounds, reproducibility and individual ownership.

func _init() -> void:
	var first := GardenSimulation.new()
	var second := GardenSimulation.new()
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
	assert(first.pixies[0].mood == "Curious about flowers", "Nearby pixy missed flower reaction")
	first.advance(5.1)
	assert(first.pixies[0].mood == "Settled", "Temporary mood did not expire")
	print("PASS: 18000 ticks; bounds, reproducibility, independent state")
	quit()
