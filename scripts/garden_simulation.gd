class_name GardenSimulation
extends RefCounted
## Seeded movement model. Does not access scene nodes or artwork.

var pixies: Array[PixyState] = []
var random := RandomNumberGenerator.new()
var elapsed: float = 0.0
var garden_definition: GardenDefinition
var flower_positions: Array[Vector2] = []

func _init(definition: GardenDefinition = null) -> void:
	garden_definition = definition if definition != null else GardenDefinition.new()
	random.seed = 240910
	var elements := ["Earth", "Fire", "Wind", "Water"]
	for i in range(elements.size()):
		pixies.append(PixyState.new("pixy_%d" % i, elements[i], Vector2(-2.4 + i * 1.6, 0.5)))

func advance(delta: float) -> void:
	elapsed += delta
	for pixy in pixies:
		_update_needs(pixy, delta)
		_update_reaction(pixy, delta)
		if pixy.idle_remaining > 0.0:
			pixy.idle_remaining -= delta
			_apply_idle_activity(pixy, delta)
			continue
		if pixy.position.distance_to(pixy.target) < 0.05:
			_arrive_and_choose(pixy)
		else:
			pixy.activity = "Wandering" if pixy.activity == "Taking in the garden" else pixy.activity
			pixy.position = pixy.position.move_toward(pixy.target, delta * 0.38)

func notice_flower(ground_position: Vector2, notice_radius: float = 2.4) -> void:
	flower_positions.append(ground_position)
	for pixy in pixies:
		if pixy.position.distance_to(ground_position) <= notice_radius:
			pixy.show_reaction("?", 5.0)

func _update_needs(pixy: PixyState, delta: float) -> void:
	pixy.energy = clampf(pixy.energy - delta * 0.0018, 0.0, 1.0)
	pixy.comfort = clampf(pixy.comfort - delta * 0.0007, 0.0, 1.0)
	pixy.curiosity = clampf(pixy.curiosity - delta * 0.0014, 0.0, 1.0)

func _update_reaction(pixy: PixyState, delta: float) -> void:
	if pixy.reaction_remaining <= 0.0:
		return
	pixy.reaction_remaining -= delta
	if pixy.reaction_remaining <= 0.0:
		pixy.reaction = ""

func _apply_idle_activity(pixy: PixyState, delta: float) -> void:
	if pixy.activity == "Resting":
		pixy.energy = clampf(pixy.energy + delta * 0.018, 0.0, 1.0)
		pixy.comfort = clampf(pixy.comfort + delta * 0.002, 0.0, 1.0)
	elif pixy.activity == "Enjoying flowers":
		pixy.curiosity = clampf(pixy.curiosity + delta * 0.025, 0.0, 1.0)
		pixy.comfort = clampf(pixy.comfort + delta * 0.01, 0.0, 1.0)

func _arrive_and_choose(pixy: PixyState) -> void:
	if pixy.activity == "Visiting flowers":
		pixy.activity = "Enjoying flowers"
		pixy.idle_remaining = random.randf_range(3.0, 5.0)
		pixy.show_reaction("♪", 2.5)
		return
	if pixy.energy < 0.35:
		pixy.activity = "Resting"
		pixy.idle_remaining = random.randf_range(4.0, 7.0)
		return
	if pixy.curiosity < 0.55 and not flower_positions.is_empty():
		pixy.activity = "Visiting flowers"
		pixy.target = _nearest_flower(pixy.position)
		return
	pixy.target = garden_definition.random_reachable_point(random)
	pixy.activity = "Investigating water" if garden_definition.surface_at(pixy.target) == GardenDefinition.WATER else "Wandering"
	pixy.idle_remaining = random.randf_range(1.0, 3.0)

func _nearest_flower(from: Vector2) -> Vector2:
	var nearest := flower_positions[0]
	var nearest_distance := from.distance_squared_to(nearest)
	for position in flower_positions:
		var distance := from.distance_squared_to(position)
		if distance < nearest_distance:
			nearest = position
			nearest_distance = distance
	return nearest

func to_dictionary() -> Dictionary:
	var saved_pixies: Array[Dictionary] = []
	for pixy in pixies:
		saved_pixies.append(pixy.to_dictionary())
	var saved_flowers: Array[Array] = []
	for position in flower_positions:
		saved_flowers.append([position.x, position.y])
	return {
		"version": 1,
		"elapsed": elapsed,
		"random_state": random.state,
		"pixies": saved_pixies,
		"flowers": saved_flowers,
	}

func load_dictionary(data: Dictionary) -> void:
	elapsed = float(data.get("elapsed", 0.0))
	random.state = int(data.get("random_state", random.state))
	var saved_pixies: Array = data.get("pixies", [])
	for i in range(mini(pixies.size(), saved_pixies.size())):
		if saved_pixies[i] is Dictionary:
			pixies[i].load_dictionary(saved_pixies[i])
	flower_positions.clear()
	for value in data.get("flowers", []):
		if value is Array and value.size() >= 2:
			flower_positions.append(Vector2(float(value[0]), float(value[1])))

