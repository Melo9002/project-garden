class_name PixyView
extends Node3D
## Presentation for one simulated pixy. Geometry is authored in pixy_placeholder.tscn.

signal selected(view: PixyView)

@export var hover_amplitude: float = 0.08
@export var hover_speed: float = 1.8
@onready var body: Node3D = $Body
@onready var sprite: Sprite3D = $Body/Sprite3D
@onready var name_label: Label3D = $NameLabel
@onready var selection_ring: MeshInstance3D = $SelectionRing
var phase: float = 0.0
var selected_now := false
var pointer_over := false

func setup(kind: String, tint: Color, offset: float) -> void:
	phase = offset
	name_label.text = kind
	sprite.modulate = tint.lightened(0.18)

func sync(state: PixyState, time: float) -> void:
	position = Vector3(state.position.x, 0.65, state.position.y)
	body.position.y = sin(time * hover_speed + phase) * hover_amplitude
	var emphasis := 1.08 if selected_now else (1.04 if pointer_over else 1.0)
	body.scale = Vector3.ONE * emphasis

func set_selected(value: bool) -> void:
	selected_now = value
	selection_ring.visible = value

func _on_pick_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)

func _on_pick_area_mouse_entered() -> void:
	pointer_over = true

func _on_pick_area_mouse_exited() -> void:
	pointer_over = false

