extends Node

const MainScene = preload("res://Main.tscn")

var game
var failures: Array[String] = []


func _ready() -> void:
	call_deferred("run")


func run() -> void:
	game = MainScene.instantiate()
	get_tree().root.add_child(game)
	await get_tree().process_frame
	test_random_first_player()
	test_board_orientation_and_hidden_hand()
	test_spell_enables_attack_without_copy()
	test_explicit_phase_flow_and_unopposed_attack()
	test_passing_defense_uses_zero_def()
	test_mission_starts_hidden_and_reveals()
	test_support_unlock_and_fixed_hand()
	for attack_id in ["power_strike_001", "precise_attack_001", "execution_001", "coordinated_attack_001"]:
		test_attack_technique(attack_id)
	for defense_id in ["guard_001", "total_block_001", "support_cover_001", "endure_001"]:
		test_defense_technique(defense_id)
	test_mission_failures()
	await test_ai_and_human_can_start()
	if failures.is_empty():
		print("TEST_OK: fases explícitas, defensa activa, ataques sin defensa, hechizos, tamaños, IA y misiones.")
		get_tree().quit(0)
	else:
		for failure in failures:
			push_error(failure)
		get_tree().quit(1)


func reset_combat() -> void:
	game.selected_game_mode = game.GAME_MODE_PVP
	game.active_player = game.PLAYER_A
	game.phase = game.PHASE_POSITIONING
	game.game_over = false
	game.player_a_hand.clear()
	game.player_b_hand.clear()
	game.player_a_front.fill(null)
	game.player_a_support.fill(null)
	game.player_b_front.fill(null)
	game.player_b_support.fill(null)
	game.player_a_support_unlocked.fill(false)
	game.player_b_support_unlocked.fill(false)
	game.player_a_main_deck.draw_pile.clear()
	game.player_b_main_deck.draw_pile.clear()
	game.player_a_main_deck.discard_pile.clear()
	game.player_b_main_deck.discard_pile.clear()
	game.player_a_main_discard = game.player_a_main_deck.discard_pile
	game.player_b_main_discard = game.player_b_main_deck.discard_pile
	var mission: Dictionary = {
		"id": "test_mission", "name": "Prueba", "vp": 1,
		"fail_condition": "assigned_deaths", "fail_threshold": 99,
		"dead_assigned_count": 0
	}
	for index in range(game.MISSION_COUNT):
		game.player_a_active_missions[index] = mission.duplicate(true)
		game.player_b_active_missions[index] = mission.duplicate(true)
	game.clear_combat_selection()


func combat_card(card_id: String) -> Dictionary:
	return game.create_combat_character(CardDatabase.get_card(card_id))


func select_combat(attacker: Dictionary, target: Dictionary) -> void:
	game.player_a_front[0] = attacker
	game.player_b_front[0] = target
	game.selected_attacker = attacker
	game.selected_target = target
	game.selected_attacker_info = {"player": game.PLAYER_A, "row": game.ROW_FRONT, "mission_index": 0}


func test_attack_technique(card_id: String) -> void:
	reset_combat()
	var attacker: Dictionary = combat_card("assassin_001")
	var target: Dictionary = combat_card("defender_001")
	if card_id == "execution_001":
		target["hp"] = 2
	if card_id == "coordinated_attack_001":
		game.player_a_support[0] = combat_card("tank_001")
	select_combat(attacker, target)
	game.player_a_hand.append(CardDatabase.get_card(card_id))
	game.player_b_hand.append(CardDatabase.get_card("defender_001"))
	var hp_before: int = int(target["hp"])
	game.prepare_attack_with_card(0)
	check(game.phase == game.PHASE_DEFENSE_RESPONSE, "%s no abrió respuesta de defensa" % card_id)
	check(game.player_a_hand.is_empty(), "%s no se consumió" % card_id)
	game.prepare_defense_with_copy()
	check(int(target["hp"]) == hp_before - 1, "%s calculó daño incorrecto" % card_id)
	check(game.player_a_main_discard.size() == 1, "%s no llegó al descarte exactamente una vez" % card_id)
	check(not game.attack_pending and game.pending_attack_card == null, "%s dejó efectos pendientes" % card_id)


