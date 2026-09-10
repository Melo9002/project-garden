class_name GardenSimulation
extends RefCounted
## Seeded movement model. Does not access scene nodes or artwork.

var pixies: Array[PixyState] = []
var random := RandomNumberGenerator.new()
var elapsed: float = 0.0

func _init() -> void:
	random.seed = 240910
	var elements := ["Earth", "Fire", "Wind", "Water"]
	for i in range(elements.size()):
		pixies.append(PixyState.new("pixy_%d" % i, elements[i], Vector2(-2.4 + i * 1.6, 0.5)))

func advance(delta: float) -> void:
	elapsed += delta
	for pixy in pixies:
		if pixy.idle_remaining > 0.0:
			pixy.idle_remaining -= delta
			continue
		if pixy.position.distance_to(pixy.target) < 0.05:
			pixy.target = Vector2(random.randf_range(-7.0, 7.0), random.randf_range(-2.4, 2.1))
			pixy.idle_remaining = random.randf_range(1.0, 3.0)
		else:
			pixy.position = pixy.position.move_toward(pixy.target, delta * 0.38)

