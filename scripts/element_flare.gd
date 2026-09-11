class_name ElementFlare
extends Node3D
## Short-lived presentation for elemental energy already produced by simulation.

@export_range(0.3, 3.0, 0.1) var lifetime: float = 1.35
@export_range(0.0, 2.0, 0.05) var rise_speed: float = 0.45
var age := 0.0
var phase := 0.0
var drift_direction := 1.0
var glow_color := Color.WHITE

func setup(color: Color, variation: float) -> void:
	glow_color = color.lightened(0.28)
	phase = variation * 2.7
	drift_direction = -1.0 if int(variation) % 2 == 0 else 1.0
	_apply_alpha(0.0)

func _process(delta: float) -> void:
	age += delta
	var progress := age / lifetime
	if progress >= 1.0:
		queue_free()
		return
	position.y += rise_speed * delta
	position.x += sin(age * 4.2 + phase) * 0.055 * delta * drift_direction
	var envelope := sin(progress * PI)
	scale = Vector3.ONE * lerpf(0.55, 1.15, envelope)
	_apply_alpha(envelope)

func _apply_alpha(alpha: float) -> void:
	$Glow.modulate = Color(glow_color.r, glow_color.g, glow_color.b, alpha * 0.9)
	$Streak.modulate = Color(glow_color.r, glow_color.g, glow_color.b, alpha * 0.72)
