class_name FlowerPatch
extends Node3D
## Small authored garden object with a placement-preview outline.

@export var valid_preview_material: Material
@export var invalid_preview_material: Material
@export var item_kind: StringName = &"flower"

func show_placement_preview(valid: bool) -> void:
	$ValidRing.visible = valid
	$InvalidRing.visible = not valid
	for mesh in find_children("*", "MeshInstance3D"):
		if mesh != $ValidRing and mesh != $InvalidRing:
			mesh.material_overlay = valid_preview_material if valid else invalid_preview_material

func finish_placement() -> void:
	$ValidRing.visible = false
	$InvalidRing.visible = false
	for mesh in find_children("*", "MeshInstance3D"):
		mesh.material_overlay = null
