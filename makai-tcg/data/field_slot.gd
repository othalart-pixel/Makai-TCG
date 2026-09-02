extends Button

signal card_dropped(slot_index: int, payload: Dictionary)

var slot_index: int = -1
var accepts_cards: bool = true


func configure(index: int) -> void:
	slot_index = index


func _can_drop_data(_at_position: Vector2, data) -> bool:
	return accepts_cards and data is Dictionary and data.get("kind", "") == "hand_card" and data.get("card_type", "") == "character"


func _drop_data(_at_position: Vector2, data) -> void:
	if _can_drop_data(_at_position, data):
		card_dropped.emit(slot_index, data)
