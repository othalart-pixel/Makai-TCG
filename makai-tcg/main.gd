extends Control

const DeckScript = preload("res://data/deck.gd")
const MissionDeckScript = preload("res://data/mission_deck.gd")
const MissionDatabaseScript = preload("res://data/mission_database.gd")
const CardButtonScript = preload("res://data/card_button.gd")
const FieldSlotScript = preload("res://data/field_slot.gd")
const SimpleAIScript = preload("res://ai/simple_ai.gd")
const CardVisualsScript = preload("res://data/card_visuals.gd")

const PLAYER_A := "A"
const PLAYER_B := "B"
const ROW_FRONT := "front"
const ROW_SUPPORT := "support"
const PHASE_POSITIONING := "positioning"
const PHASE_ATTACK := "attack"
const PHASE_DEFENSE_RESPONSE := "defense_response"
const PHASE_RESOLUTION := "resolution"
const PHASE_TURN_END := "turn_end"
const CHOICE_ATTACK := "attack"
const CHOICE_DEFENSE := "defense"
const CHOICE_UTILITY := "utility"
const GAME_MODE_PVP := "pvp"
const GAME_MODE_AI := "ai"
const MISSION_COUNT := 3
const VICTORY_VP := 5
const MAIN_DECK_MAX := 40
const MISSION_DECK_MAX := 10
const DECK_SAVE_PATH := "user://decks.json"
const CARD_SIZE := Vector2(145.0, 195.0)
const MISSION_CARD_SIZE := Vector2(210.0, 151.0)
const HIDDEN_CARD_SIZE := CARD_SIZE
const SUPPORT_COLLAPSED_SIZE := Vector2(CARD_SIZE.x, 42.0)
const MISSION_FRONT_STACK_SIZE := Vector2(240.0, 270.0)
const HAND_VIEWPORT_WIDTH_MARGIN := 64.0
const MISSION_REVEAL_SECONDS := 2.5
const MAX_AI_ACTIONS_PER_TURN := 20
const AI_ACTION_DELAY := 0.55

@onready var player_a_hand_container: HBoxContainer = %PlayerAHand
@onready var player_b_hand_container: HBoxContainer = %PlayerBHand
@onready var mission_battlefield: HBoxContainer = %MissionBattlefield
@onready var player_a_hand_title: Label = %PlayerAHandTitle
@onready var player_b_hand_title: Label = %PlayerBHandTitle
@onready var game_board_vbox: VBoxContainer = $MarginContainer/MainScroll/MainVBox
@onready var player_a_hand_scroll: ScrollContainer = $MarginContainer/MainScroll/MainVBox/PlayerAHandScroll
@onready var player_b_hand_scroll: ScrollContainer = $MarginContainer/MainScroll/MainVBox/PlayerBHandScroll
@onready var player_a_discard_row: HBoxContainer = $MarginContainer/MainScroll/MainVBox/PlayerADiscardRow
@onready var player_b_discard_row: HBoxContainer = $MarginContainer/MainScroll/MainVBox/PlayerBDiscardRow
@onready var action_row: HBoxContainer = $MarginContainer/MainScroll/MainVBox/ActionRow
@onready var game_hud_sidebar: Control = %GameHudSidebar
@onready var hud_sidebar_panel: PanelContainer = %HudSidebarPanel
@onready var hud_sidebar_content: VBoxContainer = %HudSidebarContent
@onready var hud_sidebar_toggle: Button = %HudSidebarToggle
@onready var player_hand_dock: Control = %PlayerHandDock
@onready var player_hand_dock_content: VBoxContainer = %PlayerHandDockContent
@onready var player_a_header: Label = %PlayerAHeader
@onready var player_b_header: Label = %PlayerBHeader
@onready var status_label: Label = %StatusLabel
@onready var attack_button: Button = %AttackButton
@onready var defend_button: Button = %DefendButton
@onready var pass_button: Button = %PassButton
@onready var resource_choice_panel: VBoxContainer = %ResourceChoicePanel
@onready var resource_choice_title: Label = %ResourceChoiceTitle
@onready var resource_choice_row: VBoxContainer = %ResourceChoiceRow
@onready var game_board: MarginContainer = $MarginContainer
@onready var deck_builder: MarginContainer = %DeckBuilder
@onready var main_menu: MarginContainer = %MainMenu
@onready var pvp_setup: MarginContainer = %PvpSetup
@onready var ai_setup: MarginContainer = %AiSetup
@onready var main_deck_counter: Label = %MainDeckCounter
@onready var mission_deck_counter: Label = %MissionDeckCounter
@onready var main_available_list: VBoxContainer = %MainAvailableList
@onready var main_deck_list: VBoxContainer = %MainDeckList
@onready var mission_available_list: VBoxContainer = %MissionAvailableList
@onready var mission_deck_list: VBoxContainer = %MissionDeckList
@onready var deck_builder_status: Label = %DeckBuilderStatus
@onready var deck_name_input: LineEdit = %DeckNameInput
@onready var saved_deck_selector: OptionButton = %SavedDeckSelector
@onready var new_deck_button: Button = %NewDeckButton
@onready var save_deck_button: Button = %SaveDeckButton
@onready var load_deck_button: Button = %LoadDeckButton
@onready var delete_deck_button: Button = %DeleteDeckButton
@onready var aggro_preset_button: Button = %AggroPresetButton
@onready var balance_preset_button: Button = %BalancePresetButton
@onready var control_preset_button: Button = %ControlPresetButton
@onready var back_to_menu_from_builder_button: Button = %BackToMenuFromBuilderButton
@onready var player_a_main_discard_label: Label = %PlayerAMainDiscardLabel
@onready var player_b_main_discard_label: Label = %PlayerBMainDiscardLabel
@onready var player_a_mission_discard_label: Label = %PlayerAMissionDiscardLabel
@onready var player_b_mission_discard_label: Label = %PlayerBMissionDiscardLabel
@onready var view_player_a_discard_button: Button = %ViewPlayerADiscardButton
@onready var view_player_b_discard_button: Button = %ViewPlayerBDiscardButton
@onready var discard_panel: PanelContainer = %DiscardPanel
@onready var discard_panel_title: Label = %DiscardPanelTitle
@onready var discard_panel_content: Label = %DiscardPanelContent
@onready var close_discard_button: Button = %CloseDiscardButton
@onready var play_pvp_menu_button: Button = %PlayPvpMenuButton
@onready var play_ai_menu_button: Button = %PlayAiMenuButton
@onready var manage_decks_menu_button: Button = %ManageDecksMenuButton
@onready var pvp_player_1_deck_selector: OptionButton = %PvpPlayer1DeckSelector
@onready var pvp_player_2_deck_selector: OptionButton = %PvpPlayer2DeckSelector
@onready var ai_human_deck_selector: OptionButton = %AiHumanDeckSelector
@onready var ai_opponent_deck_selector: OptionButton = %AiOpponentDeckSelector
@onready var pvp_setup_status: Label = %PvpSetupStatus
@onready var ai_setup_status: Label = %AiSetupStatus
@onready var start_pvp_button: Button = %StartPvpButton
@onready var back_from_pvp_button: Button = %BackFromPvpButton
@onready var start_ai_button: Button = %StartAiButton
@onready var back_from_ai_button: Button = %BackFromAiButton
@onready var end_game_panel: PanelContainer = %EndGamePanel
@onready var end_game_title: Label = %EndGameTitle
@onready var replay_button: Button = %ReplayButton
@onready var end_game_menu_button: Button = %EndGameMenuButton

var player_a_main_deck = DeckScript.new()
var player_a_mission_deck = MissionDeckScript.new()
var player_b_main_deck = DeckScript.new()
var player_b_mission_deck = MissionDeckScript.new()
var deck_builder_mission_database = MissionDatabaseScript.new()
var main_deck_composition: Dictionary = {}
var mission_deck_composition: Dictionary = {}
var saved_decks: Dictionary = {}
var simple_ai = SimpleAIScript.new()
var selected_game_mode: String = GAME_MODE_PVP
var ai_turn_running: bool = false
var ai_action_delay: float = AI_ACTION_DELAY
var current_player_a_deck_definition: Dictionary = {}
var current_player_b_deck_definition: Dictionary = {}

var player_a_main_discard: Array = []
var player_a_mission_discard: Array = []
var player_b_main_discard: Array = []
var player_b_mission_discard: Array = []

var player_a_hand: Array = []
var player_b_hand: Array = []
var player_a_front: Array = [null, null, null]
var player_a_support: Array = [null, null, null]
var player_b_front: Array = [null, null, null]
var player_b_support: Array = [null, null, null]
var player_a_active_missions: Array = [null, null, null]
var player_b_active_missions: Array = [null, null, null]
var player_a_support_unlocked: Array[bool] = [false, false, false]
var player_b_support_unlocked: Array[bool] = [false, false, false]

var player_a_vp: int = 0
var player_b_vp: int = 0
var active_player: String = PLAYER_A
var phase: String = PHASE_POSITIONING
var game_over: bool = false

var selected_attacker_info: Dictionary = {}
var selected_attacker = null
var selected_target = null
var status_message: String = ""
var resource_choice_mode: String = ""
var pending_attack_card = null
var attack_pending: bool = false
var pending_attack_bonus: int = 0
var pending_ignore_defense: int = 0
var pending_defense_card = null
var pending_defense_bonus: int = 0
var pending_damage_reduction: int = 0
var pending_survive_at_one: bool = false
var pending_utility_card = null
var pending_utility_discard_required: int = 0
var pending_utility_draw_count: int = 0
var selected_utility_discard_indices: Array[int] = []


func _ready() -> void:
	CardDatabase.load_cards()
	deck_builder_mission_database.load_missions()
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	pass_button.pressed.connect(_on_pass_pressed)
	new_deck_button.pressed.connect(create_new_builder_deck)
	save_deck_button.pressed.connect(save_current_deck)
	load_deck_button.pressed.connect(load_selected_deck)
	delete_deck_button.pressed.connect(delete_selected_deck)
	aggro_preset_button.pressed.connect(load_preset.bind("Aggro"))
	balance_preset_button.pressed.connect(load_preset.bind("Balance"))
	control_preset_button.pressed.connect(load_preset.bind("Defensa / Control"))
	back_to_menu_from_builder_button.pressed.connect(show_main_menu)
	view_player_a_discard_button.pressed.connect(show_main_discard.bind(PLAYER_A))
	view_player_b_discard_button.pressed.connect(show_main_discard.bind(PLAYER_B))
	close_discard_button.pressed.connect(hide_discard_panel)
	play_pvp_menu_button.pressed.connect(show_pvp_setup)
	play_ai_menu_button.pressed.connect(show_ai_setup)
	manage_decks_menu_button.pressed.connect(show_deck_builder)
	start_pvp_button.pressed.connect(start_pvp_from_setup)
	back_from_pvp_button.pressed.connect(show_main_menu)
	start_ai_button.pressed.connect(start_ai_from_setup)
	back_from_ai_button.pressed.connect(show_main_menu)
	replay_button.pressed.connect(replay_current_match)
	end_game_menu_button.pressed.connect(show_main_menu)
	hud_sidebar_toggle.pressed.connect(toggle_hud_sidebar)
	load_saved_decks()
	move_game_hud_to_sidebar()
	move_player_hand_to_dock()
	arrange_game_board()
	show_main_menu()
	refresh_deck_builder()


func arrange_game_board() -> void:
	# El rival siempre queda arriba y el jugador A abajo, incluso si cambia el turno.
	var ordered_nodes: Array[Node] = [
		mission_battlefield
	]
	for target_index in range(ordered_nodes.size()):
		game_board_vbox.move_child(ordered_nodes[target_index], target_index)
	player_a_hand_title.visible = false
	player_b_hand_title.visible = false
	player_b_hand_scroll.visible = false
	player_a_header.visible = false
	player_b_header.visible = false
	player_a_discard_row.visible = true
	player_b_discard_row.visible = true


func move_game_hud_to_sidebar() -> void:
	status_label.reparent(hud_sidebar_content, false)
	action_row.reparent(hud_sidebar_content, false)
	resource_choice_panel.reparent(hud_sidebar_content, false)
	player_a_discard_row.reparent(hud_sidebar_content, false)
	player_b_discard_row.reparent(hud_sidebar_content, false)
	hud_sidebar_panel.visible = false
	hud_sidebar_toggle.text = "◀"
	hud_sidebar_toggle.tooltip_text = "Mostrar estado y acciones"


func move_player_hand_to_dock() -> void:
	player_a_hand_title.reparent(player_hand_dock_content, false)
	player_a_hand_scroll.reparent(player_hand_dock_content, false)
	player_a_hand_scroll.visible = true
	player_b_hand_scroll.visible = false


func update_visible_hand_dock() -> void:
	var visible_player: String = PLAYER_A if selected_game_mode == GAME_MODE_AI else (other_player(active_player) if phase == PHASE_DEFENSE_RESPONSE else active_player)
	var visible_scroll: ScrollContainer = player_a_hand_scroll if visible_player == PLAYER_A else player_b_hand_scroll
	var hidden_scroll: ScrollContainer = player_b_hand_scroll if visible_player == PLAYER_A else player_a_hand_scroll
	if visible_scroll.get_parent() != player_hand_dock_content:
		if hidden_scroll.get_parent() == player_hand_dock_content:
			hidden_scroll.reparent(game_board_vbox, false)
		visible_scroll.reparent(player_hand_dock_content, false)
	visible_scroll.visible = true
	hidden_scroll.visible = false


