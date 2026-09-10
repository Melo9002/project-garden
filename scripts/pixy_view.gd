class_name PixyView
extends Node3D
## Temporary geometric stand-in. Replace this scene's visual content with sprites later.

var body: Node3D
var phase: float

func setup(kind: String, tint: Color, offset: float) -> void:
	phase = offset
	body = Node3D.new()
	add_child(body)
	var mesh := MeshInstance3D.new()
	var shape := CapsuleMesh.new()
	shape.radius = 0.17
	shape.height = 0.55
	mesh.mesh = shape
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.9
	mesh.material_override = material
	body.add_child(mesh)
	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.19
	sphere.height = 0.38
	head.mesh = sphere
	head.position.y = 0.35
	head.material_override = material
	body.add_child(head)
	var label := Label3D.new()
	label.text = kind
	label.font_size = 38
	label.pixel_size = 0.007
	label.position.y = 0.91
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(0.95, 0.96, 0.85)
	add_child(label)

func sync(state: PixyState, time: float) -> void:
	position = Vector3(state.position.x, 0.65, state.position.y)
	body.position.y = sin(time * 1.8 + phase) * 0.08