func test_defense_technique(card_id: String) -> void:
	reset_combat()
	var attacker: Dictionary = combat_card("specialist_001")
	var target: Dictionary = combat_card("assassin_001")
	if card_id == "endure_001":
		target["hp"] = 2
	if card_id == "support_cover_001":
		game.player_b_support[0] = combat_card("tank_001")
	select_combat(attacker, target)
	game.player_a_hand.append(CardDatabase.get_card("specialist_001"))
	game.player_b_hand.append(CardDatabase.get_card(card_id))
	game.prepare_attack_with_copy()
	check(game.phase == game.PHASE_DEFENSE_RESPONSE, "%s no recibió oportunidad de defensa" % card_id)
	game.prepare_defense_with_card(0)
	var expected_hp: int = 1 if card_id == "endure_001" else 3
	check(int(target["hp"]) == expected_hp, "%s calculó VID incorrecta" % card_id)
	check(game.player_b_main_discard.size() == 1, "%s no llegó al descarte exactamente una vez" % card_id)
	check(game.pending_defense_card == null and not game.attack_pending, "%s dejó efectos pendientes" % card_id)


func test_random_first_player() -> void:
	seed(20260831)
	var seen_a: bool = false
	var seen_b: bool = false
	for _index in range(64):
		var result: String = game.choose_first_player()
		seen_a = seen_a or result == game.PLAYER_A
		seen_b = seen_b or result == game.PLAYER_B
	check(seen_a and seen_b, "El sorteo inicial no produjo ambos jugadores")


func test_board_orientation_and_hidden_hand() -> void:
	reset_combat()
	game.selected_game_mode = game.GAME_MODE_AI
	game.player_b_hand.append(CardDatabase.get_card("assassin_001"))
	game.player_b_hand.append(CardDatabase.get_card("power_strike_001"))
	game.refresh_all()
	check(game.player_a_hand_scroll.get_parent() == game.player_hand_dock_content, "La mano A no quedó fijada fuera del scroll del tablero")
	check(game.mission_battlefield.get_child_count() == 3, "El tablero no creó tres columnas de misión")
	check(game.get_node("MarginContainer/MainScroll") is MarginContainer, "El battlefield todavía usa ScrollContainer")
	check(game.player_a_hand_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "La mano todavía permite scroll horizontal")
	check(game.player_b_hand_title.text == "MANO IA — 2 CARTAS (OCULTAS)", "El contador de mano IA no es correcto")
	for card_back in game.player_b_hand_container.get_children():
		check(card_back.text.is_empty(), "La mano IA reveló información sobre una carta")


func test_spell_enables_attack_without_copy() -> void:
	reset_combat()
	game.player_a_front[1] = combat_card("assassin_001")
	game.player_b_front[1] = combat_card("defender_001")
	game.player_a_hand.append(CardDatabase.get_card("power_strike_001"))
	game.refresh_all()
	check(game.phase == game.PHASE_POSITIONING, "El turno no comienza en posicionamiento")
	check(not game.can_attack_from_position(game.PLAYER_A, game.ROW_FRONT, 1), "Permitió atacar durante posicionamiento")
	game.begin_attack_phase()
	check(game.can_attack_from_position(game.PLAYER_A, game.ROW_FRONT, 1), "Una carta ATTACK no habilitó al personaje sin copia")
	game._on_field_card_pressed(game.PLAYER_A, game.ROW_FRONT, 1)
	check(game.selected_attacker == game.player_a_front[1], "No seleccionó directamente al atacante válido")
	check(game.resource_choice_mode.is_empty(), "Abrió recursos antes de seleccionar objetivo")
	game._on_field_card_pressed(game.PLAYER_B, game.ROW_FRONT, 1)
	check(game.resource_choice_mode == game.CHOICE_ATTACK, "No abrió el panel de técnicas Attack")
	check(game.CARD_SIZE == Vector2(145.0, 195.0), "Las cartas no usan la escala compacta del battlefield")
	check(game.MISSION_CARD_SIZE == Vector2(210.0, 151.0), "La misión no conserva su proporción horizontal")
	check(game.HIDDEN_CARD_SIZE == game.CARD_SIZE, "Los reversos de la IA no respetan el tamaño único")
	var mission_b_stack: Control = game.create_mission_front_stack(game.PLAYER_B, 0)
	var mission_a_stack: Control = game.create_mission_front_stack(game.PLAYER_A, 0)
	check(is_equal_approx(float(mission_b_stack.get_child(1).rotation), PI), "Las misiones B no miran hacia el jugador B")
	check(is_zero_approx(float(mission_a_stack.get_child(1).rotation)), "Las misiones A no miran hacia el jugador A")
	mission_b_stack.free()
	mission_a_stack.free()


