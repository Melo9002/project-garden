class_name PixyState
extends RefCounted
## Individual state, independent of visible scene nodes.

var id: String
var element: String
var location_id: String = "first_garden"
var position: Vector2
var target: Vector2
var idle_remaining: float = 0.0
var mood: String = "Settled"
var mood_remaining: float = 0.0

func _init(identity: String, kind: String, start: Vector2) -> void:
	id = identity
	element = kind
	position = start
	target = start

func get_activity() -> String:
	if idle_remaining > 0.0:
		return "Taking in the garden"
	return "Wandering"

func set_temporary_mood(value: String, duration: float) -> void:
	mood = value
	mood_remaining = duration

