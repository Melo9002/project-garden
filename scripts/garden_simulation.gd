class_name GardenSimulation
extends RefCounted
## Seeded movement model. Does not access scene nodes or artwork.

var pixies: Array[PixyState] = []
var random := RandomNumberGenerator.new()
var elapsed: float = 0.0
var garden_definition: GardenDefinition
var flower_positions: Array[Vector2] = []
var resting_stone_positions: Array[Vector2] = []
var wind_chime_positions: Array[Vector2] = []
var garden_energy := {"Earth": 0.1, "Fire": 0.1, "Wind": 0.1, "Water": 0.1}

func _init(definition: GardenDefinition = null, seed: int = 240910) -> void:
	garden_definition = definition if definition != null else GardenDefinition.new()
	random.seed = seed
	var elements := ["Earth", "Fire", "Wind", "Water"]
	for i in range(elements.size()):
		var pixy := PixyState.new("pixy_%d" % i, elements[i], Vector2(-2.4 + i * 1.6, 0.5))
		pixy.generate_personality(random)
		pixies.append(pixy)

func advance(delta: float) -> void:
	elapsed += delta
	_update_garden_sources(delta)
	for pixy in pixies:
		pixy.social_cooldown = maxf(0.0, pixy.social_cooldown - delta)
		if pixy.activity.begins_with("Going to greet "):
			var moving_partner := _pixy_by_id(pixy.social_partner_id)
			if moving_partner != null:
				pixy.target = moving_partner.position
		_update_needs(pixy, delta)
		_absorb_local_energy(pixy, delta)
		_update_reaction(pixy, delta)
		if pixy.idle_remaining > 0.0:
			pixy.idle_remaining -= delta
			_apply_idle_activity(pixy, delta)
			continue
		if pixy.position.distance_to(pixy.target) < 0.05:
			_arrive_and_choose(pixy)
		else:
			pixy.activity = "Wandering" if pixy.activity == "Taking in the garden" else pixy.activity
			var movement_speed := lerpf(0.27, 0.52, float(pixy.personality["vitality"]))
			pixy.position = pixy.position.move_toward(pixy.target, delta * movement_speed)

func notice_flower(ground_position: Vector2, notice_radius: float = 2.4) -> void:
	notice_item(&"flower", ground_position, notice_radius)

func notice_item(kind: StringName, ground_position: Vector2, notice_radius: float = 2.4) -> void:
	_item_positions(kind).append(ground_position)
	for pixy in pixies:
		if pixy.position.distance_to(ground_position) <= notice_radius:
			pixy.show_reaction("?", 5.0)

func placed_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for kind in [&"flower", &"resting_stone", &"wind_chime"]:
		for item_position in _item_positions(kind):
			result.append({"kind": kind, "position": item_position})
	return result

func _item_positions(kind: StringName) -> Array[Vector2]:
	match kind:
		&"resting_stone": return resting_stone_positions
		&"wind_chime": return wind_chime_positions
		_: return flower_positions

func _update_needs(pixy: PixyState, delta: float) -> void:
	var sensitivity := lerpf(0.65, 1.45, float(pixy.personality["sensitivity"]))
	var exertion := lerpf(0.82, 1.22, float(pixy.personality["vitality"]))
	pixy.energy = clampf(pixy.energy - delta * 0.0018 * exertion, 0.0, 1.0)
	pixy.comfort = clampf(pixy.comfort - delta * 0.0007 * sensitivity, 0.0, 1.0)
	pixy.curiosity = clampf(pixy.curiosity - delta * 0.0014 * sensitivity, 0.0, 1.0)

func _update_garden_sources(delta: float) -> void:
	_add_garden_energy("Earth", flower_positions.size() * delta * 0.00008)
	_add_garden_energy("Fire", delta * 0.00004)
	_add_garden_energy("Wind", delta * 0.00003)
	_add_garden_energy("Wind", wind_chime_positions.size() * delta * 0.00006)
	_add_garden_energy("Water", delta * 0.00004)

func _absorb_local_energy(pixy: PixyState, delta: float) -> void:
	var exposure := garden_definition.elemental_exposure_at(pixy.position, flower_positions)
	for chime in wind_chime_positions:
		var chime_distance := pixy.position.distance_to(chime)
		if chime_distance <= 1.5:
			exposure["Wind"] = maxf(float(exposure["Wind"]), 1.0 - chime_distance / 1.5)
	for kind in exposure:
		var amount := float(exposure[kind]) * delta
		if amount <= 0.0:
			continue
		pixy.elemental_energy[kind] = clampf(float(pixy.elemental_energy[kind]) + amount * 0.0025, 0.0, 1.0)
		_add_garden_energy(kind, amount * 0.00012)
		if kind == pixy.element:
			pixy.comfort = clampf(pixy.comfort + amount * 0.0015, 0.0, 1.0)

