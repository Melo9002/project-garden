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
var personality := {
	"sociability": 0.5,
	"boldness": 0.5,
	"vitality": 0.5,
	"sensitivity": 0.5,
	"playfulness": 0.5,
}
## Only the three relationships this pixy currently finds meaningful are remembered.
## Values are familiarity and affection in normalized 0–1 ranges.
var relationships: Dictionary = {}
var social_partner_id: String = ""
var social_cooldown: float = 0.0

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

func generate_personality(random: RandomNumberGenerator) -> void:
	for quality in personality:
		# Averages remain common while distinct extremes still occur.
		personality[quality] = clampf((random.randf() + random.randf()) * 0.5, 0.08, 0.92)

func personality_label() -> String:
	var strongest := "sociability"
	for quality in personality:
		if float(personality[quality]) > float(personality[strongest]):
			strongest = quality
	var labels := {
		"sociability": "Warm Companion",
		"boldness": "Brave Explorer",
		"vitality": "Restless Spark",
		"sensitivity": "Gentle Dreamer",
		"playfulness": "Merry Trickster",
	}
	return labels[strongest]

func remember_relationship(other_id: String, familiarity_change: float, affection_change: float) -> void:
	if other_id == id:
		return
	var bond: Dictionary = relationships.get(other_id, {"familiarity": 0.0, "affection": 0.5})
	bond["familiarity"] = clampf(float(bond["familiarity"]) + familiarity_change, 0.0, 1.0)
	bond["affection"] = clampf(float(bond["affection"]) + affection_change, 0.0, 1.0)
	relationships[other_id] = bond
	if relationships.size() > 3:
		var faintest_id := ""
		var faintest_score := INF
		for remembered_id in relationships:
			var remembered: Dictionary = relationships[remembered_id]
			var score := float(remembered["familiarity"]) + float(remembered["affection"]) * 0.35
			if score < faintest_score:
				faintest_score = score
				faintest_id = remembered_id
		relationships.erase(faintest_id)

func favorite_id() -> String:
	var favorite := ""
	var favorite_score := -1.0
	for other_id in relationships:
		var bond: Dictionary = relationships[other_id]
		var score := float(bond["familiarity"]) * float(bond["affection"])
		if score > favorite_score:
			favorite_score = score
			favorite = other_id
	return favorite

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
		"personality": personality.duplicate(),
		"relationships": relationships.duplicate(true),
		"social_partner_id": social_partner_id,
		"social_cooldown": social_cooldown,
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
	var saved_personality: Variant = data.get("personality", {})
	if saved_personality is Dictionary:
		for quality in personality:
			personality[quality] = clampf(float(saved_personality.get(quality, personality[quality])), 0.0, 1.0)
	var saved_relationships: Variant = data.get("relationships", {})
	relationships.clear()
	if saved_relationships is Dictionary:
		for other_id in saved_relationships:
			var bond: Variant = saved_relationships[other_id]
			if bond is Dictionary:
				remember_relationship(str(other_id), clampf(float(bond.get("familiarity", 0.0)), 0.0, 1.0), clampf(float(bond.get("affection", 0.5)), 0.0, 1.0) - 0.5)
	social_partner_id = str(data.get("social_partner_id", ""))
	social_cooldown = maxf(0.0, float(data.get("social_cooldown", 0.0)))
	var saved_energy: Variant = data.get("elemental_energy", {})
	if saved_energy is Dictionary:
		for kind in elemental_energy:
			elemental_energy[kind] = clampf(float(saved_energy.get(kind, elemental_energy[kind])), 0.0, 1.0)

func _read_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Array and value.size() >= 2:
		return Vector2(float(value[0]), float(value[1]))
	return fallback

