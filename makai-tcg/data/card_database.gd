extends Node

var cards: Dictionary = {}


func load_cards() -> void:
	var file = FileAccess.open(
		"res://data/cards.json",
		FileAccess.READ
	)

	if file == null:
		print("ERROR: no se pudo abrir cards.json")
		return

	var text: String = file.get_as_text()
	var data = JSON.parse_string(text)

	if data == null:
		print("ERROR: JSON invalido")
		return

	cards.clear()

	for card in data:
		if card.has("id"):
			cards[str(card["id"])] = card

	print("Cartas cargadas: ", cards.size())


func get_card(card_id: String):
	if cards.has(card_id):
		return cards[card_id].duplicate(true)

	return null


func has_card(card_id: String) -> bool:
	return cards.has(card_id)


func get_all_cards() -> Array:
	var result: Array = []

	for card_id in cards:
		result.append(cards[card_id].duplicate(true))

	return result


func get_cards_by_type(card_type: String) -> Array:
	var result: Array = []
	for card_id in cards:
		var card: Dictionary = cards[card_id]
		if str(card.get("type", "")) == card_type:
			result.append(card.duplicate(true))
	return result
