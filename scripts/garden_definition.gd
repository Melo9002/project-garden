class_name GardenDefinition
extends Resource
## Shared spatial rules for one garden. Visual geometry remains in garden.tscn.

const MEADOW := &"meadow"
const WATER := &"water"
const OUTSIDE := &"outside"

@export var reachable_bounds := Rect2(-7.0, -2.4, 14.0, 4.5)
@export var water_center := Vector2(0.8, -2.7)
@export var water_radius := Vector2(2.55, 0.72)

func surface_at(point: Vector2) -> StringName:
	var lake_distance := (point - water_center) / water_radius
	if lake_distance.length_squared() <= 1.0:
		return WATER
	if not reachable_bounds.has_point(point):
		return OUTSIDE
	return MEADOW

func random_reachable_point(random: RandomNumberGenerator) -> Vector2:
	return Vector2(
		random.randf_range(reachable_bounds.position.x, reachable_bounds.end.x),
		random.randf_range(reachable_bounds.position.y, reachable_bounds.end.y)
	)

func can_place_flower(point: Vector2) -> bool:
	return surface_at(point) == MEADOW
