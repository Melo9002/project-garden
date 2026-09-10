class_name FlowerPatch
extends Node3D
## Small authored garden object with a placement-preview outline.

func show_placement_preview(valid: bool) -> void:
	$ValidRing.visible = valid
	$InvalidRing.visible = not valid

func finish_placement() -> void:
	$ValidRing.visible = false
	$InvalidRing.visible = false