func toggle_hud_sidebar() -> void:
	hud_sidebar_panel.visible = not hud_sidebar_panel.visible
	hud_sidebar_toggle.text = "▶" if hud_sidebar_panel.visible else "◀"
	hud_sidebar_toggle.tooltip_text = "Ocultar estado y acciones" if hud_sidebar_panel.visible else "Mostrar estado y acciones"


func set_game_mode(game_mode: String) -> void:
	selected_game_mode = GAME_MODE_AI if game_mode == GAME_MODE_AI else GAME_MODE_PVP


func hide_navigation_screens() -> void:
	main_menu.visible = false
	pvp_setup.visible = false
	ai_setup.visible = false
	deck_builder.visible = false
	game_board.visible = false
	game_hud_sidebar.visible = false
	player_hand_dock.visible = false
	end_game_panel.visible = false
	discard_panel.visible = false


func show_main_menu() -> void:
	hide_navigation_screens()
	main_menu.visible = true


func show_pvp_setup() -> void:
	hide_navigation_screens()
	refresh_game_deck_selectors()
	pvp_setup_status.text = ""
	pvp_setup.visible = true


func show_ai_setup() -> void:
	hide_navigation_screens()
	refresh_game_deck_selectors()
	ai_setup_status.text = ""
	ai_setup.visible = true


func show_deck_builder() -> void:
	hide_navigation_screens()
	deck_builder.visible = true
	refresh_deck_builder()


func start_pvp_from_setup() -> void:
	var player_1_definition: Dictionary = selected_deck_definition(pvp_player_1_deck_selector)
	var player_2_definition: Dictionary = selected_deck_definition(pvp_player_2_deck_selector)
	if not is_valid_deck_definition(player_1_definition) or not is_valid_deck_definition(player_2_definition):
		pvp_setup_status.text = "Selecciona un mazo válido para ambos jugadores."
		return
	start_game_with_definitions(GAME_MODE_PVP, player_1_definition, player_2_definition)


func start_ai_from_setup() -> void:
	var human_definition: Dictionary = selected_deck_definition(ai_human_deck_selector)
	var opponent_definition: Dictionary = selected_deck_definition(ai_opponent_deck_selector)
	if not is_valid_deck_definition(human_definition) or not is_valid_deck_definition(opponent_definition):
		ai_setup_status.text = "Selecciona tu mazo y el mazo de la IA."
		return
	start_game_with_definitions(GAME_MODE_AI, human_definition, opponent_definition)


func start_game_from_builder() -> void:
	if composition_total(main_deck_composition) != MAIN_DECK_MAX:
		deck_builder_status.text = "El Main Deck debe tener exactamente 40 cartas para jugar."
		return
	if composition_total(mission_deck_composition) != MISSION_DECK_MAX:
		deck_builder_status.text = "El Mission Deck debe tener exactamente 10 misiones para jugar."
		return
	var builder_definition: Dictionary = deck_definition_from_compositions("Editor", main_deck_composition, mission_deck_composition)
	start_game_with_definitions(selected_game_mode, builder_definition, builder_definition)


func start_game_with_definitions(game_mode: String, player_a_definition: Dictionary, player_b_definition: Dictionary) -> void:
	if not is_valid_deck_definition(player_a_definition) or not is_valid_deck_definition(player_b_definition):
		return
	var first_player: String = choose_first_player()
	set_game_mode(game_mode)
	current_player_a_deck_definition = player_a_definition.duplicate(true)
	current_player_b_deck_definition = player_b_definition.duplicate(true)

	var player_a_main_ids: Array[String] = definition_main_ids(player_a_definition)
	var player_b_main_ids: Array[String] = definition_main_ids(player_b_definition)
	var player_a_mission_ids: Array[String] = definition_mission_ids(player_a_definition)
	var player_b_mission_ids: Array[String] = definition_mission_ids(player_b_definition)

	player_a_main_deck = create_main_deck_instance(player_a_main_ids)
	player_b_main_deck = create_main_deck_instance(player_b_main_ids)
	player_a_mission_deck = create_mission_deck_instance(player_a_mission_ids)
	player_b_mission_deck = create_mission_deck_instance(player_b_mission_ids)

	player_a_hand = player_a_main_deck.draw_starting_hand()
	player_b_hand = player_b_main_deck.draw_starting_hand()
	player_a_main_discard = player_a_main_deck.discard_pile
	player_b_main_discard = player_b_main_deck.discard_pile
	player_a_mission_discard = player_a_mission_deck.discard_pile
	player_b_mission_discard = player_b_mission_deck.discard_pile
	player_a_front.fill(null)
	player_a_support.fill(null)
	player_b_front.fill(null)
	player_b_support.fill(null)
	player_a_support_unlocked.fill(false)
	player_b_support_unlocked.fill(false)
	player_a_active_missions.fill(null)
	player_b_active_missions.fill(null)
	player_a_vp = 0
	player_b_vp = 0
	active_player = first_player
	transition_to_phase(PHASE_POSITIONING, "comienza el turno de %s" % player_name(active_player))
	game_over = false
	ai_turn_running = false
	clear_combat_selection()
	initialize_missions()

	hide_navigation_screens()
	game_board.visible = true
	game_hud_sidebar.visible = true
	player_hand_dock.visible = true
	hud_sidebar_panel.visible = false
	hud_sidebar_toggle.text = "◀"
	status_message = "JUGADOR %s COMIENZA. Cada jugador colocó tres misiones boca abajo." % active_player
	print("Partida iniciada: A usa ", player_a_definition.get("name", "Deck A"), " y B usa ", player_b_definition.get("name", "Deck B"), ".")
	refresh_all()
	if is_ai_controlled(active_player):
		call_deferred("run_ai_turn")


func transition_to_phase(next_phase: String, reason: String = "") -> void:
	phase = next_phase
	var debug_line: String = "[TURN] %s" % phase_display_name(next_phase).to_upper()
	if not reason.is_empty():
		debug_line += " — " + reason
	print(debug_line)


func phase_display_name(phase_id: String) -> String:
	match phase_id:
		PHASE_POSITIONING:
			return "POSICIONAMIENTO"
		PHASE_ATTACK:
			return "ATAQUE"
		PHASE_DEFENSE_RESPONSE:
			return "RESPUESTA DEFENSIVA"
		PHASE_RESOLUTION:
			return "RESOLUCIÓN"
		PHASE_TURN_END:
			return "FIN DE TURNO"
	return phase_id.to_upper()


func choose_first_player() -> String:
	return PLAYER_A if randi_range(0, 1) == 0 else PLAYER_B


func create_main_deck_instance(card_ids: Array[String]):
	var deck = DeckScript.new()
	deck.build_from_card_ids(card_ids.duplicate())
	return deck


func create_mission_deck_instance(mission_ids: Array[String]):
	var deck = MissionDeckScript.new()
	deck.build_from_mission_ids(mission_ids.duplicate())
	return deck


func replay_current_match() -> void:
	if current_player_a_deck_definition.is_empty() or current_player_b_deck_definition.is_empty():
		show_main_menu()
		return
	start_game_with_definitions(selected_game_mode, current_player_a_deck_definition, current_player_b_deck_definition)


func refresh_deck_builder() -> void:
	main_deck_counter.text = "MAIN DECK: %d / %d" % [composition_total(main_deck_composition), MAIN_DECK_MAX]
	mission_deck_counter.text = "MISSION DECK: %d / %d" % [composition_total(mission_deck_composition), MISSION_DECK_MAX]
	refresh_main_builder_lists()
	refresh_mission_builder_lists()


func refresh_main_builder_lists() -> void:
	clear_container(main_available_list)
	clear_container(main_deck_list)
	for card in CardDatabase.get_all_cards():
		var card_id: String = str(card.get("id", ""))
		var amount: int = int(main_deck_composition.get(card_id, 0))
		var add_button: Button = Button.new()
		add_button.text = "%s — %s — x%d" % [str(card.get("name", "Carta")), card_type_name(str(card.get("type", ""))), amount]
		add_button.pressed.connect(add_main_card.bind(card_id))
		main_available_list.add_child(add_button)

		if amount > 0:
			var remove_button: Button = Button.new()
			remove_button.text = "[-] %s — %s — x%d" % [str(card.get("name", "Carta")), card_type_name(str(card.get("type", ""))), amount]
			remove_button.pressed.connect(remove_main_card.bind(card_id))
			main_deck_list.add_child(remove_button)

	if main_deck_composition.is_empty():
		add_builder_empty_label(main_deck_list, "Main Deck vacío")


func refresh_mission_builder_lists() -> void:
	clear_container(mission_available_list)
	clear_container(mission_deck_list)
	for mission in deck_builder_mission_database.get_all_missions():
		var mission_id: String = str(mission.get("id", ""))
		var amount: int = int(mission_deck_composition.get(mission_id, 0))
		var add_button: Button = Button.new()
		add_button.text = "%s — MISIÓN — x%d" % [str(mission.get("name", "Misión")), amount]
		add_button.pressed.connect(add_mission_card.bind(mission_id))
		mission_available_list.add_child(add_button)

		if amount > 0:
			var remove_button: Button = Button.new()
			remove_button.text = "[-] %s — x%d" % [str(mission.get("name", "Misión")), amount]
			remove_button.pressed.connect(remove_mission_card.bind(mission_id))
			mission_deck_list.add_child(remove_button)

	if mission_deck_composition.is_empty():
		add_builder_empty_label(mission_deck_list, "Mission Deck vacío")


func add_main_card(card_id: String) -> void:
	if composition_total(main_deck_composition) >= MAIN_DECK_MAX:
		deck_builder_status.text = "MAIN DECK alcanzó el máximo de 40 cartas."
		return
	main_deck_composition[card_id] = int(main_deck_composition.get(card_id, 0)) + 1
	deck_builder_status.text = "Carta agregada al Main Deck."
	refresh_deck_builder()


func remove_main_card(card_id: String) -> void:
	remove_composition_card(main_deck_composition, card_id)
	deck_builder_status.text = "Carta retirada del Main Deck."
	refresh_deck_builder()


func add_mission_card(mission_id: String) -> void:
	if composition_total(mission_deck_composition) >= MISSION_DECK_MAX:
		deck_builder_status.text = "MISSION DECK alcanzó el máximo de 10 cartas."
		return
	mission_deck_composition[mission_id] = int(mission_deck_composition.get(mission_id, 0)) + 1
	deck_builder_status.text = "Misión agregada al Mission Deck."
	refresh_deck_builder()


func remove_mission_card(mission_id: String) -> void:
	remove_composition_card(mission_deck_composition, mission_id)
	deck_builder_status.text = "Misión retirada del Mission Deck."
	refresh_deck_builder()


func remove_composition_card(composition: Dictionary, card_id: String) -> void:
	var amount: int = int(composition.get(card_id, 0))
	if amount <= 1:
		composition.erase(card_id)
	else:
		composition[card_id] = amount - 1


func create_new_builder_deck() -> void:
	main_deck_composition.clear()
	mission_deck_composition.clear()
	deck_name_input.text = ""
	deck_builder_status.text = "Nuevo deck vacío."
	refresh_deck_builder()


func load_preset(preset_name: String) -> void:
	var definition: Dictionary = get_preset_definition(preset_name)
	main_deck_composition = ids_to_composition(definition_main_ids(definition))
	mission_deck_composition = ids_to_composition(definition_mission_ids(definition))
	deck_name_input.text = preset_name
	deck_builder_status.text = "Prearmado %s cargado: Main 40 / Mission 10." % preset_name
	refresh_deck_builder()


func get_preset_definition(preset_name: String) -> Dictionary:
	var preset_main: Dictionary = {}
	var preset_missions: Dictionary = {}
	match preset_name:
		"Aggro":
			preset_main = {
				"assassin_001": 6, "fighter_001": 5, "specialist_001": 5, "defender_001": 3, "tank_001": 3,
				"power_strike_001": 3, "precise_attack_001": 3, "execution_001": 2, "coordinated_attack_001": 2,
				"guard_001": 1, "total_block_001": 1, "support_cover_001": 1, "endure_001": 1,
				"planning_001": 2, "filter_hand_001": 1, "tactical_replacement_001": 1
			}
			preset_missions = {
				"mission_assassin_atk_001": 3, "mission_light_fighter_atk_001": 3,
				"mission_specialist_atk_001": 2, "mission_assassin_def_001": 1,
				"mission_defeat_enemy_001": 1
			}
		"Defensa / Control":
			preset_main = {
				"defender_001": 6, "tank_001": 6, "fighter_001": 4, "assassin_001": 3, "specialist_001": 3,
				"power_strike_001": 1, "precise_attack_001": 1, "execution_001": 1, "coordinated_attack_001": 1,
				"guard_001": 3, "total_block_001": 3, "support_cover_001": 2, "endure_001": 2,
				"tactical_replacement_001": 1, "planning_001": 2, "filter_hand_001": 1
			}
			preset_missions = {
				"mission_defender_def_001": 3, "mission_tank_def_001": 3,
				"mission_assassin_def_001": 2, "mission_defeat_enemy_001": 2
			}
		_:
			preset_name = "Balance"
			preset_main = {
				"assassin_001": 4, "defender_001": 4, "tank_001": 4, "fighter_001": 4, "specialist_001": 4,
				"power_strike_001": 2, "precise_attack_001": 2, "execution_001": 2, "coordinated_attack_001": 1,
				"guard_001": 2, "total_block_001": 2, "support_cover_001": 2, "endure_001": 1,
				"tactical_replacement_001": 2, "planning_001": 2, "filter_hand_001": 2
			}
			preset_missions = {
				"mission_assassin_def_001": 2, "mission_defender_def_001": 2,
				"mission_assassin_atk_001": 1, "mission_light_fighter_atk_001": 1,
				"mission_tank_def_001": 1, "mission_specialist_atk_001": 1,
				"mission_defeat_enemy_001": 2
			}
	return deck_definition_from_compositions(preset_name, preset_main, preset_missions, "preset")


