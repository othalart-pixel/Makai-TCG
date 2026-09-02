extends RefCounted

const MissionDatabaseScript = preload("res://data/mission_database.gd")
const TEST_MISSION_ID := "mission_defeat_enemy_001"
const TEST_DECK_SIZE := 12

var database = MissionDatabaseScript.new()
var draw_pile: Array[String] = []
var discard_pile: Array[String] = []


func build_test_mission_deck() -> bool:
	draw_pile.clear()
	discard_pile.clear()
	if not database.load_missions():
		return false

	for _index in range(TEST_DECK_SIZE):
		draw_pile.append(TEST_MISSION_ID)
	shuffle_missions()
	return true


func build_from_mission_ids(mission_ids: Array[String]) -> bool:
	draw_pile.clear()
	discard_pile.clear()
	if not database.load_missions():
		return false

	for mission_id in mission_ids:
		if database.get_mission(mission_id) != null:
			draw_pile.append(mission_id)
		else:
			push_warning("Misión ignorada al construir Mission Deck: " + mission_id)

	shuffle_missions()
	return true


func shuffle_missions() -> void:
	draw_pile.shuffle()


func draw_mission():
	if draw_pile.is_empty():
		return null
	var mission_id: String = draw_pile.pop_front()
	return database.get_mission(mission_id)


func discard_mission(mission: Dictionary) -> bool:
	if not mission.has("id"):
		return false
	discard_pile.append(str(mission["id"]))
	return true


func get_draw_pile_count() -> int:
	return draw_pile.size()


func get_discard_pile_count() -> int:
	return discard_pile.size()
