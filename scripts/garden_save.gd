class_name GardenSave
extends RefCounted
## JSON persistence boundary. Simulation data goes in; scene nodes stay out.

const SAVE_PATH := "user://garden_save.json"

static func exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func write(data: Dictionary) -> Error:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	return OK

static func read() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}
