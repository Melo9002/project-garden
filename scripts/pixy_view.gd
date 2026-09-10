class_name PixyView
extends Node3D
## Presentation for one simulated pixy. Geometry is authored in pixy_placeholder.tscn.

@export var hover_amplitude: float = 0.08
@export var hover_speed: float = 1.8
@onready var body: Node3D = $Body
@onready var name_label: Label3D = $NameLabel
var phase: float = 0.0

func setup(kind: String, tint: Color, offset: float) -> void:
	phase = offset
	name_label.text = kind
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.9
	$Body/Torso.material_override = material
	$Body/Head.material_override = material

func sync(state: PixyState, time: float) -> void:
	position = Vector3(state.position.x, 0.65, state.position.y)
	body.position.y = sin(time * hover_speed + phase) * hover_amplitude