func _add_garden_energy(kind: String, amount: float) -> void:
	garden_energy[kind] = clampf(float(garden_energy[kind]) + amount, 0.0, 1.0)

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
	elif pixy.activity == "Playing in the shallows":
		pixy.curiosity = clampf(pixy.curiosity + delta * 0.018, 0.0, 1.0)
		pixy.comfort = clampf(pixy.comfort + delta * 0.008, 0.0, 1.0)
	elif pixy.activity.begins_with("Spending time with "):
		pixy.comfort = clampf(pixy.comfort + delta * (0.002 + 0.006 * float(pixy.personality["sociability"])), 0.0, 1.0)
	elif pixy.activity == "Resting at a mossy stone":
		pixy.energy = clampf(pixy.energy + delta * 0.024, 0.0, 1.0)
		pixy.comfort = clampf(pixy.comfort + delta * 0.005, 0.0, 1.0)
	elif pixy.activity == "Playing by the wind chime":
		pixy.curiosity = clampf(pixy.curiosity + delta * (0.018 + 0.018 * float(pixy.personality["playfulness"])), 0.0, 1.0)

func _arrive_and_choose(pixy: PixyState) -> void:
	if pixy.activity.begins_with("Going to greet "):
		_begin_social_visit(pixy)
		return
	if pixy.activity == "Seeking a resting stone":
		pixy.activity = "Resting at a mossy stone"
		pixy.idle_remaining = random.randf_range(5.0, 8.0)
		pixy.show_reaction("…", 2.5)
		return
	if pixy.activity == "Visiting the wind chime":
		pixy.activity = "Playing by the wind chime"
		pixy.idle_remaining = random.randf_range(4.0, 7.0)
		pixy.show_reaction("♪", 3.0)
		return
	if pixy.activity == "Seeking the lake":
		pixy.activity = "Playing in the shallows"
		pixy.idle_remaining = random.randf_range(8.0, 12.0)
		pixy.show_reaction("♪", 2.5)
		return
	if pixy.activity == "Visiting flowers":
		pixy.activity = "Enjoying flowers"
		pixy.idle_remaining = random.randf_range(3.0, 5.0)
		pixy.show_reaction("♪", 2.5)
		return
	if pixy.energy < 0.48 and not resting_stone_positions.is_empty():
		pixy.activity = "Seeking a resting stone"
		pixy.target = _nearest_position(pixy.position, resting_stone_positions)
		return
	if pixy.energy < 0.35:
		pixy.activity = "Resting"
		pixy.idle_remaining = random.randf_range(4.0, 7.0)
		return
	# Water seeks its habitat when comfort dips, then returns to ordinary wandering.
	# The recovery/seek gap prevents a rapid back-and-forth at the shore.
	if pixy.element == "Water" and pixy.comfort < 0.72 and pixy.activity != "Playing in the shallows":
		pixy.target = garden_definition.random_water_point(random)
		pixy.activity = "Seeking the lake"
		return
	if pixy.curiosity < 0.55:
		if not wind_chime_positions.is_empty() and (flower_positions.is_empty() or random.randf() < float(pixy.personality["playfulness"])):
			pixy.activity = "Visiting the wind chime"
			pixy.target = _nearest_position(pixy.position, wind_chime_positions)
			return
		if not flower_positions.is_empty():
			pixy.activity = "Visiting flowers"
			pixy.target = _nearest_flower(pixy.position)
			return
	if _try_choose_social_visit(pixy):
		return
	var broad_target := garden_definition.random_reachable_point(random)
	var travel_fraction := lerpf(0.28, 1.0, float(pixy.personality["boldness"]))
	pixy.target = pixy.position.lerp(broad_target, travel_fraction)
	pixy.activity = "Investigating water" if garden_definition.surface_at(pixy.target) == GardenDefinition.WATER else "Wandering"
	pixy.idle_remaining = random.randf_range(0.6, 2.8) * lerpf(1.25, 0.72, float(pixy.personality["vitality"]))

func _try_choose_social_visit(pixy: PixyState) -> bool:
	if pixy.social_cooldown > 0.0 or random.randf() > float(pixy.personality["sociability"]) * 0.34:
		return false
	var candidates: Array[PixyState] = []
	for other in pixies:
		if other != pixy and other.energy > 0.25 and not other.activity.contains("Resting") and not other.activity.begins_with("Going to greet "):
			candidates.append(other)
	if candidates.is_empty():
		return false
	var favorite := pixy.favorite_id()
	var partner := candidates[0]
	var best_score := -INF
	for candidate in candidates:
		var score := _social_score(pixy, candidate) + random.randf_range(0.0, 0.18)
		if score > best_score:
			best_score = score
			partner = candidate
	if not favorite.is_empty() and random.randf() < 0.65:
		var remembered := _pixy_by_id(favorite)
		if remembered != null:
			partner = remembered
	pixy.social_partner_id = partner.id
	pixy.target = partner.position
	pixy.activity = "Going to greet %s" % partner.element
	pixy.social_cooldown = random.randf_range(16.0, 28.0)
	return true