func test_explicit_phase_flow_and_unopposed_attack() -> void:
	reset_combat()
	var attacker: Dictionary = combat_card("assassin_001")
	var target: Dictionary = combat_card("defender_001")
	game.player_a_front[0] = attacker
	game.player_b_front[0] = target
	game.player_a_hand.append(CardDatabase.get_card("power_strike_001"))
	game.player_a_hand.append(CardDatabase.get_card("tank_001"))
	game.refresh_all()
	check(game.phase == game.PHASE_POSITIONING, "No inició el flujo en POSITIONING")
	check(game.play_character_from_hand(game.PLAYER_A, 1, game.ROW_FRONT, 1), "El posicionamiento dejó de aceptar personajes")
	game.begin_attack_phase()
	check(game.phase == game.PHASE_ATTACK, "FINALIZAR POSICIONAMIENTO no entró a ATTACK")
	var hand_size: int = game.player_a_hand.size()
	check(not game.play_character_from_hand(game.PLAYER_A, hand_size - 1, game.ROW_SUPPORT, 1), "ATTACK permitió posicionar un personaje")
	game._on_field_card_pressed(game.PLAYER_A, game.ROW_FRONT, 0)
	check(game.selected_attacker == attacker and game.selected_target == null, "La selección de atacante eligió objetivo automáticamente")
	check(not game.attack_button.disabled, "El botón quedó bloqueado mientras esperaba el único objetivo legal")
	game.request_attack_selection()
	check(game.selected_target == target and game.resource_choice_mode == game.CHOICE_ATTACK, "La ruta segura no seleccionó el FRONT opuesto ni abrió recursos")
	game.prepare_attack_with_card(0)
	check(game.phase == game.PHASE_ATTACK, "Sin recursos defensivos el juego preguntó defensa en vez de resolver")
	check(int(target["hp"]) == int(target["max_hp"]) - 4, "Un ataque sin defensa aplicó indebidamente la DEF base")
	check(game.phase == game.PHASE_ATTACK and game.active_player == game.PLAYER_A, "La resolución no devolvió el control a ATTACK")
	check(game.selected_attacker == null and game.selected_target == null and not game.attack_pending, "La resolución dejó estado temporal")
	game._on_pass_pressed()
	check(game.active_player == game.PLAYER_B and game.phase == game.PHASE_POSITIONING, "Finalizar turno no inició POSITIONING del rival")


func test_passing_defense_uses_zero_def() -> void:
	reset_combat()
	var attacker: Dictionary = combat_card("assassin_001")
	var target: Dictionary = combat_card("defender_001")
	select_combat(attacker, target)
	game.player_a_hand.append(CardDatabase.get_card("power_strike_001"))
	game.player_b_hand.append(CardDatabase.get_card("defender_001"))
	game.prepare_attack_with_card(0)
	check(game.phase == game.PHASE_DEFENSE_RESPONSE, "Con recursos no ofreció respuesta defensiva activa")
	check(game.defend_button.visible and game.pass_button.text == "PASAR DEFENSA", "La UI todavía presenta una defensa pasiva")
	game.pass_defense_from_choice()
	check(int(target["hp"]) == 1, "Pasar defensa aplicó indebidamente la DEF del personaje")


func test_mission_starts_hidden_and_reveals() -> void:
	reset_combat()
	game.player_a_active_missions[0] = game.prepare_active_mission({"id": "hidden_test", "name": "Oculta", "vp": 1})
	check(not bool(game.player_a_active_missions[0].get("revealed", true)), "La misión no comenzó boca abajo")
	game.player_a_hand.append(CardDatabase.get_card("assassin_001"))
	check(game.play_character_from_hand(game.PLAYER_A, 0, game.ROW_FRONT, 0), "No se pudo asignar personaje para revelar misión")
	check(bool(game.player_a_active_missions[0].get("revealed", false)), "La misión no se reveló al colocar personaje")
	check(bool(game.player_a_active_missions[0].get("details_visible", false)), "La misión no mostró sus detalles al revelarse")
	var stack: Control = game.create_mission_front_stack(game.PLAYER_A, 0)
	check(stack.get_child_count() == 3, "Support, misión y Front no comparten el mismo lane stack")
	check(stack.get_child(2).position.y < stack.get_child(1).position.y, "Front A no quedó superpuesto sobre la misión")
	stack.free()
	game._on_mission_card_pressed(game.PLAYER_A, 0)
	check(not bool(game.player_a_active_missions[0].get("details_visible", true)), "El clic no ocultó los detalles de misión")
	game._on_mission_card_pressed(game.PLAYER_A, 0)
	check(bool(game.player_a_active_missions[0].get("details_visible", false)), "El clic directo no volvió a mostrar los detalles")


