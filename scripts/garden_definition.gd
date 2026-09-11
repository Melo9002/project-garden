class_name GardenDefinition
extends Resource
## Shared spatial rules for one garden. Visual geometry remains in garden.tscn.

const MEADOW := &"meadow"
const WATER := &"water"
const OUTSIDE := &"outside"

@export var reachable_bounds := Rect2(-7.0, -3.0, 14.0, 7.0)
## Ordered left-to-right shoreline points (X, Z). Also used by Lakeshore's editor mesh.
@export var shoreline := PackedVector2Array([Vector2(-40, 1.8), Vector2(-10, 1.8), Vector2(-7, 1.4), Vector2(-4, 1.8), Vector2(-1, 1.5), Vector2(2, 2.1), Vector2(5, 1.6), Vector2(8, 1.9), Vector2(40, 1.9)])
@export var water_center := Vector2(0.8, 3.1)
@export var meadow_height: float = 0.06
@export var water_height: float = -0.16
@export_group("Element sources")
@export_range(0.1, 3.0, 0.1) var flower_influence_radius: float = 1.2
@export_range(-2.0, 2.0, 0.1) var open_air_start: float = 0.7
@export_range(0.0, 1.0, 0.05) var daylight_exposure: float = 0.25
@export_group("Scenario targets")
@export_range(0.0, 1.0, 0.05) var earth_target: float = 0.6
@export_range(0.0, 1.0, 0.05) var fire_target: float = 0.45
@export_range(0.0, 1.0, 0.05) var wind_target: float = 0.5
@export_range(0.0, 1.0, 0.05) var water_target: float = 0.55

func surface_at(point: Vector2) -> StringName:
	if not reachable_bounds.has_point(point):
		return OUTSIDE
	if point.y >= shore_z_at(point.x):
		return WATER
	return MEADOW

func shore_z_at(x: float) -> float:
	assert(shoreline.size() >= 2, "A lakeshore needs at least two ordered points")
	for i in range(1, shoreline.size()):
		if x <= shoreline[i].x:
			var a := shoreline[i - 1]
			var b := shoreline[i]
			return lerpf(a.y, b.y, clampf(inverse_lerp(a.x, b.x, x), 0.0, 1.0))
	return shoreline[-1].y

func surface_height_at(point: Vector2) -> float:
	# A short sloped bank keeps hovering motion continuous at the shoreline.
	return lerpf(meadow_height, water_height, smoothstep(shore_z_at(point.x) - 0.18, shore_z_at(point.x), point.y))

func random_water_point(random: RandomNumberGenerator) -> Vector2:
	var x := random.randf_range(reachable_bounds.position.x, reachable_bounds.end.x)
	return Vector2(x, random.randf_range(shore_z_at(x) + 0.15, reachable_bounds.end.y - 0.15))

func random_reachable_point(random: RandomNumberGenerator) -> Vector2:
	return Vector2(
		random.randf_range(reachable_bounds.position.x, reachable_bounds.end.x),
		random.randf_range(reachable_bounds.position.y, reachable_bounds.end.y)
	)

func can_place_flower(point: Vector2) -> bool:
	return surface_at(point) == MEADOW

func nearest_meadow_point(point: Vector2) -> Vector2:
	# Older saves may contain flowers where the enlarged lake now lies.
	var x := clampf(point.x, reachable_bounds.position.x + 0.05, reachable_bounds.end.x - 0.05)
	var z := clampf(point.y, reachable_bounds.position.y + 0.05, minf(shore_z_at(x) - 0.25, reachable_bounds.end.y - 0.05))
	return Vector2(x, z)

func elemental_exposure_at(point: Vector2, flowers: Array[Vector2]) -> Dictionary:
	var exposure := {"Earth": 0.0, "Fire": daylight_exposure, "Wind": 0.0, "Water": 0.0}
	if surface_at(point) == WATER:
		exposure["Water"] = 1.0
	if point.y >= open_air_start:
		exposure["Wind"] = clampf(inverse_lerp(open_air_start, reachable_bounds.end.y, point.y), 0.25, 1.0)
	for flower in flowers:
		var distance := point.distance_to(flower)
		if distance <= flower_influence_radius:
			exposure["Earth"] = maxf(float(exposure["Earth"]), 1.0 - distance / flower_influence_radius)
	return exposure

func energy_targets() -> Dictionary:
	return {"Earth": earth_target, "Fire": fire_target, "Wind": wind_target, "Water": water_target}