func _social_score(pixy: PixyState, other: PixyState) -> float:
	var distance_score := 1.0 - clampf(pixy.position.distance_to(other.position) / 12.0, 0.0, 1.0)
	var temperament := 1.0 - (
		absf(float(pixy.personality["playfulness"]) - float(other.personality["playfulness"]))
		+ absf(float(pixy.personality["sociability"]) - float(other.personality["sociability"]))) * 0.5
	var bond: Dictionary = pixy.relationships.get(other.id, {})
	var affection := float(bond.get("affection", 0.5))
	return distance_score * 0.35 + temperament * 0.3 + affection * 0.35

func _begin_social_visit(pixy: PixyState) -> void:
	var partner := _pixy_by_id(pixy.social_partner_id)
	if partner == null or pixy.position.distance_to(partner.position) > 1.2:
		pixy.social_partner_id = ""
		pixy.activity = "Taking in the garden"
		pixy.idle_remaining = 0.0
		return
	var duration := random.randf_range(3.5, 6.0) * lerpf(0.8, 1.25, float(pixy.personality["playfulness"]))
	pixy.activity = "Spending time with %s" % partner.element
	pixy.idle_remaining = duration
	partner.activity = "Spending time with %s" % pixy.element
	partner.idle_remaining = duration
	partner.target = partner.position
	partner.social_partner_id = pixy.id
	partner.social_cooldown = random.randf_range(16.0, 28.0)
	var warmth := 0.015 + 0.025 * minf(float(pixy.personality["sociability"]), float(partner.personality["sociability"]))
	pixy.remember_relationship(partner.id, 0.08, warmth)
	partner.remember_relationship(pixy.id, 0.08, warmth)
	pixy.show_reaction("♥" if pixy.favorite_id() == partner.id else "♪", duration)
	partner.show_reaction("♥" if partner.favorite_id() == pixy.id else "♪", duration)

func _pixy_by_id(identity: String) -> PixyState:
	for pixy in pixies:
		if pixy.id == identity:
			return pixy
	return null

func display_name_for_id(identity: String) -> String:
	var pixy := _pixy_by_id(identity)
	return pixy.element if pixy != null else ""

func _nearest_flower(from: Vector2) -> Vector2:
	return _nearest_position(from, flower_positions)

func _nearest_position(from: Vector2, positions: Array[Vector2]) -> Vector2:
	var nearest := positions[0]
	var nearest_distance := from.distance_squared_to(nearest)
	for position in positions:
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
		"version": 3,
		"elapsed": elapsed,
		"random_state": random.state,
		"pixies": saved_pixies,
		"flowers": saved_flowers,
		"items": _items_to_save_data(),
		"garden_energy": garden_energy.duplicate(),
	}

func load_dictionary(data: Dictionary) -> void:
	elapsed = float(data.get("elapsed", 0.0))
	random.state = int(data.get("random_state", random.state))
	var saved_pixies: Array = data.get("pixies", [])
	for i in range(mini(pixies.size(), saved_pixies.size())):
		if saved_pixies[i] is Dictionary:
			pixies[i].load_dictionary(saved_pixies[i])
	flower_positions.clear()
	resting_stone_positions.clear()
	wind_chime_positions.clear()
	var saved_items: Array = data.get("items", [])
	if saved_items.is_empty():
		for value in data.get("flowers", []):
			if value is Array and value.size() >= 2:
				_load_item(&"flower", value)
	else:
		for item in saved_items:
			if item is Dictionary:
				_load_item(StringName(item.get("kind", "flower")), item.get("position", []))
	for pixy in pixies:
		if pixy.activity == "Visiting flowers" and not flower_positions.is_empty():
			pixy.target = _nearest_flower(pixy.position)
	var saved_garden_energy: Variant = data.get("garden_energy", {})
	if saved_garden_energy is Dictionary:
		for kind in garden_energy:
			garden_energy[kind] = clampf(float(saved_garden_energy.get(kind, garden_energy[kind])), 0.0, 1.0)

func _items_to_save_data() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in placed_items():
		var point: Vector2 = item["position"]
		result.append({"kind": str(item["kind"]), "position": [point.x, point.y]})
	return result

func _load_item(kind: StringName, value: Variant) -> void:
	if value is not Array or value.size() < 2:
		return
	var point := Vector2(float(value[0]), float(value[1]))
	point = point if garden_definition.can_place_flower(point) else garden_definition.nearest_meadow_point(point)
	_item_positions(kind).append(point)