func get_preset_names() -> Array[String]:
	return ["Aggro", "Balance", "Defensa / Control"]


func save_current_deck() -> void:
	var deck_name: String = deck_name_input.text.strip_edges()
	if deck_name.is_empty():
		deck_builder_status.text = "Escribe un nombre antes de guardar."
		return
	if composition_total(main_deck_composition) != MAIN_DECK_MAX or composition_total(mission_deck_composition) != MISSION_DECK_MAX:
		deck_builder_status.text = "Para guardar: Main Deck 40 y Mission Deck 10."
		return
	saved_decks[deck_name] = deck_definition_from_compositions(deck_name, main_deck_composition, mission_deck_composition, "saved")
	if write_saved_decks():
		deck_builder_status.text = "Deck '%s' guardado o sobrescrito." % deck_name
		refresh_saved_deck_selector(deck_name)
		refresh_game_deck_selectors()


func load_selected_deck() -> void:
	var deck_name: String = selected_saved_deck_name()
	if deck_name.is_empty() or not saved_decks.has(deck_name):
		deck_builder_status.text = "Selecciona un deck guardado."
		return
	var deck_data: Dictionary = normalize_deck_definition(deck_name, saved_decks[deck_name])
	if not is_valid_deck_definition(deck_data):
		deck_builder_status.text = "El deck guardado no cumple Main 40 / Mission 10."
		return
	main_deck_composition = ids_to_composition(definition_main_ids(deck_data))
	mission_deck_composition = ids_to_composition(definition_mission_ids(deck_data))
	deck_name_input.text = deck_name
	deck_builder_status.text = "Deck '%s' cargado." % deck_name
	refresh_deck_builder()


func delete_selected_deck() -> void:
	var deck_name: String = selected_saved_deck_name()
	if deck_name.is_empty() or not saved_decks.has(deck_name):
		deck_builder_status.text = "Selecciona un deck para borrar."
		return
	saved_decks.erase(deck_name)
	if write_saved_decks():
		deck_builder_status.text = "Deck '%s' borrado." % deck_name
		refresh_saved_deck_selector()
		refresh_game_deck_selectors()


