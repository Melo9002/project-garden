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
			assert(absf(pos.x) <= 3.7 and absf(pos.y) <= 2.2, "Pixie escaped movement bounds")
			assert(pos == second.pixies[i].position, "Seeded runs diverged")
	first.pixies[0].location_id = "test_location"
	assert(first.pixies[1].location_id == "first_garden", "Individual state was shared")
	print("PASS: 18000 ticks; bounds, reproducibility, independent state")
	quit()
