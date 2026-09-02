extends RefCounted


func choose_utility_card(hand: Array, draw_pile_count: int) -> Dictionary:
	for index in range(hand.size()):
		var card: Dictionary = hand[index]
		if str(card.get("type", "")) != "utility":
			continue
		match str(card.get("effect", "")):
			"draw":
				if draw_pile_count >= int(card.get("draw", 0)):
					return {"hand_index": index, "card": card}
			"discard_draw":
				var discard_count: int = int(card.get("discard", 0))
				var draw_count: int = int(card.get("draw", 0))
				if hand.size() - 1 >= discard_count and draw_pile_count >= draw_count:
					if discard_count == 1 or hand.size() <= 5 or count_type(hand, "character") == 0:
						return {"hand_index": index, "card": card}
	return {}


func choose_card_to_play(hand: Array, fronts: Array, supports: Array, missions: Array, enemy_fronts: Array) -> Dictionary:
	var front_open: bool = fronts.any(func(card): return card == null)
	var candidates: Array[Dictionary] = []
	for hand_index in range(hand.size()):
		var card: Dictionary = hand[hand_index]
		if str(card.get("type", "")) != "character":
			continue
		if count_card_id(hand, str(card.get("id", ""))) == 1 and (contains_card_id(fronts, str(card.get("id", ""))) or contains_card_id(supports, str(card.get("id", "")))):
			continue
		for mission_index in range(fronts.size()):
			var row: String = ""
			if front_open and fronts[mission_index] == null:
				row = "front"
			elif not front_open and fronts[mission_index] != null and supports[mission_index] == null:
				row = "support"
			if row.is_empty():
				continue
			var score: int = score_slot(card, row, mission_index, fronts, supports, missions, enemy_fronts)
			candidates.append({"hand_index": hand_index, "card": card, "row": row, "mission_index": mission_index, "score": score})
	return choose_highest(candidates)


func choose_slot(card: Dictionary, fronts: Array, supports: Array, missions: Array, enemy_fronts: Array) -> Dictionary:
	var fake_hand: Array = [card]
	return choose_card_to_play(fake_hand, fronts, supports, missions, enemy_fronts)


func choose_attacker(candidates: Array) -> Dictionary:
	var choice: Dictionary = choose_highest(candidates)
	if not choice.is_empty() and int(choice.get("score", 0)) <= 0:
		return {}
	return choice


func choose_attack_method(methods: Array) -> Dictionary:
	return choose_highest(methods)


func choose_defense_method(options: Array, undefended_damage: int, defender_hp: int) -> Dictionary:
	var saving_options: Array[Dictionary] = []
	for option in options:
		if int(option.get("expected_damage", undefended_damage)) < defender_hp:
			saving_options.append(option)
	if undefended_damage >= defender_hp and not saving_options.is_empty():
		return choose_lowest_damage(saving_options)
	if undefended_damage >= 2:
		var best: Dictionary = choose_lowest_damage(options)
		if not best.is_empty() and int(best.get("expected_damage", undefended_damage)) < undefended_damage:
			return best
	return {"kind": "pass", "name": "PASS DEFENSE", "expected_damage": undefended_damage}


func choose_discards(hand: Array, count: int, missions: Array) -> Array[int]:
	var ranked: Array[Dictionary] = []
	for index in range(hand.size()):
		var card: Dictionary = hand[index]
		var keep_score: int = card_keep_score(card, missions)
		ranked.append({"hand_index": index, "score": keep_score})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary): return int(a["score"]) < int(b["score"]))
	var result: Array[int] = []
	for index in range(mini(count, ranked.size())):
		result.append(int(ranked[index]["hand_index"]))
	return result


func should_pass_turn(has_useful_action: bool) -> bool:
	return not has_useful_action


func score_slot(card: Dictionary, row: String, mission_index: int, fronts: Array, supports: Array, missions: Array, enemy_fronts: Array) -> int:
	var score: int = 4 if row == "front" else 2
	if mission_index < missions.size() and mission_matches_card(missions[mission_index], card):
		score += 2
	if mission_index < enemy_fronts.size() and enemy_fronts[mission_index] != null:
		score += 1
	if row == "front" and mission_index < supports.size() and supports[mission_index] != null:
		score += 1
	if row == "support" and mission_index < fronts.size() and fronts[mission_index] != null:
		score += 2
	return score


func mission_matches_card(mission: Variant, card: Dictionary) -> bool:
	return mission != null and str(mission.get("target_class", "")) == str(card.get("class", ""))


func card_keep_score(card: Dictionary, missions: Array) -> int:
	var score: int = 0
	match str(card.get("type", "")):
		"character":
			score = 4
			for mission in missions:
				if mission_matches_card(mission, card):
					score += 2
		"attack", "defense":
			score = 3
		"utility":
			score = 1
	return score


func count_type(hand: Array, card_type: String) -> int:
	var count: int = 0
	for card in hand:
		if str(card.get("type", "")) == card_type:
			count += 1
	return count


func count_card_id(cards: Array, card_id: String) -> int:
	var count: int = 0
	for card in cards:
		if card != null and str(card.get("id", "")) == card_id:
			count += 1
	return count


func contains_card_id(cards: Array, card_id: String) -> bool:
	return count_card_id(cards, card_id) > 0


func choose_highest(candidates: Array) -> Dictionary:
	if candidates.is_empty():
		return {}
	var best_score: int = -100000
	var best: Array[Dictionary] = []
	for candidate in candidates:
		var score: int = int(candidate.get("score", 0))
		if score > best_score:
			best_score = score
			best = [candidate]
		elif score == best_score:
			best.append(candidate)
	return best.pick_random().duplicate(true)


func choose_lowest_damage(options: Array) -> Dictionary:
	if options.is_empty():
		return {}
	var best_damage: int = 100000
	var best: Array[Dictionary] = []
	for option in options:
		var damage: int = int(option.get("expected_damage", best_damage))
		if damage < best_damage:
			best_damage = damage
			best = [option]
		elif damage == best_damage:
			best.append(option)
	return best.pick_random().duplicate(true)