func load_saved_decks() -> void:
	saved_decks.clear()
	if FileAccess.file_exists(DECK_SAVE_PATH):
		var file: FileAccess = FileAccess.open(DECK_SAVE_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				saved_decks = parsed
	refresh_saved_deck_selector()
	refresh_game_deck_selectors()


func write_saved_decks() -> bool:
	var file: FileAccess = FileAccess.open(DECK_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		deck_builder_status.text = "No se pudo escribir decks.json."
		return false
	file.store_string(JSON.stringify(saved_decks, "  "))
	return true


func refresh_saved_deck_selector(preferred_name: String = "") -> void:
	saved_deck_selector.clear()
	var names: Array = saved_decks.keys()
	names.sort()
	for deck_name in names:
		saved_deck_selector.add_item(str(deck_name))
		saved_deck_selector.set_item_metadata(saved_deck_selector.item_count - 1, str(deck_name))
		if str(deck_name) == preferred_name:
			saved_deck_selector.select(saved_deck_selector.item_count - 1)


func selected_saved_deck_name() -> String:
	if saved_deck_selector.item_count == 0 or saved_deck_selector.selected < 0:
		return ""
	return str(saved_deck_selector.get_item_metadata(saved_deck_selector.selected))


func deck_definition_from_compositions(deck_name: String, main_composition: Dictionary, mission_composition: Dictionary, source: String = "saved") -> Dictionary:
	return {
		"name": deck_name,
		"main_deck": expand_composition(main_composition),
		"mission_deck": expand_composition(mission_composition),
		"source": source
	}


func normalize_deck_definition(deck_name: String, raw_definition: Variant) -> Dictionary:
	if not (raw_definition is Dictionary):
		return {}
	var definition: Dictionary = raw_definition
	if definition.has("main_deck") and definition.has("mission_deck"):
		var normalized: Dictionary = definition.duplicate(true)
		normalized["name"] = str(definition.get("name", deck_name))
		normalized["source"] = str(definition.get("source", "saved"))
		return normalized
	if definition.has("main") and definition.has("mission"):
		return deck_definition_from_compositions(
			deck_name,
			definition.get("main", {}),
			definition.get("mission", {}),
			"saved"
		)
	return {}


func definition_main_ids(definition: Dictionary) -> Array[String]:
	return variant_to_id_array(definition.get("main_deck", definition.get("main", {})))


func definition_mission_ids(definition: Dictionary) -> Array[String]:
	return variant_to_id_array(definition.get("mission_deck", definition.get("mission", {})))


func variant_to_id_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for card_id in value:
			result.append(str(card_id))
	elif value is Dictionary:
		result = expand_composition(value)
	return result


func ids_to_composition(card_ids: Array[String]) -> Dictionary:
	var composition: Dictionary = {}
	for card_id in card_ids:
		composition[card_id] = int(composition.get(card_id, 0)) + 1
	return composition


func is_valid_deck_definition(definition: Dictionary) -> bool:
	var main_ids: Array[String] = definition_main_ids(definition)
	var mission_ids: Array[String] = definition_mission_ids(definition)
	if main_ids.size() != MAIN_DECK_MAX or mission_ids.size() != MISSION_DECK_MAX:
		return false
	for card_id in main_ids:
		if not CardDatabase.has_card(card_id):
			return false
	for mission_id in mission_ids:
		if deck_builder_mission_database.get_mission(mission_id) == null:
			return false
	return true


func refresh_game_deck_selectors() -> void:
	var selectors: Array[OptionButton] = [
		pvp_player_1_deck_selector,
		pvp_player_2_deck_selector,
		ai_human_deck_selector,
		ai_opponent_deck_selector
	]
	for selector in selectors:
		selector.clear()
		for preset_name in get_preset_names():
			selector.add_item("PREARMADO · %s" % preset_name)
			selector.set_item_metadata(selector.item_count - 1, "preset:" + preset_name)
		var names: Array = saved_decks.keys()
		names.sort()
		for deck_name in names:
			var definition: Dictionary = normalize_deck_definition(str(deck_name), saved_decks[deck_name])
			if is_valid_deck_definition(definition):
				selector.add_item("GUARDADO · %s" % str(deck_name))
				selector.set_item_metadata(selector.item_count - 1, "saved:" + str(deck_name))


func selected_deck_definition(selector: OptionButton) -> Dictionary:
	if selector.item_count == 0 or selector.selected < 0:
		return {}
	var key: String = str(selector.get_item_metadata(selector.selected))
	if key.begins_with("preset:"):
		return get_preset_definition(key.trim_prefix("preset:"))
	if key.begins_with("saved:"):
		var deck_name: String = key.trim_prefix("saved:")
		if saved_decks.has(deck_name):
			return normalize_deck_definition(deck_name, saved_decks[deck_name])
	return {}


func composition_total(composition: Dictionary) -> int:
	var total: int = 0
	for card_id in composition:
		total += int(composition[card_id])
	return total


func expand_composition(composition: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for card_id in composition:
		for _copy in range(int(composition[card_id])):
			result.append(str(card_id))
	return result


func card_type_name(card_type: String) -> String:
	match card_type:
		"character":
			return "PERSONAJE"
		"attack":
			return "ATAQUE"
		"defense":
			return "DEFENSA"
		"utility":
			return "UTILIDAD"
	return card_type.to_upper()


func add_builder_empty_label(container: VBoxContainer, text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(label)


func initialize_missions() -> void:
	for player_id in [PLAYER_A, PLAYER_B]:
		var active_missions: Array = get_active_missions(player_id)
		for mission_index in range(MISSION_COUNT):
			active_missions[mission_index] = prepare_active_mission(get_mission_deck(player_id).draw_mission())


func prepare_active_mission(mission: Variant) -> Variant:
	if mission == null or not mission is Dictionary:
		return null
	var active: Dictionary = mission.duplicate(true)
	active["dead_assigned_count"] = 0
	active["mission_state"] = "active"
	active["revealed"] = false
	active["details_visible"] = false
	return active


func mission_has_assigned_character(player_id: String, mission_index: int) -> bool:
	return get_field_row(player_id, ROW_FRONT)[mission_index] != null or get_field_row(player_id, ROW_SUPPORT)[mission_index] != null


func reveal_mission(player_id: String, mission_index: int) -> bool:
	var missions: Array = get_active_missions(player_id)
	if mission_index < 0 or mission_index >= missions.size() or missions[mission_index] == null:
		return false
	var mission: Dictionary = missions[mission_index]
	if bool(mission.get("revealed", false)):
		return false
	mission["revealed"] = true
	mission["details_visible"] = true
	return true


func present_revealed_mission(player_id: String, mission_index: int) -> void:
	var missions: Array = get_active_missions(player_id)
	if mission_index < 0 or mission_index >= missions.size() or missions[mission_index] == null:
		return
	var mission_id: String = str(missions[mission_index].get("id", ""))
	status_message = mission_detail_message(player_id, mission_index, missions[mission_index]) + "\nSe ocultará; después haz clic directamente en la misión para verla."
	hud_sidebar_panel.visible = true
	hud_sidebar_toggle.text = "▶"
	refresh_all()
	await get_tree().create_timer(MISSION_REVEAL_SECONDS).timeout
	if game_over:
		return
	missions = get_active_missions(player_id)
	if mission_index >= missions.size() or missions[mission_index] == null or str(missions[mission_index].get("id", "")) != mission_id:
		return
	missions[mission_index]["details_visible"] = false
	status_message = "La misión %s%d quedó resumida. Haz clic directamente en ella para consultar el texto." % [player_id, mission_index + 1]
	hud_sidebar_panel.visible = false
	hud_sidebar_toggle.text = "◀"
	refresh_all()


func _on_mission_card_pressed(player_id: String, mission_index: int) -> void:
	var missions: Array = get_active_missions(player_id)
	if mission_index < 0 or mission_index >= missions.size() or missions[mission_index] == null:
		return
	var mission: Dictionary = missions[mission_index]
	if not bool(mission.get("revealed", false)):
		status_message = "MISIÓN %s%d está boca abajo. Coloca un personaje en su Front para revelarla." % [player_id, mission_index + 1]
		refresh_all()
		return
	mission["details_visible"] = not bool(mission.get("details_visible", false))
	if bool(mission["details_visible"]):
		status_message = mission_detail_message(player_id, mission_index, mission)
		hud_sidebar_panel.visible = true
		hud_sidebar_toggle.text = "▶"
	else:
		status_message = "Detalles de MISIÓN %s%d ocultos." % [player_id, mission_index + 1]
	refresh_all()


func mission_detail_message(player_id: String, mission_index: int, mission: Dictionary) -> String:
	return "MISIÓN %s%d — %s\nOBJETIVO: Vence enemigo\nEFECTO: %s\nFALLA: %s\nRECOMPENSA: %d VP" % [player_id, mission_index + 1, str(mission.get("name", "Misión")), mission_card_effect_text(mission), mission_failure_short_text(mission), int(mission.get("vp", 1))]


func register_assigned_death(player_id: String, mission_index: int, defeated_row: String) -> String:
	var active_missions: Array = get_active_missions(player_id)
	if mission_index < 0 or mission_index >= active_missions.size() or active_missions[mission_index] == null:
		return ""
	var mission: Dictionary = active_missions[mission_index]
	mission["dead_assigned_count"] = int(mission.get("dead_assigned_count", 0)) + 1
	var condition: String = str(mission.get("fail_condition", ""))
	var failed: bool = false
	match condition:
		"front_defeated":
			failed = defeated_row == ROW_FRONT
		"assigned_deaths":
			failed = int(mission.get("dead_assigned_count", 0)) >= int(mission.get("fail_threshold", 1))
		"all_assigned_defeated":
			failed = get_field_row(player_id, ROW_FRONT)[mission_index] == null and get_field_row(player_id, ROW_SUPPORT)[mission_index] == null
	if not failed:
		return "MISIÓN %s%d registra %d baja(s) asignada(s)." % [player_id, mission_index + 1, int(mission.get("dead_assigned_count", 0))]
	return fail_mission(player_id, mission_index)


func fail_mission(player_id: String, mission_index: int) -> String:
	var active_missions: Array = get_active_missions(player_id)
	var failed_mission: Dictionary = active_missions[mission_index]
	failed_mission["mission_state"] = "failed"
	get_mission_deck(player_id).discard_mission(failed_mission)
	active_missions[mission_index] = prepare_active_mission(get_mission_deck(player_id).draw_mission())
	if active_missions[mission_index] != null and mission_has_assigned_character(player_id, mission_index):
		active_missions[mission_index]["revealed"] = true
	var message: String = "JUGADOR %s FALLA MISIÓN %d: %s. Sin VP." % [player_id, mission_index + 1, str(failed_mission.get("name", "Misión"))]
	if active_missions[mission_index] != null:
		if bool(active_missions[mission_index].get("revealed", false)):
			message += " Se revela una nueva misión porque aún hay un personaje asignado."
		else:
			message += " Se coloca una nueva misión boca abajo."
	else:
		message += " Su Mission Deck está vacío."
	return message


func create_combat_character(card: Dictionary) -> Dictionary:
	var character: Dictionary = card.duplicate(true)
	character["base_atk"] = int(card.get("base_atk", card.get("atk", 0)))
	character["base_def"] = int(card.get("base_def", card.get("def", 0)))
	character["max_hp"] = int(card.get("hp", 0))
	character["hp"] = int(card.get("hp", 0))
	return character


func play_character_from_hand(player_id: String, hand_index: int, row: String, mission_index: int, actor_label: String = "") -> bool:
	if game_over or phase != PHASE_POSITIONING or player_id != active_player:
		return false
	if mission_index < 0 or mission_index >= MISSION_COUNT or (row != ROW_FRONT and row != ROW_SUPPORT):
		return false
	if row == ROW_SUPPORT and not is_support_unlocked(player_id, mission_index):
		status_message = "Primero debes colocar un personaje en FRONT de MISIÓN %d para habilitar SUPPORT." % (mission_index + 1)
		refresh_all()
		return false
	var field_row: Array = get_field_row(player_id, row)
	var hand: Array = get_hand(player_id)
	if field_row[mission_index] != null or hand_index < 0 or hand_index >= hand.size():
		return false
	var card: Dictionary = hand[hand_index]
	if str(card.get("type", "")) != "character":
		return false
	hand.remove_at(hand_index)
	field_row[mission_index] = create_combat_character(card)
	if row == ROW_FRONT:
		unlock_support(player_id, mission_index)
	var mission_revealed: bool = reveal_mission(player_id, mission_index)
	var actor: String = actor_label if not actor_label.is_empty() else player_name(player_id)
	status_message = "%s juega %s en %s de MISIÓN %d." % [actor, str(card.get("name", "Carta")), row_display_name(row), mission_index + 1]
	if mission_revealed:
		status_message += " La misión de %s se revela y mostrará sus detalles brevemente." % player_name(player_id)
	print("Carta jugada: ", card.get("name", "Carta"), " en ", row, " misión ", mission_index + 1)
	refresh_all()
	if mission_revealed:
		call_deferred("present_revealed_mission", player_id, mission_index)
	return true


func _on_card_dropped(mission_index: int, payload: Dictionary, player_id: String, row: String) -> void:
	if game_over or ai_turn_running or is_ai_controlled(player_id) or not resource_choice_mode.is_empty() or phase != PHASE_POSITIONING or player_id != active_player:
		return
	if mission_index < 0 or mission_index >= MISSION_COUNT:
		return
	if row != ROW_FRONT and row != ROW_SUPPORT:
		return

	var field_row: Array = get_field_row(player_id, row)
	if field_row[mission_index] != null:
		status_message = "La posición %s %d ya está ocupada." % [row_display_name(row), mission_index + 1]
		refresh_all()
		return
	if str(payload.get("player_id", "")) != player_id or payload.get("kind", "") != "hand_card":
		return

	var hand: Array = get_hand(player_id)
	var hand_index: int = int(payload.get("hand_index", -1))
	if hand_index < 0 or hand_index >= hand.size():
		return
	var card: Dictionary = hand[hand_index]
	if str(card.get("id", "")) != str(payload.get("card_id", "")):
		return
	if str(card.get("type", "")) != "character":
		status_message = "Solo las cartas CHARACTER pueden entrar a Front o Support."
		refresh_all()
		return

	play_character_from_hand(player_id, hand_index, row, mission_index)


func _on_field_card_pressed(player_id: String, row: String, mission_index: int) -> void:
	if game_over or ai_turn_running or not resource_choice_mode.is_empty() or phase != PHASE_ATTACK:
		return
	var field_row: Array = get_field_row(player_id, row)
	if mission_index < 0 or mission_index >= MISSION_COUNT or field_row[mission_index] == null:
		return
	if player_id == active_player:
		if not can_attack_from_position(player_id, row, mission_index):
			status_message = "Ese personaje no puede atacar ahora."
			refresh_all()
			return
		selected_attacker = field_row[mission_index]
		selected_attacker_info = {"player": player_id, "mission_index": mission_index, "row": row}
		selected_target = null
		print("[ATTACK] Selected attacker: ", selected_attacker.get("name", "Carta"))
		print_valid_targets()
		status_message = "Atacante seleccionado. Elige el FRONT enemigo iluminado."
	elif is_valid_target_position(player_id, row, mission_index):
		selected_target = field_row[mission_index]
		print("[ATTACK] Target selected: ", selected_target.get("name", "Carta"))
		resource_choice_mode = CHOICE_ATTACK
		status_message = "Objetivo seleccionado. Elige una copia o una carta ATTACK."
	refresh_all()


func _on_attack_pressed() -> void:
	if phase == PHASE_POSITIONING:
		begin_attack_phase()
	elif phase == PHASE_ATTACK:
		request_attack_selection()


func _on_attack_spell_card_pressed(player_id: String, _hand_index: int) -> void:
	if player_id == active_player and phase == PHASE_ATTACK:
		request_attack_selection()


func begin_attack_phase() -> void:
	if game_over or phase != PHASE_POSITIONING or not resource_choice_mode.is_empty():
		return
	clear_combat_selection()
	transition_to_phase(PHASE_ATTACK, "%s finaliza posicionamiento" % player_name(active_player))
	status_message = "Selecciona un personaje iluminado para atacar o finaliza el turno."
	print_valid_attackers()
	refresh_all()


func request_attack_selection() -> void:
	if game_over or ai_turn_running or is_ai_controlled(active_player) or phase != PHASE_ATTACK or not resource_choice_mode.is_empty():
		return
	if not can_selected_attacker_attack():
		var candidates: Array[Dictionary] = find_attackable_positions(active_player)
		if candidates.is_empty():
			status_message = "No hay personajes que puedan atacar. Puedes finalizar el turno."
			refresh_all()
			return
		status_message = "Elige directamente uno de los personajes iluminados."
		refresh_all()
		return
	if selected_target == null:
		if not select_only_valid_target_for_attacker():
			status_message = "No existe un FRONT enemigo válido para ese atacante."
			refresh_all()
			return
	resource_choice_mode = CHOICE_ATTACK
	status_message = "Elegir método de ataque: copia del personaje o carta ATTACK."
	refresh_all()


func select_only_valid_target_for_attacker() -> bool:
	if phase != PHASE_ATTACK or selected_attacker_info.is_empty() or not can_selected_attacker_attack():
		return false
	var mission_index: int = int(selected_attacker_info.get("mission_index", -1))
	if mission_index < 0 or mission_index >= MISSION_COUNT:
		return false
	var target: Variant = get_field_row(other_player(active_player), ROW_FRONT)[mission_index]
	if target == null or int(target.get("hp", 0)) <= 0:
		return false
	selected_target = target
	print("[ATTACK] Target selected: ", selected_target.get("name", "Carta"), " (automatic fallback)")
	return true


func _on_defend_pressed() -> void:
	if ai_turn_running or is_ai_controlled(other_player(active_player)) or not can_defend_selected_target():
		return
	resource_choice_mode = CHOICE_DEFENSE
	status_message = "Elegir método de defensa."
	refresh_all()


func _on_pass_pressed() -> void:
	var acting_player: String = other_player(active_player) if phase == PHASE_DEFENSE_RESPONSE else active_player
	if game_over or ai_turn_running or is_ai_controlled(acting_player) or not resource_choice_mode.is_empty():
		return
	if phase == PHASE_DEFENSE_RESPONSE:
		resolve_attack(false, "%s elige PASS DEFENSE." % str(selected_target.get("name", "Defensor")))
	elif phase == PHASE_ATTACK:
		status_message = "%s pasa su turno." % player_name(active_player)
		finish_turn()


func prepare_attack_with_copy() -> void:
	clear_pending_effects()
	if not discard_copy_from_hand(active_player, str(selected_attacker.get("id", ""))):
		return
	resource_choice_mode = ""
	attack_pending = true
	begin_defense_response("%s descarta una copia para atacar con ATQ base." % str(selected_attacker.get("name", "Carta")))


func prepare_attack_with_card(hand_index: int) -> void:
	clear_pending_effects()
	var card: Variant = discard_card_from_hand(active_player, hand_index, CHOICE_ATTACK)
	if card == null:
		return
	pending_attack_card = card
	configure_pending_attack_effect(card)
	resource_choice_mode = ""
	attack_pending = true
	begin_defense_response("%s usa %s para atacar. %s" % [str(selected_attacker.get("name", "Carta")), str(card.get("name", "Ataque")), attack_effect_summary(card)])


func begin_defense_response(attack_note: String) -> void:
	var defender_id: String = other_player(active_player)
	transition_to_phase(PHASE_DEFENSE_RESPONSE, "ataque declarado contra %s" % str(selected_target.get("name", "Carta")))
	if not has_defense_resource(defender_id):
		print("[DEFENSE] No defense resource: DEF=0")
		resolve_attack(false, "%s\n%s no tiene copia ni carta DEFENSE: no puede activar su DEF." % [attack_note, str(selected_target.get("name", "Carta"))])
		return
	status_message = "%s\n%s puede activar su DEF descartando una copia o usando una carta DEFENSE." % [attack_note, str(selected_target.get("name", "Carta")).to_upper()]
	print("[DEFENSE] Waiting for active defense: ", player_name(defender_id))
	refresh_all()
	if is_ai_controlled(defender_id):
		call_deferred("run_ai_defense_response")


func prepare_defense_with_copy() -> void:
	clear_pending_defense_effects()
	var defender_id: String = other_player(active_player)
	if not discard_copy_from_hand(defender_id, str(selected_target.get("id", ""))):
		return
	print("[DEFENSE] Active defense: character copy")
	resource_choice_mode = ""
	resolve_attack(true, "%s descarta una copia para defender con DEF base." % str(selected_target.get("name", "Carta")))


func prepare_defense_with_card(hand_index: int) -> void:
	clear_pending_defense_effects()
	var defender_id: String = other_player(active_player)
	var card: Variant = discard_card_from_hand(defender_id, hand_index, CHOICE_DEFENSE)
	if card == null:
		return
	pending_defense_card = card
	configure_pending_defense_effect(card)
	print("[DEFENSE] Active defense: ", card.get("name", "Defense"))
	resource_choice_mode = ""
	resolve_attack(true, "%s usa %s para defender. %s" % [str(selected_target.get("name", "Carta")), str(card.get("name", "Defensa")), defense_effect_summary(card)])


func cancel_resource_choice() -> void:
	resource_choice_mode = ""
	status_message = "Selección de recurso cancelada."
	refresh_all()


func pass_defense_from_choice() -> void:
	resource_choice_mode = ""
	resolve_attack(false, "%s elige PASS DEFENSE." % str(selected_target.get("name", "Defensor")))


func _on_utility_card_pressed(player_id: String, hand_index: int) -> void:
	if ai_turn_running or is_ai_controlled(player_id):
		return
	play_utility_from_hand(player_id, hand_index)


func play_utility_from_hand(player_id: String, hand_index: int) -> bool:
	if game_over or phase != PHASE_POSITIONING or not resource_choice_mode.is_empty() or player_id != active_player:
		return false
	var hand: Array = get_hand(player_id)
	if hand_index < 0 or hand_index >= hand.size():
		return false
	var card: Dictionary = hand[hand_index]
	if str(card.get("type", "")) != CHOICE_UTILITY:
		return false

	var discard_required: int = int(card.get("discard", 0))
	if hand.size() - 1 < discard_required:
		status_message = "Necesitas al menos %d cartas adicionales para usar %s." % [discard_required, str(card.get("name", "Utilidad"))]
		refresh_all()
		return false

	var used_card: Variant = discard_card_from_hand(player_id, hand_index, CHOICE_UTILITY)
	if used_card == null:
		return false
	if str(card.get("effect", "")) == "draw":
		var drawn: Array = get_main_deck(player_id).draw_cards(int(card.get("draw", 0)))
		status_message = "%s usa %s, la envía al cementerio y roba %d carta(s)." % [player_name(player_id), str(card.get("name", "Utilidad")), drawn.size()]
		refresh_all()
		return true

	pending_utility_card = used_card
	pending_utility_discard_required = discard_required
	pending_utility_draw_count = int(card.get("draw", 0))
	selected_utility_discard_indices.clear()
	resource_choice_mode = CHOICE_UTILITY
	status_message = "Selecciona %d carta(s) para descartar." % discard_required
	refresh_all()
	return true


func toggle_utility_discard(hand_index: int) -> void:
	if resource_choice_mode != CHOICE_UTILITY:
		return
	if selected_utility_discard_indices.has(hand_index):
		selected_utility_discard_indices.erase(hand_index)
	elif selected_utility_discard_indices.size() < pending_utility_discard_required:
		selected_utility_discard_indices.append(hand_index)
	refresh_all()


func confirm_utility_discard() -> void:
	if resource_choice_mode != CHOICE_UTILITY or selected_utility_discard_indices.size() != pending_utility_discard_required:
		return
	var player_id: String = active_player
	var hand: Array = get_hand(player_id)
	selected_utility_discard_indices.sort()
	selected_utility_discard_indices.reverse()
	for hand_index in selected_utility_discard_indices:
		if hand_index >= 0 and hand_index < hand.size():
			var discarded: Dictionary = hand[hand_index]
			hand.remove_at(hand_index)
			get_main_deck(player_id).discard_card(discarded)
	var utility_name: String = str(pending_utility_card.get("name", "Utilidad"))
	var discarded_count: int = pending_utility_discard_required
	var drawn: Array = get_main_deck(player_id).draw_cards(pending_utility_draw_count)
	clear_pending_utility()
	resource_choice_mode = ""
	status_message = "%s resuelve %s: descarta %d y roba %d carta(s)." % [player_name(player_id), utility_name, discarded_count, drawn.size()]
	refresh_all()


func resolve_attack(active_defense: bool, resolution_note: String = "") -> void:
	if not attack_pending or selected_attacker == null or selected_target == null or selected_attacker_info.is_empty():
		clear_combat_selection()
		transition_to_phase(PHASE_ATTACK, "se canceló una resolución inválida")
		refresh_all()
		return
	transition_to_phase(PHASE_RESOLUTION, "se resuelve el combate")

	var mission_index: int = int(selected_attacker_info.get("mission_index", -1))
	var attacker_id: String = str(selected_attacker_info.get("player", active_player))
	var defender_id: String = other_player(attacker_id)
	var attacker_name: String = str(selected_attacker.get("name", "Atacante"))
	var target_name: String = str(selected_target.get("name", "Objetivo"))
	var total_attack: int = effective_atk(selected_attacker, attacker_id, mission_index) + pending_attack_bonus
	var defense_used: int = maxi(0, effective_def(selected_target, defender_id, mission_index) + pending_defense_bonus - pending_ignore_defense) if active_defense else 0
	var damage: int = maxi(0, total_attack - defense_used)
	damage = maxi(0, damage - (pending_damage_reduction if active_defense else 0))
	var current_hp: int = int(selected_target.get("hp", 0))
	if active_defense and pending_survive_at_one and damage >= current_hp and current_hp > 0:
		damage = current_hp - 1
	selected_target["hp"] = maxi(0, int(selected_target.get("hp", 0)) - damage)
	print("[RESOLUTION] ATQ=", total_attack, " DEF=", defense_used, " Damage=", damage, " Active defense=", active_defense)

	var result: String = "%s ataca a %s en MISIÓN %d.\nATQ TOTAL: %d | DEF EFECTIVA: %d\nDAÑO: %d\n%s queda con %d/%d VID." % [attacker_name, target_name, mission_index + 1, total_attack, defense_used, damage, target_name, int(selected_target.get("hp", 0)), int(selected_target.get("max_hp", 0))]
	if not resolution_note.is_empty():
		result = resolution_note + "\n" + result

	if int(selected_target.get("hp", 0)) <= 0:
		get_main_deck(defender_id).discard_card(selected_target)
		get_field_row(defender_id, ROW_FRONT)[mission_index] = null
		result += "\n%s ha sido derrotado." % target_name
		var failure_message: String = register_assigned_death(defender_id, mission_index, ROW_FRONT)
		if not failure_message.is_empty():
			result += "\n" + failure_message
		result += "\n" + complete_mission(attacker_id, mission_index, active_player)

	status_message = result
	if game_over:
		clear_combat_selection()
		transition_to_phase(PHASE_TURN_END, "partida terminada")
		refresh_all()
		return
	clear_combat_selection()
	transition_to_phase(PHASE_ATTACK, "combate resuelto; el atacante conserva el turno")
	refresh_all()
	print_valid_attackers()
	if is_ai_controlled(active_player):
		call_deferred("run_ai_turn")


func complete_mission(mission_owner: String, mission_index: int, winner_player_id: String) -> String:
	var active_missions: Array = get_active_missions(mission_owner)
	if mission_index < 0 or mission_index >= MISSION_COUNT or active_missions[mission_index] == null:
		return "No había una misión activa para completar."

	var mission_card: Dictionary = active_missions[mission_index]
	var earned_vp: int = int(mission_card.get("vp", 1))
	add_vp(winner_player_id, earned_vp)
	get_mission_deck(mission_owner).discard_mission(mission_card)

	var new_mission: Variant = get_mission_deck(mission_owner).draw_mission()
	active_missions[mission_index] = prepare_active_mission(new_mission)
	if active_missions[mission_index] != null and mission_has_assigned_character(mission_owner, mission_index):
		active_missions[mission_index]["revealed"] = true

	var message: String = "%s completa MISIÓN %d y obtiene +%d VP." % [player_name(winner_player_id), mission_index + 1, earned_vp]
	if get_vp(winner_player_id) >= VICTORY_VP:
		game_over = true
		message += "\nJUGADOR %s GANA LA PARTIDA" % winner_player_id
	elif new_mission != null:
		if bool(active_missions[mission_index].get("revealed", false)):
			message += "\nSe revela una nueva misión del Mission Deck de %s porque aún tiene un personaje asignado." % player_name(mission_owner)
		else:
			message += "\nSe coloca boca abajo una nueva misión del Mission Deck de %s." % player_name(mission_owner)
	else:
		message += "\nEl Mission Deck de %s está vacío." % player_name(mission_owner)
	return message


func finish_turn() -> void:
	clear_combat_selection()
	transition_to_phase(PHASE_TURN_END, "%s finaliza su turno" % player_name(active_player))
	active_player = other_player(active_player)
	var draw_message: String = draw_turn_card(active_player)
	if not draw_message.is_empty():
		status_message += "\n" + draw_message
	transition_to_phase(PHASE_POSITIONING, "comienza el turno de %s" % player_name(active_player))
	refresh_all()
	if is_ai_controlled(active_player) and not game_over:
		call_deferred("run_ai_turn")


func run_ai_turn() -> void:
	if ai_turn_running or game_over or not is_ai_controlled(active_player) or (phase != PHASE_POSITIONING and phase != PHASE_ATTACK):
		return
	ai_turn_running = true
	var action_count: int = 0
	print("AI TURN START")
	status_message = "IA SIMPLE comienza su turno."
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout

	while is_ai_controlled(active_player) and phase == PHASE_POSITIONING and not game_over and action_count < MAX_AI_ACTIONS_PER_TURN:
		var utility_choice: Dictionary = simple_ai.choose_utility_card(get_hand(active_player), get_main_deck(active_player).get_draw_pile_count())
		if not utility_choice.is_empty():
			action_count += 1
			await execute_ai_utility(utility_choice)
			continue

		var play_choice: Dictionary = simple_ai.choose_card_to_play(
			get_hand(active_player),
			get_field_row(active_player, ROW_FRONT),
			get_field_row(active_player, ROW_SUPPORT),
			get_active_missions(active_player),
			get_field_row(other_player(active_player), ROW_FRONT)
		)
		if not play_choice.is_empty():
			action_count += 1
			await execute_ai_character_play(play_choice)
			continue

		break
	if phase == PHASE_POSITIONING and not game_over:
		begin_attack_phase()
	if phase == PHASE_ATTACK and not game_over:
		var attack_choice: Dictionary = choose_ai_attack()
		if not attack_choice.is_empty():
			action_count += 1
			await execute_ai_attack(attack_choice)
			ai_turn_running = false
			refresh_all()
			return

	if action_count >= MAX_AI_ACTIONS_PER_TURN:
		push_warning("La IA alcanzó MAX_AI_ACTIONS_PER_TURN; se fuerza PASS TURN.")
		status_message = "IA alcanzó el límite de acciones y pasa el turno."
	else:
		status_message = "IA pasa el turno."
	print("AI PASS TURN")
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout
	ai_turn_running = false
	finish_turn()


func execute_ai_utility(choice: Dictionary) -> void:
	var hand_index: int = int(choice.get("hand_index", -1))
	var hand: Array = get_hand(active_player)
	if hand_index < 0 or hand_index >= hand.size():
		return
	var utility_name: String = str(hand[hand_index].get("name", "Utility"))
	status_message = "IA prepara %s." % utility_name
	print("AI PLAY: ", utility_name)
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout
	if not play_utility_from_hand(active_player, hand_index):
		return
	if resource_choice_mode == CHOICE_UTILITY:
		var discard_indices: Array[int] = simple_ai.choose_discards(get_hand(active_player), pending_utility_discard_required, get_active_missions(active_player))
		if discard_indices.size() != pending_utility_discard_required:
			resource_choice_mode = ""
			clear_pending_utility()
			return
		selected_utility_discard_indices = discard_indices
		status_message = "IA elige %d carta(s) para descartar con %s." % [discard_indices.size(), utility_name]
		refresh_all()
		await get_tree().create_timer(ai_action_delay).timeout
		confirm_utility_discard()
	status_message = "IA usa %s." % utility_name
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout


func execute_ai_character_play(choice: Dictionary) -> void:
	var card: Dictionary = choice.get("card", {})
	var row: String = str(choice.get("row", ROW_FRONT))
	var mission_index: int = int(choice.get("mission_index", -1))
	status_message = "IA selecciona %s para %s de Misión %d." % [str(card.get("name", "Personaje")), row_display_name(row), mission_index + 1]
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout
	if play_character_from_hand(active_player, int(choice.get("hand_index", -1)), row, mission_index, "IA"):
		print("AI PLAY: ", card.get("name", "Personaje"), " -> Mission ", mission_index + 1, " ", row_display_name(row))
	await get_tree().create_timer(ai_action_delay).timeout


func choose_ai_attack() -> Dictionary:
	var candidates: Array[Dictionary] = []
	for row in [ROW_FRONT, ROW_SUPPORT]:
		var field_row: Array = get_field_row(active_player, row)
		for mission_index in range(MISSION_COUNT):
			var attacker: Variant = field_row[mission_index]
			var target: Variant = get_field_row(other_player(active_player), ROW_FRONT)[mission_index]
			if not can_attack_from_position(active_player, row, mission_index):
				continue
			var methods: Array[Dictionary] = build_ai_attack_methods(attacker, target, row, mission_index)
			var method: Dictionary = simple_ai.choose_attack_method(methods)
			if method.is_empty():
				continue
			var candidate: Dictionary = method.duplicate(true)
			candidate["attacker"] = attacker
			candidate["target"] = target
			candidate["row"] = row
			candidate["mission_index"] = mission_index
			candidates.append(candidate)
	return simple_ai.choose_attacker(candidates)


func build_ai_attack_methods(attacker: Dictionary, target: Dictionary, row: String, mission_index: int) -> Array[Dictionary]:
	var methods: Array[Dictionary] = []
	var hand: Array = get_hand(active_player)
	var copy_index: int = find_copy_in_hand(active_player, str(attacker.get("id", "")))
	var attack_card_indices: Array[int] = find_cards_by_type(active_player, CHOICE_ATTACK)
	if copy_index >= 0:
		var copy_damage: int = estimate_ai_attack_damage(attacker, target, row, mission_index, null)
		methods.append({
			"kind": "copy", "hand_index": copy_index, "name": "Copia de %s" % str(attacker.get("name", "Personaje")),
			"expected_damage": copy_damage, "score": score_ai_attack(copy_damage, int(target.get("hp", 0)), true, attack_card_indices.is_empty())
		})
	for hand_index in attack_card_indices:
		var attack_card: Dictionary = hand[hand_index]
		var expected_damage: int = estimate_ai_attack_damage(attacker, target, row, mission_index, attack_card)
		methods.append({
			"kind": "attack_card", "hand_index": hand_index, "name": str(attack_card.get("name", "Attack")),
			"expected_damage": expected_damage, "score": score_ai_attack(expected_damage, int(target.get("hp", 0)), false, false)
		})
	return methods


func estimate_ai_attack_damage(attacker: Dictionary, target: Dictionary, row: String, mission_index: int, attack_card: Variant) -> int:
	var attack_value: int = effective_atk(attacker, active_player, mission_index)
	var ignored_defense: int = 0
	if attack_card != null:
		var value: int = int(attack_card.get("value", 0))
		match str(attack_card.get("effect", "")):
			"atk_bonus":
				attack_value += value
			"ignore_defense":
				ignored_defense += value
			"execution_bonus":
				if int(target.get("hp", 0)) * 2 <= int(target.get("max_hp", 0)):
					attack_value += value
			"support_bonus":
				var ally_row: String = ROW_SUPPORT if row == ROW_FRONT else ROW_FRONT
				if get_field_row(active_player, ally_row)[mission_index] != null:
					attack_value += value
	var defense_value: int = maxi(0, effective_def(target, other_player(active_player), mission_index) - ignored_defense)
	return maxi(0, attack_value - defense_value)


func score_ai_attack(expected_damage: int, target_hp: int, uses_copy: bool, no_attack_cards: bool) -> int:
	var score: int = expected_damage * 10
	if expected_damage >= target_hp:
		score += 80
	if expected_damage == 0:
		score -= 10
	if uses_copy:
		score += 2 if no_attack_cards else -2
	else:
		score += 1
	return score


func execute_ai_attack(choice: Dictionary) -> void:
	selected_attacker = choice.get("attacker", null)
	selected_target = choice.get("target", null)
	selected_attacker_info = {
		"player": active_player,
		"row": str(choice.get("row", ROW_FRONT)),
		"mission_index": int(choice.get("mission_index", -1))
	}
	status_message = "IA selecciona %s para atacar en Misión %d." % [str(selected_attacker.get("name", "Atacante")), int(choice.get("mission_index", 0)) + 1]
	print("AI ATTACK: ", selected_attacker.get("name", "Atacante"), " -> ", selected_target.get("name", "Objetivo"))
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout
	status_message = "IA usa %s." % str(choice.get("name", "recurso de ataque"))
	print("AI ATTACK METHOD: ", choice.get("name", "recurso"))
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout
	if str(choice.get("kind", "")) == "copy":
		prepare_attack_with_copy()
	else:
		prepare_attack_with_card(int(choice.get("hand_index", -1)))


func run_ai_defense_response() -> void:
	if ai_turn_running or game_over or phase != PHASE_DEFENSE_RESPONSE or not is_ai_controlled(other_player(active_player)):
		return
	ai_turn_running = true
	status_message += "\nIA evalúa su defensa."
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout
	var undefended_damage: int = estimate_ai_defense_damage(null, false)
	var options: Array[Dictionary] = build_ai_defense_options()
	var decision: Dictionary = simple_ai.choose_defense_method(options, undefended_damage, int(selected_target.get("hp", 0)))
	status_message = "IA elige %s." % str(decision.get("name", "PASS DEFENSE"))
	print("AI DEFENSE: ", decision.get("name", "PASS DEFENSE"))
	refresh_all()
	await get_tree().create_timer(ai_action_delay).timeout
	match str(decision.get("kind", "pass")):
		"copy":
			prepare_defense_with_copy()
		"defense_card":
			prepare_defense_with_card(int(decision.get("hand_index", -1)))
		_:
			print("[DEFENSE] Passive defense")
			if resource_choice_mode == CHOICE_DEFENSE:
				pass_defense_from_choice()
			else:
				resolve_attack(false, "IA elige PASS DEFENSE.")
	ai_turn_running = false


func build_ai_defense_options() -> Array[Dictionary]:
	var defender_id: String = other_player(active_player)
	var options: Array[Dictionary] = []
	var copy_index: int = find_copy_in_hand(defender_id, str(selected_target.get("id", "")))
	if copy_index >= 0:
		options.append({"kind": "copy", "hand_index": copy_index, "name": "Copia de %s" % str(selected_target.get("name", "Defensor")), "expected_damage": estimate_ai_defense_damage(null, true)})
	for hand_index in find_cards_by_type(defender_id, CHOICE_DEFENSE):
		var defense_card: Dictionary = get_hand(defender_id)[hand_index]
		options.append({"kind": "defense_card", "hand_index": hand_index, "name": str(defense_card.get("name", "Defense")), "expected_damage": estimate_ai_defense_damage(defense_card, true)})
	return options


func estimate_ai_defense_damage(defense_card: Variant, defended: bool) -> int:
	var mission_index: int = int(selected_attacker_info.get("mission_index", -1))
	var attack_value: int = effective_atk(selected_attacker, active_player, mission_index) + pending_attack_bonus
	if not defended:
		return attack_value
	var defense_bonus: int = 0
	var damage_reduction: int = 0
	var survive: bool = false
	if defense_card != null:
		var value: int = int(defense_card.get("value", 0))
		match str(defense_card.get("effect", "")):
			"def_bonus":
				defense_bonus += value
			"damage_reduction":
				damage_reduction += value
			"support_def_bonus":
				if get_field_row(other_player(active_player), ROW_SUPPORT)[mission_index] != null:
					defense_bonus += value
			"survive_at_one":
				survive = true
	var defense_value: int = maxi(0, effective_def(selected_target, other_player(active_player), mission_index) + defense_bonus - pending_ignore_defense)
	var damage: int = maxi(0, attack_value - defense_value - damage_reduction)
	if survive and damage >= int(selected_target.get("hp", 0)):
		damage = maxi(0, int(selected_target.get("hp", 0)) - 1)
	return damage


func draw_turn_card(player_id: String) -> String:
	var card: Variant = get_main_deck(player_id).draw_card()
	if card == null:
		return "%s no tiene más cartas en su Main Deck." % player_name(player_id)
	print("Carta robada por ", player_name(player_id), ": ", card.get("name", "Carta"))
	return "%s roba 1 carta del Main Deck: %s." % [player_name(player_id), str(card.get("name", "Carta"))]


func find_copy_in_hand(player_id: String, card_id: String) -> int:
	var hand: Array = get_hand(player_id)
	for index in range(hand.size()):
		if str(hand[index].get("id", "")) == card_id:
			return index
	return -1


func discard_copy_from_hand(player_id: String, card_id: String) -> bool:
	var hand_index: int = find_copy_in_hand(player_id, card_id)
	if hand_index < 0:
		return false
	var hand: Array = get_hand(player_id)
	var card: Dictionary = hand[hand_index]
	hand.remove_at(hand_index)
	get_main_deck(player_id).discard_card(card)
	refresh_hand(player_id)
	return true


func find_cards_by_type(player_id: String, card_type: String) -> Array[int]:
	var result: Array[int] = []
	var hand: Array = get_hand(player_id)
	for index in range(hand.size()):
		if str(hand[index].get("type", "")) == card_type:
			result.append(index)
	return result


func discard_card_from_hand(player_id: String, hand_index: int, expected_type: String):
	var hand: Array = get_hand(player_id)
	if hand_index < 0 or hand_index >= hand.size():
		return null
	var card: Dictionary = hand[hand_index]
	if str(card.get("type", "")) != expected_type:
		return null
	hand.remove_at(hand_index)
	get_main_deck(player_id).discard_card(card)
	refresh_hand(player_id)
	return card


func has_attack_resource(player_id: String, attacker) -> bool:
	return find_copy_in_hand(player_id, str(attacker.get("id", ""))) >= 0 or not find_cards_by_type(player_id, CHOICE_ATTACK).is_empty()


func has_defense_resource(player_id: String) -> bool:
	if selected_target == null:
		return false
	return find_copy_in_hand(player_id, str(selected_target.get("id", ""))) >= 0 or not find_cards_by_type(player_id, CHOICE_DEFENSE).is_empty()


func configure_pending_attack_effect(card: Dictionary) -> void:
	var value: int = int(card.get("value", 0))
	match str(card.get("effect", "")):
		"atk_bonus":
			pending_attack_bonus += value
		"ignore_defense":
			pending_ignore_defense += value
		"execution_bonus":
			if int(selected_target.get("hp", 0)) * 2 <= int(selected_target.get("max_hp", 0)):
				pending_attack_bonus += value
		"support_bonus":
			var mission_index: int = int(selected_attacker_info.get("mission_index", -1))
			var attacker_row: String = str(selected_attacker_info.get("row", ROW_FRONT))
			var ally_row: String = ROW_SUPPORT if attacker_row == ROW_FRONT else ROW_FRONT
			if mission_index >= 0 and get_field_row(active_player, ally_row)[mission_index] != null:
				pending_attack_bonus += value


func configure_pending_defense_effect(card: Dictionary) -> void:
	var value: int = int(card.get("value", 0))
	match str(card.get("effect", "")):
		"def_bonus":
			pending_defense_bonus += value
		"damage_reduction":
			pending_damage_reduction += value
		"support_def_bonus":
			var mission_index: int = int(selected_attacker_info.get("mission_index", -1))
			if mission_index >= 0 and get_field_row(other_player(active_player), ROW_SUPPORT)[mission_index] != null:
				pending_defense_bonus += value
		"survive_at_one":
			pending_survive_at_one = true


func attack_effect_summary(card: Dictionary) -> String:
	return str(card.get("description", "Técnica de ataque aplicada."))


func defense_effect_summary(card: Dictionary) -> String:
	return str(card.get("description", "Técnica de defensa aplicada."))


func resource_effect_label(card: Dictionary) -> String:
	var value: int = int(card.get("value", 0))
	match str(card.get("effect", "")):
		"atk_bonus":
			return "+%d ATQ" % value
		"ignore_defense":
			return "IGNORA %d DEF" % value
		"execution_bonus":
			return "+%d ATQ A ≤50%% VID" % value
		"support_bonus":
			return "+%d ATQ CON ALIADO" % value
		"def_bonus":
			return "+%d DEF" % value
		"damage_reduction":
			return "REDUCE %d DAÑO" % value
		"support_def_bonus":
			return "+%d DEF CON SUPPORT" % value
		"survive_at_one":
			return "SOBREVIVE CON 1 VID"
	return "SIN EFECTO"


func mission_stat_bonus(character: Dictionary, player_id: String, mission_index: int, stat_name: String) -> int:
	if mission_index < 0 or mission_index >= MISSION_COUNT:
		return 0
	var mission: Variant = get_active_missions(player_id)[mission_index]
	if mission == null or str(mission.get("target_class", "")) != str(character.get("class", "")):
		return 0
	var expected_modifier: String = "class_atk_bonus" if stat_name == "atk" else "class_def_bonus"
	if str(mission.get("modifier_type", "")) != expected_modifier:
		return 0
	return int(mission.get("value", 0))


func effective_atk(character: Dictionary, player_id: String, mission_index: int) -> int:
	var base_value: int = int(character.get("base_atk", character.get("atk", 0)))
	return maxi(0, base_value + mission_stat_bonus(character, player_id, mission_index, "atk"))


func effective_def(character: Dictionary, player_id: String, mission_index: int) -> int:
	var base_value: int = int(character.get("base_def", character.get("def", 0)))
	return maxi(0, base_value + mission_stat_bonus(character, player_id, mission_index, "def"))


func can_attack_from_position(player_id: String, row: String, mission_index: int) -> bool:
	if game_over or not resource_choice_mode.is_empty() or phase != PHASE_ATTACK or player_id != active_player:
		return false
	if mission_index < 0 or mission_index >= MISSION_COUNT:
		return false
	var attacker: Variant = get_field_row(player_id, row)[mission_index]
	var target: Variant = get_field_row(other_player(player_id), ROW_FRONT)[mission_index]
	if attacker == null or target == null or int(attacker.get("hp", 0)) <= 0 or int(target.get("hp", 0)) <= 0:
		return false
	return has_attack_resource(player_id, attacker)


func is_valid_target_position(player_id: String, row: String, mission_index: int) -> bool:
	if phase != PHASE_ATTACK or selected_attacker_info.is_empty() or selected_attacker == null:
		return false
	if player_id != other_player(active_player) or row != ROW_FRONT:
		return false
	if mission_index != int(selected_attacker_info.get("mission_index", -1)):
		return false
	var target: Variant = get_field_row(player_id, row)[mission_index]
	return target != null and int(target.get("hp", 0)) > 0 and can_selected_attacker_attack()


func is_selected_target_position(player_id: String, row: String, mission_index: int) -> bool:
	return selected_target != null and not selected_attacker_info.is_empty() and player_id == other_player(active_player) and row == ROW_FRONT and mission_index == int(selected_attacker_info.get("mission_index", -1)) and get_field_row(player_id, row)[mission_index] == selected_target


func print_valid_attackers() -> void:
	var names: Array[String] = []
	for position in find_attackable_positions(active_player):
		var card: Dictionary = get_field_row(active_player, str(position["row"]))[int(position["mission_index"])]
		names.append("%s (%s %d)" % [str(card.get("name", "Carta")), row_display_name(str(position["row"])), int(position["mission_index"]) + 1])
	print("[ATTACK] Valid attackers: ", ", ".join(names) if not names.is_empty() else "ninguno")


func print_valid_targets() -> void:
	var names: Array[String] = []
	if not selected_attacker_info.is_empty():
		var mission_index: int = int(selected_attacker_info.get("mission_index", -1))
		var target: Variant = get_field_row(other_player(active_player), ROW_FRONT)[mission_index]
		if target != null:
			names.append("%s (FRONT %d)" % [str(target.get("name", "Carta")), mission_index + 1])
	print("[ATTACK] Valid targets: ", ", ".join(names) if not names.is_empty() else "ninguno")


func can_selected_attacker_attack() -> bool:
	if selected_attacker_info.is_empty():
		return false
	return can_attack_from_position(
		str(selected_attacker_info.get("player", "")),
		str(selected_attacker_info.get("row", "")),
		int(selected_attacker_info.get("mission_index", -1))
	)


func find_attackable_positions(player_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in [ROW_FRONT, ROW_SUPPORT]:
		for mission_index in range(MISSION_COUNT):
			if can_attack_from_position(player_id, row, mission_index):
				result.append({"row": row, "mission_index": mission_index})
	return result


func has_any_attackable_character(player_id: String) -> bool:
	return not find_attackable_positions(player_id).is_empty()


func can_defend_selected_target() -> bool:
	if game_over or not resource_choice_mode.is_empty() or phase != PHASE_DEFENSE_RESPONSE or selected_target == null:
		return false
	return has_defense_resource(other_player(active_player))


func refresh_all() -> void:
	update_visible_hand_dock()
	refresh_hand(PLAYER_A)
	refresh_hand(PLAYER_B)
	refresh_mission_battlefield()
	refresh_headers()
	refresh_discard_summaries()
	refresh_resource_choice()
	refresh_actions()
	refresh_status()
	refresh_end_game_panel()


func refresh_hand(player_id: String) -> void:
	var container: HBoxContainer = get_hand_container(player_id)
	clear_container(container)
	var hand: Array = get_hand(player_id)
	if player_id == PLAYER_B and selected_game_mode == GAME_MODE_AI:
		player_b_hand_title.text = "MANO IA — %d CARTAS (OCULTAS)" % hand.size()
		player_b_hand_scroll.custom_minimum_size.y = 205.0
		for _index in range(hand.size()):
			var card_back: Button = Button.new()
			set_exact_control_size(card_back, HIDDEN_CARD_SIZE)
			card_back.text = ""
			card_back.tooltip_text = "CARTA OCULTA"
			card_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
			CardVisualsScript.apply_to(card_back, "hidden")
			container.add_child(card_back)
		configure_hand_spacing(container, hand.size())
		return
	player_b_hand_title.text = "MANO B — ARRASTRA UNA CARTA" if player_id == PLAYER_B else player_b_hand_title.text
	if player_id == PLAYER_B:
		player_b_hand_scroll.custom_minimum_size.y = 205.0
	player_a_hand_title.text = "MANO A — ARRASTRA UNA CARTA"
	for index in range(hand.size()):
		var card: Dictionary = hand[index]
		var button: Variant = CardButtonScript.new()
		set_exact_control_size(button, CARD_SIZE)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = card_text(card)
		CardVisualsScript.apply_to(button, str(card.get("type", "")))
		var human_can_use: bool = not ai_turn_running and not is_ai_controlled(player_id)
		button.configure_drag(
			human_can_use and not game_over and resource_choice_mode.is_empty() and player_id == active_player and phase == PHASE_POSITIONING and str(card.get("type", "")) == "character",
			{"kind": "hand_card", "player_id": player_id, "hand_index": index, "card_id": str(card.get("id", "")), "card_type": str(card.get("type", ""))}
		)
		if str(card.get("type", "")) == CHOICE_UTILITY:
			button.disabled = not human_can_use or phase != PHASE_POSITIONING
			if human_can_use:
				button.pressed.connect(_on_utility_card_pressed.bind(player_id, index))
		elif str(card.get("type", "")) == CHOICE_ATTACK and human_can_use and player_id == active_player and phase == PHASE_ATTACK:
			button.pressed.connect(_on_attack_spell_card_pressed.bind(player_id, index))
		if is_usable_combat_hand_card(player_id, card):
			apply_glow(button, Color(0.25, 0.75, 1.0))
		container.add_child(button)
	configure_hand_spacing(container, hand.size())
	if hand.is_empty():
		add_empty_label(container, "Sin cartas en mano")


func configure_hand_spacing(container: HBoxContainer, card_count: int) -> void:
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	var separation: int = 8
	if card_count > 1:
		var available_width: float = get_viewport_rect().size.x - HAND_VIEWPORT_WIDTH_MARGIN
		var required_spacing: float = (available_width - CARD_SIZE.x * card_count) / float(card_count - 1)
		separation = int(clampf(required_spacing, -CARD_SIZE.x * 0.68, 8.0))
	container.add_theme_constant_override("separation", separation)


func refresh_mission_battlefield() -> void:
	clear_container(mission_battlefield)
	for mission_index in range(MISSION_COUNT):
		var column: VBoxContainer = VBoxContainer.new()
		column.custom_minimum_size = Vector2(250.0, 0.0)
		column.add_theme_constant_override("separation", 4)
		column.alignment = BoxContainer.ALIGNMENT_CENTER
		mission_battlefield.add_child(column)
		column.add_child(create_mission_front_stack(PLAYER_B, mission_index))
		column.add_child(create_mission_front_stack(PLAYER_A, mission_index))


func add_compact_zone_label(container: VBoxContainer, text_value: String, font_size: int) -> void:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	container.add_child(label)


func create_field_slot(player_id: String, row: String, mission_index: int, overlay_mode: bool = false):
	var field_row: Array = get_field_row(player_id, row)
	var slot: Variant = FieldSlotScript.new()
	var support_locked: bool = row == ROW_SUPPORT and not is_support_unlocked(player_id, mission_index) and field_row[mission_index] == null
	set_exact_control_size(slot, SUPPORT_COLLAPSED_SIZE if support_locked else CARD_SIZE)
	slot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	slot.configure(mission_index)
	slot.card_dropped.connect(_on_card_dropped.bind(player_id, row))
	slot.accepts_cards = not support_locked and not game_over and resource_choice_mode.is_empty() and phase == PHASE_POSITIONING and player_id == active_player and field_row[mission_index] == null
	if support_locked:
		slot.text = "SUPPORT CONTRAÍDO — COLOCA FRONT"
		slot.disabled = true
		return slot
	if field_row[mission_index] == null:
		slot.text = "COLOCA FRONT" if overlay_mode else "[ VACÍO ]"
		if overlay_mode:
			apply_overlay_slot_style(slot)
	else:
		slot.text = field_card_text(field_row[mission_index], player_id, mission_index)
		CardVisualsScript.apply_to(slot, "character")
		slot.toggle_mode = true
		slot.disabled = ai_turn_running
		slot.button_pressed = is_selected_attacker(player_id, row, mission_index)
		slot.pressed.connect(_on_field_card_pressed.bind(player_id, row, mission_index))
		if is_selected_attacker(player_id, row, mission_index):
			apply_selected_highlight(slot, Color(0.35, 1.0, 0.45))
		elif is_selected_target_position(player_id, row, mission_index):
			apply_selected_highlight(slot, Color(1.0, 0.58, 0.2))
		elif is_valid_target_position(player_id, row, mission_index):
			apply_glow(slot, Color(1.0, 0.58, 0.2))
		elif can_attack_from_position(player_id, row, mission_index):
			apply_glow(slot, Color(0.25, 1.0, 0.35))
		elif is_selected_defender(player_id, row, mission_index) and can_defend_selected_target():
			apply_glow(slot, Color(0.25, 0.65, 1.0))
	return slot


func create_mission_card(player_id: String, mission_index: int) -> Button:
	var active_missions: Array = get_active_missions(player_id)
	var button: Button = Button.new()
	set_exact_control_size(button, MISSION_CARD_SIZE)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(_on_mission_card_pressed.bind(player_id, mission_index))
	if active_missions[mission_index] == null:
		button.text = "MISIÓN %s\nSIN MISIÓN" % player_id
	else:
		var mission: Dictionary = active_missions[mission_index]
		if not bool(mission.get("revealed", false)):
			button.text = ""
			button.tooltip_text = "MISIÓN %s — BOCA ABAJO" % player_id
			CardVisualsScript.apply_to(button, "mission_back")
		elif bool(mission.get("details_visible", false)):
			button.text = "%s · %s\nOBJ: Vence enemigo\nEFECTO: %s\nFALLA: %s\nRECOMPENSA: %d VP" % [player_id, str(mission.get("name", "Misión")), mission_card_effect_text(mission), mission_failure_short_text(mission), int(mission.get("vp", 1))]
			CardVisualsScript.apply_to(button, "mission")
		else:
			button.text = "%s · %s\nCLIC PARA VER DETALLES" % [player_id, str(mission.get("name", "Misión"))]
			CardVisualsScript.apply_to(button, "mission")
	return button


func create_mission_front_stack(player_id: String, mission_index: int) -> Control:
	var stack: Control = Control.new()
	set_exact_control_size(stack, MISSION_FRONT_STACK_SIZE)
	var support_slot: Variant = create_field_slot(player_id, ROW_SUPPORT, mission_index)
	var support_is_locked: bool = not is_support_unlocked(player_id, mission_index) and get_field_row(player_id, ROW_SUPPORT)[mission_index] == null
	support_slot.position = Vector2(47.5, 0.0 if player_id == PLAYER_B else (228.0 if support_is_locked else 75.0))
	if player_id == PLAYER_B and not support_is_locked:
		support_slot.pivot_offset = CARD_SIZE * 0.5
		support_slot.rotation = PI
	stack.add_child(support_slot)
	var mission_card: Button = create_mission_card(player_id, mission_index)
	mission_card.position = Vector2(15.0, 74.0 if player_id == PLAYER_B else 45.0)
	if player_id == PLAYER_B:
		mission_card.pivot_offset = MISSION_CARD_SIZE * 0.5
		mission_card.rotation = PI
	stack.add_child(mission_card)
	var front_slot: Variant = create_field_slot(player_id, ROW_FRONT, mission_index, true)
	front_slot.position = Vector2(47.5, 75.0 if player_id == PLAYER_B else 0.0)
	if player_id == PLAYER_B:
		front_slot.pivot_offset = CARD_SIZE * 0.5
		front_slot.rotation = PI
	stack.add_child(front_slot)
	return stack


func apply_overlay_slot_style(slot: Button) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.05, 0.07, 0.12)
	style.border_color = Color(0.45, 0.65, 0.85, 0.55)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		slot.add_theme_stylebox_override(state, style)


func refresh_headers() -> void:
	player_a_header.text = "JUGADOR A — VP: %d" % player_a_vp
	player_b_header.text = "JUGADOR B%s — VP: %d" % [" (IA SIMPLE)" if is_ai_controlled(PLAYER_B) else "", player_b_vp]


func refresh_discard_summaries() -> void:
	player_a_main_discard_label.text = "CEMENTERIO A — %d cartas" % player_a_main_discard.size()
	player_b_main_discard_label.text = "CEMENTERIO B — %d cartas" % player_b_main_discard.size()
	player_a_mission_discard_label.text = "DESCARTE MISIONES A — %d" % player_a_mission_discard.size()
	player_b_mission_discard_label.text = "DESCARTE MISIONES B — %d" % player_b_mission_discard.size()


func show_main_discard(player_id: String) -> void:
	var discard_ids: Array = player_a_main_discard if player_id == PLAYER_A else player_b_main_discard
	var grouped: Dictionary = {}
	for card_id in discard_ids:
		var normalized_id: String = str(card_id)
		grouped[normalized_id] = int(grouped.get(normalized_id, 0)) + 1
	var lines: Array[String] = []
	var ids: Array = grouped.keys()
	ids.sort()
	for card_id in ids:
		var card: Variant = CardDatabase.get_card(str(card_id))
		var card_name: String = str(card.get("name", card_id)) if card != null else str(card_id)
		lines.append("%s x%d" % [card_name, int(grouped[card_id])])
	discard_panel_title.text = "CEMENTERIO %s — %d cartas" % [player_id, discard_ids.size()]
	discard_panel_content.text = "Sin cartas descartadas." if lines.is_empty() else "\n".join(lines)
	discard_panel.visible = true


func hide_discard_panel() -> void:
	discard_panel.visible = false


func refresh_resource_choice() -> void:
	clear_container(resource_choice_row)
	resource_choice_panel.visible = not resource_choice_mode.is_empty()
	if resource_choice_mode.is_empty():
		return
	hud_sidebar_panel.visible = true
	hud_sidebar_toggle.text = "▶"

	if resource_choice_mode == CHOICE_UTILITY:
		resource_choice_title.text = "Elegir cartas para descartar — %d / %d" % [selected_utility_discard_indices.size(), pending_utility_discard_required]
		var utility_hand: Array = get_hand(active_player)
		for hand_index in range(utility_hand.size()):
			var discard_button: Button = Button.new()
			discard_button.custom_minimum_size = Vector2(155.0, 58.0)
			discard_button.toggle_mode = true
			discard_button.button_pressed = selected_utility_discard_indices.has(hand_index)
			discard_button.text = str(utility_hand[hand_index].get("name", "Carta"))
			discard_button.pressed.connect(toggle_utility_discard.bind(hand_index))
			resource_choice_row.add_child(discard_button)
		var confirm_button: Button = Button.new()
		confirm_button.custom_minimum_size = Vector2(120.0, 58.0)
		confirm_button.text = "CONFIRMAR"
		confirm_button.disabled = selected_utility_discard_indices.size() != pending_utility_discard_required
		confirm_button.pressed.connect(confirm_utility_discard)
		resource_choice_row.add_child(confirm_button)
		return

	var player_id: String = active_player if resource_choice_mode == CHOICE_ATTACK else other_player(active_player)
	var character: Variant = selected_attacker if resource_choice_mode == CHOICE_ATTACK else selected_target
	var copy_index: int = find_copy_in_hand(player_id, str(character.get("id", "")))
	resource_choice_title.text = "Elegir método de ataque" if resource_choice_mode == CHOICE_ATTACK else "Elegir método de defensa"

	if copy_index >= 0:
		var copy_button: Button = Button.new()
		copy_button.custom_minimum_size = Vector2(165.0, 58.0)
		copy_button.text = "USAR COPIA\n%s" % str(character.get("name", "Personaje"))
		if resource_choice_mode == CHOICE_ATTACK:
			copy_button.pressed.connect(prepare_attack_with_copy)
		else:
			copy_button.pressed.connect(prepare_defense_with_copy)
		resource_choice_row.add_child(copy_button)

	for hand_index in find_cards_by_type(player_id, resource_choice_mode):
		var technique: Dictionary = get_hand(player_id)[hand_index]
		var technique_button: Button = Button.new()
		technique_button.custom_minimum_size = Vector2(155.0, 58.0)
		technique_button.text = "%s\n%s" % [str(technique.get("name", "Técnica")), resource_effect_label(technique)]
		if resource_choice_mode == CHOICE_ATTACK:
			technique_button.pressed.connect(prepare_attack_with_card.bind(hand_index))
		else:
			technique_button.pressed.connect(prepare_defense_with_card.bind(hand_index))
		resource_choice_row.add_child(technique_button)

	var final_button: Button = Button.new()
	final_button.custom_minimum_size = Vector2(125.0, 58.0)
	if resource_choice_mode == CHOICE_DEFENSE:
		final_button.text = "PASAR DEFENSA"
		final_button.pressed.connect(pass_defense_from_choice)
	else:
		final_button.text = "CANCELAR"
		final_button.pressed.connect(cancel_resource_choice)
	resource_choice_row.add_child(final_button)


func refresh_actions() -> void:
	var defense_actor: String = other_player(active_player)
	attack_button.visible = phase == PHASE_POSITIONING or phase == PHASE_ATTACK
	if phase == PHASE_POSITIONING:
		attack_button.text = "FINALIZAR POSICIONAMIENTO"
		attack_button.disabled = game_over or ai_turn_running or is_ai_controlled(active_player) or not resource_choice_mode.is_empty()
	else:
		attack_button.text = "ELEGIR OBJETIVO / RECURSO" if selected_target == null else "ELEGIR RECURSO DE ATAQUE"
		attack_button.disabled = game_over or ai_turn_running or is_ai_controlled(active_player) or not can_selected_attacker_attack() or not resource_choice_mode.is_empty()
	defend_button.visible = phase == PHASE_DEFENSE_RESPONSE and has_defense_resource(defense_actor)
	defend_button.text = "DEFENSA ACTIVA"
	defend_button.disabled = game_over or ai_turn_running or is_ai_controlled(defense_actor) or not can_defend_selected_target()
	var acting_player: String = defense_actor if phase == PHASE_DEFENSE_RESPONSE else active_player
	pass_button.visible = phase == PHASE_ATTACK or phase == PHASE_DEFENSE_RESPONSE
	pass_button.disabled = game_over or ai_turn_running or is_ai_controlled(acting_player) or not resource_choice_mode.is_empty()
	pass_button.text = "PASAR DEFENSA" if phase == PHASE_DEFENSE_RESPONSE else "FINALIZAR TURNO"


func refresh_status() -> void:
	var lines: Array[String] = []
	lines.append("TURNO: JUGADOR %s — FASE: %s" % [active_player, phase_display_name(phase)])
	lines.append("VP A: %d | VP B: %d" % [player_a_vp, player_b_vp])
	if selected_attacker == null:
		lines.append("ATACANTE: NINGUNO")
	else:
		lines.append("ATACANTE: %s — %s — MISIÓN %d" % [str(selected_attacker.get("name", "Carta")), row_display_name(str(selected_attacker_info.get("row", ""))), int(selected_attacker_info.get("mission_index", -1)) + 1])
	if selected_target == null:
		lines.append("OBJETIVO: NINGUNO")
	else:
		lines.append("OBJETIVO: %s — FRONT — MISIÓN %d" % [str(selected_target.get("name", "Carta")), int(selected_attacker_info.get("mission_index", -1)) + 1])
	if not status_message.is_empty():
		lines.append(status_message)
	status_label.text = "\n".join(lines)


func refresh_end_game_panel() -> void:
	end_game_panel.visible = game_over and game_board.visible
	if not end_game_panel.visible:
		return
	var winner_id: String = PLAYER_A if player_a_vp >= VICTORY_VP else PLAYER_B
	var winner_name: String = "JUGADOR %s" % winner_id
	if is_ai_controlled(winner_id):
		winner_name += " (IA SIMPLE)"
	end_game_title.text = "FIN DE PARTIDA\n%s GANA" % winner_name


func is_selected_attacker(player_id: String, row: String, mission_index: int) -> bool:
	return not selected_attacker_info.is_empty() and str(selected_attacker_info.get("player", "")) == player_id and str(selected_attacker_info.get("row", "")) == row and int(selected_attacker_info.get("mission_index", -1)) == mission_index


func is_selected_defender(player_id: String, row: String, mission_index: int) -> bool:
	return phase == PHASE_DEFENSE_RESPONSE and player_id == other_player(active_player) and row == ROW_FRONT and int(selected_attacker_info.get("mission_index", -1)) == mission_index


func card_text(card: Dictionary) -> String:
	var card_type: String = str(card.get("type", ""))
	if card_type == CHOICE_ATTACK:
		return "%s\nATAQUE\n%s" % [str(card.get("name", "Ataque")), resource_effect_label(card)]
	if card_type == CHOICE_DEFENSE:
		return "%s\nDEFENSA\n%s" % [str(card.get("name", "Defensa")), resource_effect_label(card)]
	if card_type == CHOICE_UTILITY:
		return "%s\nUTILIDAD\n%s" % [str(card.get("name", "Utilidad")), utility_effect_label(card)]
	var hp: int = int(card.get("hp", 0))
	var max_hp: int = int(card.get("max_hp", hp))
	return "%s\nATQ %d | DEF %d\nVID %d/%d" % [str(card.get("name", "Carta")), int(card.get("base_atk", card.get("atk", 0))), int(card.get("base_def", card.get("def", 0))), hp, max_hp]


func utility_effect_label(card: Dictionary) -> String:
	if str(card.get("effect", "")) == "discard_draw":
		return "DESCARTA %d · ROBA %d" % [int(card.get("discard", 0)), int(card.get("draw", 0))]
	return "ROBA %d CARTAS" % int(card.get("draw", 0))


func field_card_text(card: Dictionary, player_id: String, mission_index: int) -> String:
	var base_atk: int = int(card.get("base_atk", card.get("atk", 0)))
	var base_def: int = int(card.get("base_def", card.get("def", 0)))
	var atk_bonus: int = effective_atk(card, player_id, mission_index) - base_atk
	var def_bonus: int = effective_def(card, player_id, mission_index) - base_def
	var atk_text: String = "ATQ %d%s" % [effective_atk(card, player_id, mission_index), bonus_suffix(atk_bonus)]
	var def_text: String = "DEF %d%s" % [effective_def(card, player_id, mission_index), bonus_suffix(def_bonus)]
	return "%s\n%s | %s\nVID %d/%d" % [str(card.get("name", "Carta")), atk_text, def_text, int(card.get("hp", 0)), int(card.get("max_hp", card.get("hp", 0)))]


func bonus_suffix(value: int) -> String:
	if value > 0:
		return " (+%d)" % value
	if value < 0:
		return " (%d)" % value
	return ""


func mission_modifier_text(mission: Dictionary) -> String:
	var modifier_type: String = str(mission.get("modifier_type", ""))
	if modifier_type.is_empty():
		return "Sin modificador"
	var stat_name: String = "ATQ" if modifier_type == "class_atk_bonus" else "DEF"
	var value: int = int(mission.get("value", 0))
	var signed_value: String = "+%d" % value if value >= 0 else str(value)
	return "%s %s %s" % [class_display_name(str(mission.get("target_class", ""))), signed_value, stat_name]


func mission_card_effect_text(mission: Dictionary) -> String:
	var text: String = mission_modifier_text(mission)
	text = text.replace("Combatientes ligeros", "Ligeros")
	text = text.replace("Especialistas frágiles", "Especialistas")
	return text


func mission_failure_short_text(mission: Dictionary) -> String:
	var deaths: int = int(mission.get("dead_assigned_count", 0))
	match str(mission.get("fail_condition", "")):
		"front_defeated":
			return "cae Front"
		"assigned_deaths":
			return "%d/%d asignados" % [deaths, int(mission.get("fail_threshold", 1))]
		"all_assigned_defeated":
			return "caen todos (%d)" % deaths
	return "sin condición"


func class_display_name(class_id: String) -> String:
	match class_id:
		"assassin":
			return "Asesinos"
		"defender":
			return "Defensores"
		"tank":
			return "Tanques"
		"light_fighter":
			return "Combatientes ligeros"
		"fragile_specialist":
			return "Especialistas frágiles"
	return class_id


func apply_glow(button: Button, glow_color: Color) -> void:
	button.self_modulate = Color(
		0.88 + glow_color.r * 0.12,
		0.88 + glow_color.g * 0.12,
		0.88 + glow_color.b * 0.12,
		1.0
	)


func apply_selected_highlight(button: Button, highlight_color: Color) -> void:
	button.self_modulate = Color(
		0.72 + highlight_color.r * 0.28,
		0.72 + highlight_color.g * 0.28,
		0.72 + highlight_color.b * 0.28,
		1.0
	)


func is_usable_combat_hand_card(player_id: String, card: Dictionary) -> bool:
	var card_type: String = str(card.get("type", ""))
	if phase == PHASE_ATTACK and player_id == active_player and selected_attacker != null and selected_target != null:
		return card_type == CHOICE_ATTACK or (card_type == "character" and str(card.get("id", "")) == str(selected_attacker.get("id", "")))
	if phase == PHASE_DEFENSE_RESPONSE and player_id == other_player(active_player) and selected_target != null:
		return card_type == CHOICE_DEFENSE or (card_type == "character" and str(card.get("id", "")) == str(selected_target.get("id", "")))
	return false


func add_empty_label(container: HBoxContainer, text: String) -> void:
	var label: Label = Label.new()
	set_exact_control_size(label, CARD_SIZE)
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	container.add_child(label)


func set_exact_control_size(control: Control, target_size: Vector2) -> void:
	control.custom_minimum_size = target_size
	control.size = target_size
	control.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	control.size_flags_vertical = Control.SIZE_SHRINK_CENTER


func clear_container(container: Container) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func clear_combat_selection() -> void:
	selected_attacker_info.clear()
	selected_attacker = null
	selected_target = null
	resource_choice_mode = ""
	clear_pending_effects()


func clear_pending_effects() -> void:
	pending_attack_card = null
	attack_pending = false
	pending_attack_bonus = 0
	pending_ignore_defense = 0
	clear_pending_defense_effects()
	clear_pending_utility()


func clear_pending_utility() -> void:
	pending_utility_card = null
	pending_utility_discard_required = 0
	pending_utility_draw_count = 0
	selected_utility_discard_indices.clear()


func clear_pending_defense_effects() -> void:
	pending_defense_card = null
	pending_defense_bonus = 0
	pending_damage_reduction = 0
	pending_survive_at_one = false


func add_vp(player_id: String, amount: int) -> void:
	if player_id == PLAYER_A:
		player_a_vp += amount
	else:
		player_b_vp += amount


func get_vp(player_id: String) -> int:
	return player_a_vp if player_id == PLAYER_A else player_b_vp


func get_hand(player_id: String) -> Array:
	return player_a_hand if player_id == PLAYER_A else player_b_hand


func get_field_row(player_id: String, row: String) -> Array:
	if player_id == PLAYER_A:
		return player_a_front if row == ROW_FRONT else player_a_support
	return player_b_front if row == ROW_FRONT else player_b_support


func get_main_deck(player_id: String):
	return player_a_main_deck if player_id == PLAYER_A else player_b_main_deck


func get_mission_deck(player_id: String):
	return player_a_mission_deck if player_id == PLAYER_A else player_b_mission_deck


func get_active_missions(player_id: String) -> Array:
	return player_a_active_missions if player_id == PLAYER_A else player_b_active_missions


func get_support_unlocks(player_id: String) -> Array[bool]:
	return player_a_support_unlocked if player_id == PLAYER_A else player_b_support_unlocked


func is_support_unlocked(player_id: String, mission_index: int) -> bool:
	if mission_index < 0 or mission_index >= MISSION_COUNT:
		return false
	return get_support_unlocks(player_id)[mission_index]


func unlock_support(player_id: String, mission_index: int) -> void:
	if mission_index >= 0 and mission_index < MISSION_COUNT:
		get_support_unlocks(player_id)[mission_index] = true


func get_hand_container(player_id: String) -> HBoxContainer:
	return player_a_hand_container if player_id == PLAYER_A else player_b_hand_container


func other_player(player_id: String) -> String:
	return PLAYER_B if player_id == PLAYER_A else PLAYER_A


func is_ai_controlled(player_id: String) -> bool:
	return selected_game_mode == GAME_MODE_AI and player_id == PLAYER_B


func player_name(player_id: String) -> String:
	return "Jugador %s" % player_id


func row_display_name(row: String) -> String:
	return "FRONT" if row == ROW_FRONT else "SUPPORT"
