extends RefCounted

var draw_pile: Array = []
var hand: Array = []
var discard_pile: Array = []

var hand_size: int = 5


func build_test_deck() -> void:
	draw_pile.clear()
	hand.clear()
	discard_pile.clear()

	# Mazo de prueba usando IDs del cards.json.
	# Puedes cambiar cantidades después.
	var deck_list: Array = [
		"assassin_001",
		"assassin_001",
		"assassin_001",

		"defender_001",
		"defender_001",
		"defender_001",

		"tank_001",
		"tank_001",
		"tank_001",

		"fighter_001",
		"fighter_001",
		"fighter_001",

		"specialist_001",
		"specialist_001",
		"specialist_001",

		"power_strike_001",
		"precise_attack_001",
		"execution_001",
		"coordinated_attack_001",

		"guard_001",
		"total_block_001",
		"support_cover_001",
		"endure_001",

		"tactical_replacement_001",
		"planning_001",
		"filter_hand_001"
	]

	for card_id in deck_list:
		if CardDatabase.has_card(card_id):
			draw_pile.append(card_id)
		else:
			print("ADVERTENCIA: carta no encontrada: ", card_id)

	shuffle_deck()

	print("Mazo creado con ", draw_pile.size(), " cartas.")


func build_from_card_ids(card_ids: Array[String]) -> void:
	draw_pile.clear()
	hand.clear()
	discard_pile.clear()

	for card_id in card_ids:
		if CardDatabase.has_card(card_id):
			draw_pile.append(card_id)
		else:
			push_warning("Carta ignorada al construir Main Deck: " + card_id)

	shuffle_deck()
	print("Main Deck personalizado creado con ", draw_pile.size(), " cartas.")


func shuffle_deck() -> void:
	draw_pile.shuffle()


func draw_card():
	if draw_pile.is_empty():
		print("No quedan cartas en el mazo.")
		return null

	var card_id = draw_pile.pop_front()
	var card = CardDatabase.get_card(card_id)

	if card == null:
		print("ERROR: no se pudo cargar la carta ", card_id)
		return null

	hand.append(card)
	return card


func draw_starting_hand() -> Array:
	hand.clear()

	for i in range(hand_size):
		if draw_pile.is_empty():
			break

		draw_card()

	return hand


func draw_cards(amount: int) -> Array:
	var drawn: Array = []

	for i in range(amount):
		var card = draw_card()

		if card == null:
			break

		drawn.append(card)

	return drawn


func discard_from_hand(index: int) -> bool:
	if index < 0 or index >= hand.size():
		return false

	var card = hand[index]

	if card.has("id"):
		discard_pile.append(card["id"])

	hand.remove_at(index)

	return true


func discard_card(card: Dictionary) -> bool:
	if not card.has("id"):
		return false

	discard_pile.append(str(card["id"]))
	return true


func get_hand() -> Array:
	return hand


func get_draw_pile_count() -> int:
	return draw_pile.size()


func get_discard_pile_count() -> int:
	return discard_pile.size()