func test_support_unlock_and_fixed_hand() -> void:
	reset_combat()
	game.player_a_hand.append(CardDatabase.get_card("tank_001"))
	check(not game.play_character_from_hand(game.PLAYER_A, 0, game.ROW_SUPPORT, 0), "SUPPORT aceptó carta antes de colocar FRONT")
	check(not game.is_support_unlocked(game.PLAYER_A, 0), "SUPPORT comenzó expandido")
	game.player_a_hand.append(CardDatabase.get_card("assassin_001"))
	check(game.play_character_from_hand(game.PLAYER_A, 1, game.ROW_FRONT, 0), "No se pudo colocar FRONT para habilitar SUPPORT")
	check(game.is_support_unlocked(game.PLAYER_A, 0), "SUPPORT no se expandió después de colocar FRONT")
	check(game.play_character_from_hand(game.PLAYER_A, 0, game.ROW_SUPPORT, 0), "SUPPORT no aceptó carta después de habilitarse")
	check(game.player_a_support[0] != null, "La carta no quedó colocada en SUPPORT")


func test_ai_and_human_can_start() -> void:
	var seed_a: int = find_seed_for_first_player(game.PLAYER_A)
	var seed_b: int = find_seed_for_first_player(game.PLAYER_B)
	var definition: Dictionary = game.get_preset_definition("Balance")
	seed(seed_a)
	game.start_game_with_definitions(game.GAME_MODE_AI, definition, definition)
	check(game.active_player == game.PLAYER_A, "El humano no pudo comenzar con un sorteo A")
	seed(seed_b)
	game.ai_action_delay = 0.01
	game.start_game_with_definitions(game.GAME_MODE_AI, definition, definition)
	check(game.active_player == game.PLAYER_B, "La IA no pudo comenzar con un sorteo B")
	await get_tree().create_timer(1.0).timeout
	check(game.game_over or game.active_player == game.PLAYER_A, "La IA que comenzó no devolvió el control al humano")


func find_seed_for_first_player(wanted: String) -> int:
	for candidate in range(1, 1000):
		seed(candidate)
		if game.choose_first_player() == wanted:
			return candidate
	return 1


func test_mission_failures() -> void:
	reset_combat()
	var replacement_ids: Array[String] = ["mission_defeat_enemy_001", "mission_defeat_enemy_001", "mission_defeat_enemy_001"]
	game.player_a_mission_deck.build_from_mission_ids(replacement_ids)
	game.player_a_mission_discard = game.player_a_mission_deck.discard_pile
	game.player_a_active_missions[0] = game.prepare_active_mission({"id": "front_fail", "name": "Front", "fail_condition": "front_defeated"})
	game.register_assigned_death(game.PLAYER_A, 0, game.ROW_FRONT)
	check(game.player_a_mission_discard.has("front_fail"), "No descartó la misión al caer Front")
	check(int(game.player_a_active_missions[0].get("dead_assigned_count", -1)) == 0, "La misión de reemplazo heredó bajas")

	game.player_a_active_missions[1] = game.prepare_active_mission({"id": "two_fail", "name": "Dos bajas", "fail_condition": "assigned_deaths", "fail_threshold": 2})
	game.register_assigned_death(game.PLAYER_A, 1, game.ROW_FRONT)
	check(not game.player_a_mission_discard.has("two_fail"), "Falló antes de alcanzar dos bajas")
	game.register_assigned_death(game.PLAYER_A, 1, game.ROW_SUPPORT)
	check(game.player_a_mission_discard.has("two_fail"), "No falló al alcanzar dos bajas")

	game.player_a_active_missions[2] = game.prepare_active_mission({"id": "all_fail", "name": "Todos", "fail_condition": "all_assigned_defeated"})
	game.player_a_support[2] = combat_card("tank_001")
	game.register_assigned_death(game.PLAYER_A, 2, game.ROW_FRONT)
	check(not game.player_a_mission_discard.has("all_fail"), "Falló aunque quedaba un apoyo asignado")
	game.player_a_support[2] = null
	game.register_assigned_death(game.PLAYER_A, 2, game.ROW_SUPPORT)
	check(game.player_a_mission_discard.has("all_fail"), "No falló al caer todos los asignados")


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
