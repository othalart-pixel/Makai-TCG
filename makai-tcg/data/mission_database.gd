extends RefCounted

var missions: Dictionary = {}


func load_missions() -> bool:
	var file: FileAccess = FileAccess.open("res://data/missions.json", FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir missions.json")
		return false

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Array):
		push_error("missions.json debe contener un Array")
		return false

	missions.clear()
	for mission in parsed:
		if mission is Dictionary and mission.has("id"):
			missions[str(mission["id"])] = mission

	return not missions.is_empty()


func get_mission(mission_id: String):
	if not missions.has(mission_id):
		return null
	return missions[mission_id].duplicate(true)


func get_all_missions() -> Array:
	var result: Array = []
	for mission_id in missions:
		result.append(missions[mission_id].duplicate(true))
	return result
