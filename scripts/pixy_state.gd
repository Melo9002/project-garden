class_name PixyState
extends RefCounted
## Individual state, independent of visible scene nodes.

var id: String
var element: String
var location_id: String = "first_garden"
var position: Vector2
var target: Vector2
var idle_remaining: float = 0.0
var energy: float = 0.8
var comfort: float = 0.7
var curiosity: float = 0.75
var activity: String = "Taking in the garden"
var reaction: String = ""
var reaction_remaining: float = 0.0
var elemental_energy := {"Earth": 0.1, "Fire": 0.1, "Wind": 0.1, "Water": 0.1}

func _init(identity: String, kind: String, start: Vector2) -> void:
	id = identity
	element = kind
	position = start
	target = start

func get_activity() -> String:
	return activity

func get_mood() -> String:
	if energy < 0.25:
		return "Sleepy"
	if curiosity < 0.25:
		return "Restless"
	if comfort > 0.72:
		return "Comfortable"
	return "Content"

func describe_need(value: float) -> String:
	if value < 0.25:
		return "low"
	if value < 0.55:
		return "okay"
	if value < 0.8:
		return "good"
	return "full"

func show_reaction(value: String, duration: float) -> void:
	reaction = value
	reaction_remaining = duration

func affinity_energy() -> float:
	return float(elemental_energy.get(element, 0.0))

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"element": element,
		"location_id": location_id,
		"position": [position.x, position.y],
		"target": [target.x, target.y],
		"idle_remaining": idle_remaining,
		"energy": energy,
		"comfort": comfort,
		"curiosity": curiosity,
		"activity": activity,
		"reaction": reaction,
		"reaction_remaining": reaction_remaining,
		"elemental_energy": elemental_energy.duplicate(),
	}

func load_dictionary(data: Dictionary) -> void:
	location_id = str(data.get("location_id", location_id))
	position = _read_vector2(data.get("position", [position.x, position.y]), position)
	target = _read_vector2(data.get("target", [target.x, target.y]), target)
	idle_remaining = float(data.get("idle_remaining", 0.0))
	energy = clampf(float(data.get("energy", energy)), 0.0, 1.0)
	comfort = clampf(float(data.get("comfort", comfort)), 0.0, 1.0)
	curiosity = clampf(float(data.get("curiosity", curiosity)), 0.0, 1.0)
	activity = str(data.get("activity", activity))
	reaction = str(data.get("reaction", ""))
	reaction_remaining = float(data.get("reaction_remaining", 0.0))
	var saved_energy: Variant = data.get("elemental_energy", {})
	if saved_energy is Dictionary:
		for kind in elemental_energy:
			elemental_energy[kind] = clampf(float(saved_energy.get(kind, elemental_energy[kind])), 0.0, 1.0)

func _read_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return fallback

