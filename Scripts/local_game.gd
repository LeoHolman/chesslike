extends Node2D

var WhiteTile = preload("res://Scenes/WhiteTile.tscn")
var BlackTile = preload("res://Scenes/BlackTile.tscn")
const BOARD_MARGIN_RATIO = 0.05
const BASE_TILE_SIZE = 100.0
const INVALID_SQUARE = Vector2i(-1, -1)
const SELECTED_HIGHLIGHT = Color(1.0, 0.84, 0.0, 0.38)
const LEGAL_MOVE_HIGHLIGHT = Color(0.18, 0.75, 0.3, 0.35)
const SPELL_TARGET_HIGHLIGHT = Color(0.2, 0.67, 0.95, 0.35)
const TURN_INDICATOR_PADDING = 12.0
const TURN_INDICATOR_BACKGROUND = Color(0.95, 0.93, 0.86, 0.94)
const TURN_INDICATOR_BORDER = Color(0.2, 0.2, 0.2, 1.0)
const WHITE_POOL_PANEL_BACKGROUND = Color(0.27, 0.35, 0.52, 0.92)
const WHITE_POOL_PANEL_HOVER_BACKGROUND = Color(0.36, 0.46, 0.66, 0.96)
const BLACK_POOL_PANEL_BACKGROUND = Color(0.43, 0.25, 0.24, 0.92)
const BLACK_POOL_PANEL_HOVER_BACKGROUND = Color(0.57, 0.33, 0.31, 0.96)
const DROP_POOL_PANEL_BORDER = Color(0.9, 0.92, 0.98, 1.0)
const SPELL_PANEL_BORDER = Color(0.9, 0.92, 0.98, 1.0)
const HUD_PANEL_SPACING = 12.0
const FILE_NAMES = "abcdefghijklmnopqrstuvwxyz"
const DEFAULT_PROMOTION_PIECE_IDS = ["queen", "rook", "bishop", "knight"]
const CUSTOM_MOVE_KIND_JUMP = "jump"
const CUSTOM_MOVE_KIND_SLIDE = "slide"
const CUSTOM_CAPTURE_MODE_ANY = "any"
const CUSTOM_CAPTURE_MODE_NON_CAPTURE = "non_capture"
const CUSTOM_CAPTURE_MODE_CAPTURE_ONLY = "capture_only"
const CUSTOM_SLIDE_SCOPE_INFINITE = "infinite"
const CUSTOM_SLIDE_SCOPE_HALTING = "halting"
const DEFAULT_PLAYER1_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const DEFAULT_PLAYER2_COLOR = Color(0.08, 0.08, 0.08, 1.0)

var board_height = 8
var board_width = 8
var board_origin = Vector2.ZERO
var tile_size = 64.0
var pieces = {}
var selected_square = INVALID_SQUARE
var legal_moves: Array[Vector2i] = []
var current_turn = "white"
var move_history: Array[String] = []
var captured_pieces = {
	"white": [],
	"black": []
}
var game_over = false
var status_message = ""
var castling_enabled = true
var en_passant_enabled = true
var promotion_enabled = true
var en_passant_target_square = INVALID_SQUARE
var promotion_picker_layer: CanvasLayer
var promotion_picker_root: Control
var promotion_panel: PanelContainer
var promotion_title_label: Label
var promotion_option_buttons = {}
var promotion_options_container: VBoxContainer
var promotion_pending = false
var pending_promotion_move: Dictionary = {}
var promotion_piece_options: Array[String] = []
var victory_condition = "checkmate"
var piece_dropping_enabled = false
var capture_to_drop_pool_enabled = false
var limit_army_strength_enabled = false
var unbalanced_armies_enabled = false
var army_strength_cap = 2
var army_strength_cap_white = 2
var army_strength_cap_black = 2
var drop_pools = {
	"white": [],
	"black": []
}
var selected_drop_piece_id = ""
var selected_drop_piece_owner = ""
var legal_drop_squares: Array[Vector2i] = []
var drop_pool_selection_index = {
	"white": 0,
	"black": 0
}
var white_drop_pool_panel_rect = Rect2()
var black_drop_pool_panel_rect = Rect2()
var drop_pool_entry_rects = {
	"white": [],
	"black": []
}
var drop_pool_scroll_offsets = {
	"white": 0,
	"black": 0
}
var drop_pool_viewport_rects = {
	"white": Rect2(),
	"black": Rect2()
}
var player_side_colors = {
	"white": DEFAULT_PLAYER1_COLOR,
	"black": DEFAULT_PLAYER2_COLOR
}
var board_tile_colors = {
	"light": Color(1.0, 1.0, 1.0, 1.0),
	"dark": Color(0.41, 0.41, 0.41, 1.0)
}
var promotion_zone_rows = {
	"white": 1,
	"black": 1
}
var allow_undo_enabled = false
var undo_snapshots: Array[Dictionary] = []
var drop_piece_drag_active = false
var drop_piece_drag_position = Vector2.ZERO
var drop_pool_hover_owner = ""
var spell_cards_enabled = false
var spell_cards_random = true
var spell_card_allow_duplicates = true
var spell_draw_replacement_after_cast = false
var spell_card_available_ids: Array[String] = []
var spell_card_definitions_by_id: Dictionary = {}
var spell_card_hands = {
	"white": [],
	"black": []
}
var spell_card_hand_size_white = 0
var spell_card_hand_size_black = 0
var selected_spell_card_id = ""
var selected_spell_card_owner = ""
var pending_spell_card_id = ""
var pending_spell_card_owner = ""
var spell_cast_this_turn = false
var spell_haste_active = false
var spell_haste_owner = ""
var spell_haste_piece_square = INVALID_SQUARE
var spell_haste_moves_remaining = 0
var spell_fortify_active = false
var spell_fortify_owner = ""
var spell_fortify_piece_square = INVALID_SQUARE
var spell_barrier_active = false
var spell_barrier_owner = ""
var spell_barrier_square = INVALID_SQUARE
var spell_teleport_source_square = INVALID_SQUARE
var spell_keep_selection_after_cast = false
var white_spell_panel_rect = Rect2()
var black_spell_panel_rect = Rect2()
var spell_panel_entry_rects = {
	"white": [],
	"black": []
}
var spell_panel_scroll_offsets = {
	"white": 0,
	"black": 0
}
var spell_panel_viewport_rects = {
	"white": Rect2(),
	"black": Rect2()
}
var hud_scroll_drag_active = false
var hud_scroll_drag_kind = ""
var hud_scroll_drag_owner = ""
var hud_scroll_drag_last_mouse_position = Vector2.ZERO
var last_piece_move_should_end_turn = true
var online_mode = false
var local_player_side = "white"
var export_feedback_serial = 0
var export_feedback_popup: AcceptDialog
var export_file_dialog: FileDialog

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_setup_online_match_state()
	if OS.is_debug_build():
		_debug_validate_history_entry_owner_parsing()
	_initialize_board_state()
	_ensure_promotion_picker()
	_build_board()

func _exit_tree() -> void:
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager == null:
		return
	if network_manager.turn_state_received.is_connected(_on_network_turn_state_received):
		network_manager.turn_state_received.disconnect(_on_network_turn_state_received)
	if network_manager.online_match_ended.is_connected(_on_online_match_ended):
		network_manager.online_match_ended.disconnect(_on_online_match_ended)

func _setup_online_match_state() -> void:
	var network_manager = get_node_or_null("/root/NetworkManager")
	online_mode = false
	local_player_side = "white"
	if network_manager == null:
		return
	online_mode = bool(network_manager.is_online_active())
	local_player_side = str(network_manager.get_local_player_side())
	if not network_manager.turn_state_received.is_connected(_on_network_turn_state_received):
		network_manager.turn_state_received.connect(_on_network_turn_state_received)
	if not network_manager.online_match_ended.is_connected(_on_online_match_ended):
		network_manager.online_match_ended.connect(_on_online_match_ended)

func _unhandled_input(event: InputEvent) -> void:
	if promotion_pending:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and _update_hud_panel_scroll(event.position, -1):
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and _update_hud_panel_scroll(event.position, 1):
			return
	if event is InputEventMouseMotion and hud_scroll_drag_active:
		_update_hud_scroll_drag(event.position)
		return
	if event is InputEventMouseMotion and drop_piece_drag_active:
		drop_piece_drag_position = event.position
		drop_pool_hover_owner = _drop_pool_side_at_position(event.position)
		_build_board()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _begin_hud_scroll_drag(event.position):
				return
			_handle_pointer_press(event.position)
		else:
			if hud_scroll_drag_active:
				_end_hud_scroll_drag()
				return
			_handle_pointer_release(event.position)

func _handle_pointer_press(mouse_position: Vector2) -> void:
	if _try_handle_spell_card_click(mouse_position):
		return
	if piece_dropping_enabled and _try_begin_drop_pool_drag(mouse_position):
		return
	_handle_board_click(mouse_position)

func _handle_pointer_release(mouse_position: Vector2) -> void:
	if not drop_piece_drag_active:
		return
	drop_piece_drag_position = mouse_position
	drop_pool_hover_owner = _drop_pool_side_at_position(mouse_position)
	var square = _screen_to_square(mouse_position)
	if square != INVALID_SQUARE and _try_drop_piece_from_pool(square):
		_finalize_turn_after_move()
	else:
		_clear_drop_piece_selection()
		_build_board()

func _on_viewport_resized() -> void:
	_layout_promotion_picker()
	_build_board()

func _ensure_promotion_picker() -> void:
	if promotion_picker_layer != null:
		return

	promotion_picker_layer = CanvasLayer.new()
	promotion_picker_layer.layer = 10
	add_child(promotion_picker_layer)

	promotion_picker_root = Control.new()
	promotion_picker_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	promotion_picker_root.mouse_filter = Control.MOUSE_FILTER_STOP
	promotion_picker_root.visible = false
	promotion_picker_layer.add_child(promotion_picker_root)

	var dimmer = ColorRect.new()
	dimmer.color = Color(0.0, 0.0, 0.0, 0.35)
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	promotion_picker_root.add_child(dimmer)

	promotion_panel = PanelContainer.new()
	promotion_panel.custom_minimum_size = Vector2(280.0, 250.0)
	promotion_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	promotion_picker_root.add_child(promotion_panel)

	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	promotion_panel.add_child(content)

	promotion_title_label = Label.new()
	promotion_title_label.text = "Promote Pawn"
	promotion_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	promotion_title_label.add_theme_font_size_override("font_size", 20)
	content.add_child(promotion_title_label)

	promotion_options_container = VBoxContainer.new()
	promotion_options_container.add_theme_constant_override("separation", 6)
	content.add_child(promotion_options_container)

	var cancel_button = Button.new()
	cancel_button.text = "Cancel Move"
	cancel_button.pressed.connect(_on_promotion_cancelled)
	content.add_child(cancel_button)

	_layout_promotion_picker()

func _layout_promotion_picker() -> void:
	if promotion_panel == null:
		return
	var panel_size = promotion_panel.custom_minimum_size
	promotion_panel.set_anchors_preset(Control.PRESET_CENTER)
	promotion_panel.offset_left = -panel_size.x * 0.5
	promotion_panel.offset_top = -panel_size.y * 0.5
	promotion_panel.offset_right = panel_size.x * 0.5
	promotion_panel.offset_bottom = panel_size.y * 0.5

func _show_promotion_picker(piece_color: String) -> void:
	if promotion_picker_root == null:
		return
	_rebuild_promotion_option_buttons()
	promotion_title_label.text = "Promote %s Pawn" % _display_color(piece_color)
	promotion_picker_root.visible = true

func _rebuild_promotion_option_buttons() -> void:
	if promotion_options_container == null:
		return
	for child in promotion_options_container.get_children():
		child.queue_free()
	promotion_option_buttons.clear()

	if promotion_piece_options.is_empty():
		promotion_piece_options = _get_promotion_piece_pool()

	for piece_id in promotion_piece_options:
		var option_button = Button.new()
		option_button.text = "%s %s" % [_get_piece_symbol(piece_id), piece_id.capitalize()]
		option_button.pressed.connect(_on_promotion_option_selected.bind(piece_id))
		promotion_options_container.add_child(option_button)
		promotion_option_buttons[piece_id] = option_button

func _get_promotion_piece_pool() -> Array[String]:
	var configured_pool = $"/root/GameManager".PromotionPiecePool
	var normalized_pool: Array[String] = []
	if configured_pool is Array:
		for piece_id in configured_pool:
			var piece_key = str(piece_id)
			if not $"/root/GameManager".PieceDefinitions.has(piece_key):
				continue
			if normalized_pool.has(piece_key):
				continue
			normalized_pool.append(piece_key)

	if normalized_pool.is_empty():
		for piece_id in DEFAULT_PROMOTION_PIECE_IDS:
			if $"/root/GameManager".PieceDefinitions.has(piece_id):
				normalized_pool.append(piece_id)

	if normalized_pool.is_empty():
		normalized_pool.append("queen")

	return normalized_pool

func _get_starting_drop_pools() -> Dictionary:
	var source = $"/root/GameManager".StartingDropPools
	var parsed = {
		"white": [],
		"black": []
	}
	if source is Dictionary:
		for pool_owner in ["white", "black"]:
			var values = source.get(pool_owner, [])
			if values is Array:
				var normalized: Array = []
				for piece_id in values:
					normalized.append(str(piece_id))
				parsed[pool_owner] = normalized
	return parsed

func _spell_initialize_state_from_game_manager() -> void:
	spell_card_definitions_by_id.clear()
	for card in $"/root/GameManager".get_spell_card_definitions():
		var card_id = str(card.get("id", "")).strip_edges()
		if card_id == "":
			continue
		spell_card_definitions_by_id[card_id] = card.duplicate(true)

	spell_cards_random = bool($"/root/GameManager".SpellCardsRandom)
	spell_card_allow_duplicates = bool($"/root/GameManager".SpellCardAllowDuplicates)
	spell_draw_replacement_after_cast = bool($"/root/GameManager".SpellCardDrawReplacementAfterCast)
	spell_card_available_ids.clear()
	for card_id in $"/root/GameManager".normalize_spell_card_ids($"/root/GameManager".SpellCardAvailableIds):
		var key = str(card_id)
		if not spell_card_definitions_by_id.has(key):
			continue
		spell_card_available_ids.append(key)

	spell_card_hand_size_white = max(int($"/root/GameManager".SpellCardHandSizeWhite), 0)
	spell_card_hand_size_black = max(int($"/root/GameManager".SpellCardHandSizeBlack), 0)
	if spell_card_hand_size_white == 0 and spell_card_hand_size_black == 0:
		var fallback_size = max(int($"/root/GameManager".SpellCardHandSize), 0)
		spell_card_hand_size_white = fallback_size
		spell_card_hand_size_black = fallback_size

	spell_card_hands = {
		"white": [],
		"black": []
	}
	if spell_cards_enabled:
		if spell_cards_random:
			_spell_fill_hand_randomly("white", spell_card_hand_size_white)
			_spell_fill_hand_randomly("black", spell_card_hand_size_black)
		else:
			spell_card_hands = $"/root/GameManager".normalize_spell_card_hands($"/root/GameManager".StartingSpellHands)
			_spell_clamp_hand_to_rules("white")
			_spell_clamp_hand_to_rules("black")

	selected_spell_card_id = ""
	selected_spell_card_owner = ""
	pending_spell_card_id = ""
	pending_spell_card_owner = ""
	spell_cast_this_turn = false
	spell_haste_active = false
	spell_haste_owner = ""
	spell_haste_piece_square = INVALID_SQUARE
	spell_haste_moves_remaining = 0
	spell_fortify_active = false
	spell_fortify_owner = ""
	spell_fortify_piece_square = INVALID_SQUARE
	spell_barrier_active = false
	spell_barrier_owner = ""
	spell_barrier_square = INVALID_SQUARE
	spell_teleport_source_square = INVALID_SQUARE
	spell_keep_selection_after_cast = false
	white_spell_panel_rect = Rect2()
	black_spell_panel_rect = Rect2()
	spell_panel_entry_rects["white"] = []
	spell_panel_entry_rects["black"] = []
	last_piece_move_should_end_turn = true

func _spell_hand_size_for_owner(owner: String) -> int:
	if owner == "black":
		return spell_card_hand_size_black
	return spell_card_hand_size_white

func _spell_fill_hand_randomly(owner: String, target_size: int) -> void:
	var hand: Array = spell_card_hands.get(owner, [])
	while hand.size() < max(target_size, 0):
		if spell_card_available_ids.is_empty():
			break
		if spell_card_allow_duplicates:
			hand.append(spell_card_available_ids[randi_range(0, spell_card_available_ids.size() - 1)])
			continue
		var candidates: Array = []
		for candidate in spell_card_available_ids:
			if not hand.has(candidate):
				candidates.append(candidate)
		if candidates.is_empty():
			break
		hand.append(candidates[randi_range(0, candidates.size() - 1)])
	spell_card_hands[owner] = hand

func _spell_clamp_hand_to_rules(owner: String) -> void:
	var hand: Array = spell_card_hands.get(owner, [])
	var clamped: Array = []
	var seen = {}
	var cap = _spell_hand_size_for_owner(owner)
	for card_id in hand:
		var key = str(card_id)
		if not spell_card_definitions_by_id.has(key):
			continue
		if not spell_card_available_ids.has(key):
			continue
		if not spell_card_allow_duplicates and seen.has(key):
			continue
		if clamped.size() >= cap:
			break
		seen[key] = true
		clamped.append(key)
	spell_card_hands[owner] = clamped

func _spell_card_definition(card_id: String) -> Dictionary:
	if spell_card_definitions_by_id.has(card_id):
		return spell_card_definitions_by_id[card_id]
	return {}

func _spell_card_name(card_id: String) -> String:
	var definition = _spell_card_definition(card_id)
	var fallback = card_id.capitalize()
	return str(definition.get("name", fallback))

func _spell_card_description(card_id: String) -> String:
	var definition = _spell_card_definition(card_id)
	return str(definition.get("description", ""))

func _spell_card_type(card_id: String) -> String:
	var definition = _spell_card_definition(card_id)
	var kind = str(definition.get("type", "regular")).to_lower()
	if kind != "power":
		return "regular"
	return "power"

func _hide_promotion_picker() -> void:
	if promotion_picker_root != null:
		promotion_picker_root.visible = false

func _on_promotion_option_selected(piece_id: String) -> void:
	if not promotion_pending:
		return
	if not promotion_piece_options.has(piece_id):
		return
	if not pending_promotion_move.has("from") or not pending_promotion_move.has("to"):
		_hide_promotion_picker()
		promotion_pending = false
		pending_promotion_move.clear()
		return

	var from_square: Vector2i = pending_promotion_move.get("from", INVALID_SQUARE)
	var to_square: Vector2i = pending_promotion_move.get("to", INVALID_SQUARE)
	var move_info: Dictionary = pending_promotion_move.get("move_info", _create_move_info()).duplicate(true)
	if from_square == INVALID_SQUARE or to_square == INVALID_SQUARE or not pieces.has(from_square):
		_hide_promotion_picker()
		promotion_pending = false
		pending_promotion_move.clear()
		_build_board()
		return

	move_info["promotion_piece_id"] = piece_id
	var moving_piece: Dictionary = pieces[from_square]
	var committed = _commit_move(from_square, to_square, moving_piece, move_info)
	_hide_promotion_picker()
	promotion_pending = false
	pending_promotion_move.clear()
	if committed:
		if last_piece_move_should_end_turn:
			_finalize_turn_after_move()
		else:
			_build_board()
	else:
		_build_board()

func _on_promotion_cancelled() -> void:
	promotion_pending = false
	pending_promotion_move.clear()
	_hide_promotion_picker()
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	_build_board()

func _initialize_board_state() -> void:
	board_height = _get_dimension($"/root/GameManager".BoardHeight, 8)
	board_width = _get_dimension($"/root/GameManager".BoardWidth, 8)
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	current_turn = "white"
	move_history.clear()
	captured_pieces = {
		"white": [],
		"black": []
	}
	game_over = false
	status_message = ""
	var special_rules = $"/root/GameManager".SpecialRules
	victory_condition = str($"/root/GameManager".VictoryCondition)
	castling_enabled = bool(special_rules.get("castling", true))
	en_passant_enabled = bool(special_rules.get("en_passant", true))
	promotion_enabled = bool(special_rules.get("promotion", true))
	allow_undo_enabled = bool(special_rules.get("allow_undo", false))
	if online_mode:
		allow_undo_enabled = false
	piece_dropping_enabled = bool(special_rules.get("piece_dropping", false))
	capture_to_drop_pool_enabled = bool(special_rules.get("capture_to_drop_pool", false)) and piece_dropping_enabled
	spell_cards_enabled = bool(special_rules.get("enable_spell_cards", false))
	limit_army_strength_enabled = bool(special_rules.get("limit_army_strength", false))
	unbalanced_armies_enabled = bool(special_rules.get("unbalanced_armies", false))
	army_strength_cap = max(int($"/root/GameManager".ArmyStrengthCap), 2)
	army_strength_cap_white = max(int($"/root/GameManager".ArmyStrengthCapWhite), 2)
	army_strength_cap_black = max(int($"/root/GameManager".ArmyStrengthCapBlack), 2)
	player_side_colors = _get_player_side_colors($"/root/GameManager".PlayerColors)
	board_tile_colors = _get_board_tile_colors($"/root/GameManager".TileColors)
	promotion_zone_rows = _get_promotion_zone_rows($"/root/GameManager".PromotionZones)
	promotion_piece_options = _get_promotion_piece_pool()
	en_passant_target_square = INVALID_SQUARE
	drop_pools = _get_starting_drop_pools()
	selected_drop_piece_id = ""
	selected_drop_piece_owner = ""
	legal_drop_squares.clear()
	undo_snapshots.clear()
	drop_pool_hover_owner = ""
	drop_pool_selection_index["white"] = 0
	drop_pool_selection_index["black"] = 0
	_spell_initialize_state_from_game_manager()
	pieces.clear()
	if board_width < 1 or board_height < 1:
		return
	_load_starting_pieces()
	castling_enabled = castling_enabled and _board_supports_castling()
	_update_game_state(false)

func _add_piece(square: Vector2i, piece_id: String, piece_color: String) -> void:
	pieces[square] = {
		"piece_id": piece_id,
		"color": piece_color,
		"has_moved": false
	}

func _get_dimension(value: Variant, fallback: int) -> int:
	if value is int:
		return max(value, 1)
	if value is float:
		return max(roundi(value), 1)
	if value is String:
		return max(value.to_int(), 1)
	return max(fallback, 1)

func _get_index(value: Variant, fallback: int) -> int:
	if value is int:
		return max(value, 0)
	if value is float:
		return max(roundi(value), 0)
	if value is String:
		return max(value.to_int(), 0)
	return max(fallback, 0)

func _load_starting_pieces() -> bool:
	var starting_pieces = $"/root/GameManager".StartingPieces
	if not (starting_pieces is Array):
		return false
	if starting_pieces.is_empty():
		return false

	for piece_entry in starting_pieces:
		if not (piece_entry is Dictionary):
			continue

		var square = Vector2i(
			_get_index(piece_entry.get("x", 0), 0),
			_get_index(piece_entry.get("y", 0), 0)
		)
		if square.x >= board_width or square.y >= board_height:
			continue

		_add_piece(
			square,
			str(piece_entry.get("piece_id", "rook")),
			str(piece_entry.get("color", "white"))
		)

	return not pieces.is_empty()

func _build_board() -> void:
	for child in get_children():
		if child == promotion_picker_layer:
			continue
		child.queue_free()
	white_drop_pool_panel_rect = Rect2()
	black_drop_pool_panel_rect = Rect2()
	drop_pool_entry_rects["white"] = []
	drop_pool_entry_rects["black"] = []

	board_height = _get_dimension($"/root/GameManager".BoardHeight, board_height)
	board_width = _get_dimension($"/root/GameManager".BoardWidth, board_width)
	var viewport_size = get_viewport_rect().size
	var side_hud_reserve = _hud_side_reserve_width(viewport_size)
	var top_hud_reserve = _hud_top_reserve_height(viewport_size)
	var bottom_hud_reserve = _hud_bottom_reserve_height(viewport_size)
	var safe_width = max(viewport_size.x - side_hud_reserve * 2.0, viewport_size.x * 0.34)
	var safe_height = max(viewport_size.y - top_hud_reserve - bottom_hud_reserve, viewport_size.y * 0.28)
	tile_size = min(safe_width / max(board_width, 1), safe_height / max(board_height, 1))

	var board_pixel_width = board_width * tile_size
	var board_pixel_height = board_height * tile_size
	var centered_origin = Vector2(
		(viewport_size.x - board_pixel_width) / 2.0,
		(viewport_size.y - board_pixel_height) / 2.0
	)
	var min_origin_x = side_hud_reserve
	var max_origin_x = viewport_size.x - side_hud_reserve - board_pixel_width
	var min_origin_y = top_hud_reserve
	var max_origin_y = viewport_size.y - bottom_hud_reserve - board_pixel_height
	board_origin = Vector2(
		clampf(centered_origin.x, min_origin_x, max(min_origin_x, max_origin_x)),
		clampf(centered_origin.y, min_origin_y, max(min_origin_y, max_origin_y))
	)

	for y in board_height:
		for x in board_width:
			var tile_color = board_tile_colors.get("light", Color(1.0, 1.0, 1.0, 1.0)) if (x + y) % 2 == 0 else board_tile_colors.get("dark", Color(0.41, 0.41, 0.41, 1.0))
			add_child(_create_board_tile(Vector2i(x, y), tile_color))

	_draw_highlights()
	_draw_pieces()
	_draw_drop_piece_drag_preview()
	_draw_turn_indicator()
	_draw_back_to_main_menu_button()
	_draw_undo_button()
	_draw_status_feedback_banner()
	_draw_spell_card_panels()
	if piece_dropping_enabled:
		_draw_drop_pool_panels()
	else:
		_draw_captured_pieces_panels()
	_draw_move_history_panel()
	_draw_game_over_banner()

func _draw_turn_indicator() -> void:
	var font_size = _hud_font_size(0.22, 13, 24)
	var info_font_size = _hud_font_size(0.14, 10, 14)
	var swatch_size = clampf(tile_size * 0.24, 14.0, 24.0)
	var indicator_position = Vector2(
		TURN_INDICATOR_PADDING,
		TURN_INDICATOR_PADDING
	)
	var viewport_size = get_viewport_rect().size
	var indicator_width = clampf(tile_size * 2.2, 150.0, min(viewport_size.x * 0.30, 260.0))
	var indicator_height = _turn_indicator_height()
	var indicator_size = Vector2(indicator_width, indicator_height)

	var background = ColorRect.new()
	background.position = indicator_position
	background.size = indicator_size
	background.color = TURN_INDICATOR_BACKGROUND
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var border = _create_indicator_border(indicator_position, indicator_size)
	add_child(border)

	var swatch = ColorRect.new()
	swatch.position = indicator_position + Vector2(TURN_INDICATOR_PADDING, (indicator_size.y - swatch_size) / 2.0)
	swatch.size = Vector2(swatch_size, swatch_size)
	swatch.color = _turn_color_swatch(current_turn)
	add_child(swatch)

	var swatch_border = _create_indicator_border(swatch.position, swatch.size)
	add_child(swatch_border)

	var turn_label = Label.new()
	turn_label.text = "Turn: %s" % _display_color(current_turn)
	var turn_label_y = indicator_position.y + ((indicator_size.y - font_size) * 0.5) - 2.0
	if spell_cards_enabled:
		turn_label_y = indicator_position.y + TURN_INDICATOR_PADDING - 1.0
	turn_label.position = Vector2(indicator_position.x + TURN_INDICATOR_PADDING + swatch_size + 10.0, turn_label_y)
	turn_label.add_theme_font_size_override("font_size", font_size)
	turn_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	turn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(turn_label)

	if spell_cards_enabled:
		var cast_status_label = Label.new()
		cast_status_label.text = "Spell: Used" if spell_cast_this_turn else "Spell: Ready"
		cast_status_label.position = Vector2(
			indicator_position.x + TURN_INDICATOR_PADDING + swatch_size + 10.0,
			turn_label.position.y + font_size - 1.0
		)
		cast_status_label.add_theme_font_size_override("font_size", info_font_size)
		cast_status_label.add_theme_color_override("font_color", Color(0.64, 0.12, 0.12, 1.0) if spell_cast_this_turn else Color(0.11, 0.43, 0.12, 1.0))
		cast_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(cast_status_label)

func _turn_indicator_height() -> float:
	var swatch_size = clampf(tile_size * 0.24, 14.0, 24.0)
	var base_height = clampf(swatch_size + TURN_INDICATOR_PADDING * 2.0, 40.0, 56.0)
	if spell_cards_enabled:
		return max(base_height + _hud_font_size(0.14, 10, 14) + 4.0, 56.0)
	return base_height

func _hud_top_action_button_size() -> Vector2:
	var viewport_size = get_viewport_rect().size
	return Vector2(
		clampf(tile_size * 1.9, 120.0, min(viewport_size.x * 0.26, 220.0)),
		clampf(tile_size * 0.56, 30.0, 40.0)
	)

func _draw_back_to_main_menu_button() -> void:
	var indicator_height = _turn_indicator_height()
	var button = Button.new()
	button.position = Vector2(TURN_INDICATOR_PADDING, TURN_INDICATOR_PADDING + indicator_height + 8.0)
	button.size = _hud_top_action_button_size()
	button.text = "Back to Main Menu"
	button.pressed.connect(_on_back_to_main_menu_pressed)
	add_child(button)

func _draw_undo_button() -> void:
	if not allow_undo_enabled:
		return
	var indicator_height = _turn_indicator_height()
	var action_button_size = _hud_top_action_button_size()
	var button = Button.new()
	button.position = Vector2(TURN_INDICATOR_PADDING, TURN_INDICATOR_PADDING + indicator_height + 8.0 + action_button_size.y + 8.0)
	button.size = action_button_size
	button.text = "Undo"
	button.disabled = undo_snapshots.is_empty() or promotion_pending
	button.pressed.connect(_on_undo_button_pressed)
	add_child(button)

func _on_back_to_main_menu_pressed() -> void:
	if online_mode:
		var network_manager = get_node_or_null("/root/NetworkManager")
		if network_manager != null:
			network_manager.leave_session()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_undo_button_pressed() -> void:
	if online_mode and not _is_local_turn():
		return
	if undo_snapshots.is_empty():
		return
	var snapshot = undo_snapshots.pop_back()
	_restore_from_undo_snapshot(snapshot)
	_publish_turn_state_to_peer()

func _capture_undo_snapshot() -> Dictionary:
	return {
		"pieces": pieces.duplicate(true),
		"captured_pieces": captured_pieces.duplicate(true),
		"drop_pools": _duplicate_drop_pools(drop_pools),
		"spell_card_hands": $"/root/GameManager".normalize_spell_card_hands(spell_card_hands),
		"spell_cast_this_turn": spell_cast_this_turn,
		"spell_haste_active": spell_haste_active,
		"spell_haste_owner": spell_haste_owner,
		"spell_haste_piece_square": spell_haste_piece_square,
		"spell_haste_moves_remaining": spell_haste_moves_remaining,
		"spell_fortify_active": spell_fortify_active,
		"spell_fortify_owner": spell_fortify_owner,
		"spell_fortify_piece_square": spell_fortify_piece_square,
		"spell_barrier_active": spell_barrier_active,
		"spell_barrier_owner": spell_barrier_owner,
		"spell_barrier_square": spell_barrier_square,
		"spell_teleport_source_square": spell_teleport_source_square,
		"pending_spell_card_id": pending_spell_card_id,
		"pending_spell_card_owner": pending_spell_card_owner,
		"move_history": move_history.duplicate(true),
		"current_turn": current_turn,
		"status_message": status_message,
		"game_over": game_over,
		"en_passant_target": en_passant_target_square
	}

func _restore_from_undo_snapshot(snapshot: Dictionary) -> void:
	pieces = snapshot.get("pieces", {}).duplicate(true)
	captured_pieces = snapshot.get("captured_pieces", {"white": [], "black": []}).duplicate(true)
	drop_pools = _duplicate_drop_pools(snapshot.get("drop_pools", {}))
	spell_card_hands = $"/root/GameManager".normalize_spell_card_hands(snapshot.get("spell_card_hands", {"white": [], "black": []}))
	spell_cast_this_turn = bool(snapshot.get("spell_cast_this_turn", false))
	spell_haste_active = bool(snapshot.get("spell_haste_active", false))
	spell_haste_owner = str(snapshot.get("spell_haste_owner", ""))
	spell_haste_piece_square = snapshot.get("spell_haste_piece_square", INVALID_SQUARE)
	spell_haste_moves_remaining = int(snapshot.get("spell_haste_moves_remaining", 0))
	spell_fortify_active = bool(snapshot.get("spell_fortify_active", false))
	spell_fortify_owner = str(snapshot.get("spell_fortify_owner", ""))
	spell_fortify_piece_square = snapshot.get("spell_fortify_piece_square", INVALID_SQUARE)
	spell_barrier_active = bool(snapshot.get("spell_barrier_active", false))
	spell_barrier_owner = str(snapshot.get("spell_barrier_owner", ""))
	spell_barrier_square = snapshot.get("spell_barrier_square", INVALID_SQUARE)
	spell_teleport_source_square = snapshot.get("spell_teleport_source_square", INVALID_SQUARE)
	pending_spell_card_id = str(snapshot.get("pending_spell_card_id", ""))
	pending_spell_card_owner = str(snapshot.get("pending_spell_card_owner", ""))
	selected_spell_card_id = pending_spell_card_id
	selected_spell_card_owner = pending_spell_card_owner
	spell_keep_selection_after_cast = false
	if not spell_haste_active:
		spell_haste_owner = ""
		spell_haste_piece_square = INVALID_SQUARE
		spell_haste_moves_remaining = 0
	if not spell_fortify_active:
		spell_fortify_owner = ""
		spell_fortify_piece_square = INVALID_SQUARE
	if not spell_barrier_active:
		spell_barrier_owner = ""
		spell_barrier_square = INVALID_SQUARE
	move_history = (snapshot.get("move_history", []) as Array).duplicate(true)
	current_turn = str(snapshot.get("current_turn", "white"))
	status_message = str(snapshot.get("status_message", ""))
	game_over = bool(snapshot.get("game_over", false))
	en_passant_target_square = snapshot.get("en_passant_target", INVALID_SQUARE)
	promotion_pending = false
	pending_promotion_move.clear()
	_hide_promotion_picker()
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	legal_drop_squares.clear()
	selected_drop_piece_id = ""
	selected_drop_piece_owner = ""
	drop_piece_drag_active = false
	drop_pool_hover_owner = ""
	_build_board()

func _is_local_turn() -> bool:
	if not online_mode:
		return true
	return current_turn == local_player_side

func _publish_turn_state_to_peer() -> void:
	if not online_mode:
		return
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager == null:
		return
	network_manager.submit_turn_state(_export_network_state())

func _on_network_turn_state_received(state: Dictionary) -> void:
	if not online_mode:
		return
	_import_network_state(state)
	_build_board()

func _on_online_match_ended(reason: String) -> void:
	if not online_mode:
		return
	game_over = true
	status_message = reason
	promotion_pending = false
	pending_promotion_move.clear()
	_hide_promotion_picker()
	_build_board()

func _export_network_state() -> Dictionary:
	var serialized_pieces: Array = []
	for square in pieces.keys():
		var piece_data: Dictionary = pieces[square]
		serialized_pieces.append({
			"x": square.x,
			"y": square.y,
			"piece_id": str(piece_data.get("piece_id", "")),
			"color": str(piece_data.get("color", "white")),
			"has_moved": bool(piece_data.get("has_moved", false))
		})

	return {
		"pieces": serialized_pieces,
		"captured_pieces": captured_pieces.duplicate(true),
		"drop_pools": _duplicate_drop_pools(drop_pools),
		"spell_card_hands": $"/root/GameManager".normalize_spell_card_hands(spell_card_hands),
		"spell_cast_this_turn": spell_cast_this_turn,
		"spell_haste_active": spell_haste_active,
		"spell_haste_owner": spell_haste_owner,
		"spell_haste_piece_square": {
			"x": spell_haste_piece_square.x,
			"y": spell_haste_piece_square.y
		},
		"spell_haste_moves_remaining": spell_haste_moves_remaining,
		"spell_fortify_active": spell_fortify_active,
		"spell_fortify_owner": spell_fortify_owner,
		"spell_fortify_piece_square": {
			"x": spell_fortify_piece_square.x,
			"y": spell_fortify_piece_square.y
		},
		"spell_barrier_active": spell_barrier_active,
		"spell_barrier_owner": spell_barrier_owner,
		"spell_barrier_square": {
			"x": spell_barrier_square.x,
			"y": spell_barrier_square.y
		},
		"spell_teleport_source_square": {
			"x": spell_teleport_source_square.x,
			"y": spell_teleport_source_square.y
		},
		"pending_spell_card_id": pending_spell_card_id,
		"pending_spell_card_owner": pending_spell_card_owner,
		"move_history": move_history.duplicate(true),
		"current_turn": current_turn,
		"status_message": status_message,
		"game_over": game_over,
		"en_passant_target": {
			"x": en_passant_target_square.x,
			"y": en_passant_target_square.y
		}
	}

func _import_network_state(state: Dictionary) -> void:
	pieces.clear()
	var serialized_pieces = state.get("pieces", [])
	if serialized_pieces is Array:
		for entry in serialized_pieces:
			if not (entry is Dictionary):
				continue
			var square = Vector2i(int(entry.get("x", -1)), int(entry.get("y", -1)))
			if square.x < 0 or square.y < 0 or square.x >= board_width or square.y >= board_height:
				continue
			pieces[square] = {
				"piece_id": str(entry.get("piece_id", "")),
				"color": str(entry.get("color", "white")),
				"has_moved": bool(entry.get("has_moved", false))
			}

	captured_pieces = state.get("captured_pieces", {"white": [], "black": []}).duplicate(true)
	drop_pools = _duplicate_drop_pools(state.get("drop_pools", {}))
	spell_card_hands = $"/root/GameManager".normalize_spell_card_hands(state.get("spell_card_hands", {"white": [], "black": []}))
	spell_cast_this_turn = bool(state.get("spell_cast_this_turn", false))
	spell_haste_active = bool(state.get("spell_haste_active", false))
	spell_haste_owner = str(state.get("spell_haste_owner", ""))
	spell_haste_moves_remaining = int(state.get("spell_haste_moves_remaining", 0))
	var haste_square = state.get("spell_haste_piece_square", {})
	if haste_square is Dictionary:
		spell_haste_piece_square = Vector2i(int(haste_square.get("x", -1)), int(haste_square.get("y", -1)))
	else:
		spell_haste_piece_square = INVALID_SQUARE
	spell_fortify_active = bool(state.get("spell_fortify_active", false))
	spell_fortify_owner = str(state.get("spell_fortify_owner", ""))
	var fortify_square = state.get("spell_fortify_piece_square", {})
	if fortify_square is Dictionary:
		spell_fortify_piece_square = Vector2i(int(fortify_square.get("x", -1)), int(fortify_square.get("y", -1)))
	else:
		spell_fortify_piece_square = INVALID_SQUARE
	spell_barrier_active = bool(state.get("spell_barrier_active", false))
	spell_barrier_owner = str(state.get("spell_barrier_owner", ""))
	var barrier_square = state.get("spell_barrier_square", {})
	if barrier_square is Dictionary:
		spell_barrier_square = Vector2i(int(barrier_square.get("x", -1)), int(barrier_square.get("y", -1)))
	else:
		spell_barrier_square = INVALID_SQUARE
	var teleport_square = state.get("spell_teleport_source_square", {})
	if teleport_square is Dictionary:
		spell_teleport_source_square = Vector2i(int(teleport_square.get("x", -1)), int(teleport_square.get("y", -1)))
	else:
		spell_teleport_source_square = INVALID_SQUARE
	pending_spell_card_id = str(state.get("pending_spell_card_id", ""))
	pending_spell_card_owner = str(state.get("pending_spell_card_owner", ""))
	selected_spell_card_id = pending_spell_card_id
	selected_spell_card_owner = pending_spell_card_owner
	spell_keep_selection_after_cast = false
	if not spell_haste_active:
		spell_haste_owner = ""
		spell_haste_piece_square = INVALID_SQUARE
		spell_haste_moves_remaining = 0
	if not spell_fortify_active:
		spell_fortify_owner = ""
		spell_fortify_piece_square = INVALID_SQUARE
	if not spell_barrier_active:
		spell_barrier_owner = ""
		spell_barrier_square = INVALID_SQUARE
	move_history = (state.get("move_history", []) as Array).duplicate(true)
	current_turn = str(state.get("current_turn", "white"))
	status_message = str(state.get("status_message", ""))
	game_over = bool(state.get("game_over", false))
	var en_passant_target = state.get("en_passant_target", {})
	if en_passant_target is Dictionary:
		en_passant_target_square = Vector2i(int(en_passant_target.get("x", -1)), int(en_passant_target.get("y", -1)))
	else:
		en_passant_target_square = INVALID_SQUARE

	promotion_pending = false
	pending_promotion_move.clear()
	_hide_promotion_picker()
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	legal_drop_squares.clear()
	selected_drop_piece_id = ""
	selected_drop_piece_owner = ""
	drop_piece_drag_active = false
	drop_pool_hover_owner = ""
	undo_snapshots.clear()

func _draw_status_feedback_banner() -> void:
	if status_message == "" or game_over:
		return

	var viewport_size = get_viewport_rect().size
	var panel_width = clampf(viewport_size.x * 0.42, 240.0, 520.0)
	var panel_height = clampf(viewport_size.y * 0.075, 42.0, 76.0)
	var panel_position = Vector2(
		(viewport_size.x - panel_width) * 0.5,
		TURN_INDICATOR_PADDING
	)
	var banner_style = _status_feedback_style(status_message)
	var background_color: Color = banner_style.get("background", _player_color(current_turn))
	var text_color = _high_contrast_text_color(background_color)

	var background = ColorRect.new()
	background.position = panel_position
	background.size = Vector2(panel_width, panel_height)
	background.color = background_color
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	add_child(_create_colored_border(panel_position, Vector2(panel_width, panel_height), banner_style.get("border", Color(1.0, 0.82, 0.64, 1.0))))

	var feedback_label = Label.new()
	feedback_label.position = panel_position + Vector2(10.0, 4.0)
	feedback_label.size = Vector2(panel_width - 20.0, panel_height - 8.0)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback_label.text = status_message
	feedback_label.add_theme_font_size_override("font_size", _hud_font_size(0.2, 15, 26))
	feedback_label.add_theme_color_override("font_color", text_color)
	feedback_label.add_theme_constant_override("outline_size", 0)
	feedback_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(feedback_label)

func _status_feedback_style(message: String) -> Dictionary:
	var owner = _status_message_owner(message)
	var background = _player_color(owner)
	background.a = 0.92
	var border = _high_contrast_text_color(background)
	border.a = 0.95
	return {
		"background": background,
		"border": border
	}

func _status_message_owner(message: String) -> String:
	var lower_message = message.to_lower()
	if lower_message.find("player 2") != -1:
		return "black"
	if lower_message.find("player 1") != -1:
		return "white"
	return current_turn


func _draw_captured_pieces_panels() -> void:
	var panel_size = _get_hud_panel_size(3.0, 1.7, 168.0, 84.0)
	var left_position = Vector2(
		TURN_INDICATOR_PADDING,
		get_viewport_rect().size.y - panel_size.y - TURN_INDICATOR_PADDING
	)
	var right_position = Vector2(
		get_viewport_rect().size.x - panel_size.x - TURN_INDICATOR_PADDING,
		get_viewport_rect().size.y - panel_size.y - TURN_INDICATOR_PADDING
	)
	_draw_hud_panel(left_position, panel_size, "Player 1 Captures", [_format_captured_strength_summary("white"), _format_captured_piece_list("white")])
	_draw_hud_panel(right_position, panel_size, "Player 2 Captures", [_format_captured_strength_summary("black"), _format_captured_piece_list("black")])

func _draw_drop_pool_panels() -> void:
	var panel_size = _get_hud_panel_size(3.0, 2.0, 168.0, 102.0)
	var left_position = Vector2(
		TURN_INDICATOR_PADDING,
		get_viewport_rect().size.y - panel_size.y - TURN_INDICATOR_PADDING
	)
	var right_position = Vector2(
		get_viewport_rect().size.x - panel_size.x - TURN_INDICATOR_PADDING,
		get_viewport_rect().size.y - panel_size.y - TURN_INDICATOR_PADDING
	)
	white_drop_pool_panel_rect = Rect2(left_position, panel_size)
	black_drop_pool_panel_rect = Rect2(right_position, panel_size)
	drop_pool_viewport_rects["white"] = Rect2()
	drop_pool_viewport_rects["black"] = Rect2()

	_draw_drop_pool_panel(left_position, panel_size, "Player 1 Drop Pool", "white")
	_draw_drop_pool_panel(right_position, panel_size, "Player 2 Drop Pool", "black")

func _draw_spell_card_panels() -> void:
	white_spell_panel_rect = Rect2()
	black_spell_panel_rect = Rect2()
	spell_panel_entry_rects["white"] = []
	spell_panel_entry_rects["black"] = []
	spell_panel_viewport_rects["white"] = Rect2()
	spell_panel_viewport_rects["black"] = Rect2()
	if not spell_cards_enabled:
		return

	var panel_size = _get_hud_panel_size(3.0, 1.55, 180.0, 80.0)
	var footer_height = _get_hud_panel_size(3.0, 2.0, 168.0, 102.0).y
	var y = get_viewport_rect().size.y - footer_height - panel_size.y - TURN_INDICATOR_PADDING - 8.0
	var left_position = Vector2(TURN_INDICATOR_PADDING, y)
	var right_position = Vector2(get_viewport_rect().size.x - panel_size.x - TURN_INDICATOR_PADDING, y)
	white_spell_panel_rect = Rect2(left_position, panel_size)
	black_spell_panel_rect = Rect2(right_position, panel_size)
	_draw_single_spell_card_panel(left_position, panel_size, "Player 1 Hand", "white")
	_draw_single_spell_card_panel(right_position, panel_size, "Player 2 Hand", "black")

func _draw_single_spell_card_panel(panel_position: Vector2, panel_size: Vector2, title: String, owner: String) -> void:
	var background = ColorRect.new()
	background.position = panel_position
	background.size = panel_size
	background.color = _drop_pool_panel_color(owner, false)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	add_child(_create_colored_border(panel_position, panel_size, SPELL_PANEL_BORDER))

	var title_label = Label.new()
	title_label.position = panel_position + Vector2(TURN_INDICATOR_PADDING, TURN_INDICATOR_PADDING - 2.0)
	title_label.text = "%s (%d/%d)" % [title, (spell_card_hands.get(owner, []) as Array).size(), _spell_hand_size_for_owner(owner)]
	title_label.add_theme_font_size_override("font_size", _hud_font_size(0.16, 11, 15))
	title_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0, 1.0))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_label)

	var entry_rects: Array = []
	var row_height = max(tile_size * 0.24, 15.0)
	var content_x = panel_position.x + TURN_INDICATOR_PADDING
	var content_width = panel_size.x - TURN_INDICATOR_PADDING * 2.0
	var current_y = panel_position.y + TURN_INDICATOR_PADDING + 20.0
	var body_height = max(panel_size.y - (TURN_INDICATOR_PADDING + 24.0), row_height)
	var entries: Array = spell_card_hands.get(owner, [])
	spell_panel_viewport_rects[owner] = Rect2(content_x, current_y, content_width, body_height)

	if entries.is_empty():
		spell_panel_scroll_offsets[owner] = 0
		var empty_label = Label.new()
		empty_label.position = Vector2(content_x, current_y)
		empty_label.size = Vector2(content_width, body_height)
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.text = "(empty)"
		empty_label.add_theme_font_size_override("font_size", _hud_font_size(0.12, 10, 12))
		empty_label.add_theme_color_override("font_color", Color(0.9, 0.93, 1.0, 1.0))
		empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(empty_label)
		spell_panel_entry_rects[owner] = entry_rects
		return

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(content_x, current_y)
	scroll.size = Vector2(content_width, body_height)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scroll)

	var rows = VBoxContainer.new()
	rows.custom_minimum_size = Vector2(content_width, 0.0)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 3)
	scroll.add_child(rows)

	var total_rows_height = entries.size() * row_height + max(entries.size() - 1, 0) * 3
	rows.custom_minimum_size = Vector2(content_width, max(body_height, total_rows_height))

	var y_offset = 0.0
	for index in range(entries.size()):
		var card_id = str(entries[index])
		var row_rect = Rect2(Vector2(0.0, y_offset), Vector2(content_width, row_height))
		var selected = owner == selected_spell_card_owner and card_id == selected_spell_card_id

		var row_label = Label.new()
		row_label.custom_minimum_size = Vector2(content_width, row_height)
		row_label.clip_text = true
		row_label.text = "%s%s [%s]" % ["> " if selected else "", _spell_card_name(card_id), "P" if _spell_card_type(card_id) == "power" else "R"]
		row_label.tooltip_text = _spell_card_description(card_id)
		row_label.add_theme_font_size_override("font_size", _hud_font_size(0.12, 10, 12))
		row_label.add_theme_color_override("font_color", Color(0.99, 0.99, 1.0, 1.0) if selected else Color(0.94, 0.96, 1.0, 1.0))
		row_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rows.add_child(row_label)

		entry_rects.append({"card_id": card_id, "rect": row_rect})
		y_offset += row_height + 3.0

	var saved_scroll = int(spell_panel_scroll_offsets.get(owner, 0))
	var max_scroll = max(int(ceil(total_rows_height - body_height)), 0)
	scroll.scroll_vertical = clamp(saved_scroll, 0, max_scroll)
	spell_panel_scroll_offsets[owner] = scroll.scroll_vertical

	spell_panel_entry_rects[owner] = entry_rects

func _try_handle_spell_card_click(mouse_position: Vector2) -> bool:
	if not spell_cards_enabled:
		return false
	if game_over or promotion_pending:
		return false
	if online_mode and not _is_local_turn():
		return false
	var owner = _spell_panel_side_at_position(mouse_position)
	if owner == "":
		return false
	if owner != current_turn:
		status_message = "You can only cast cards from your own hand."
		_build_board()
		return true
	if spell_cast_this_turn:
		status_message = "Only one spell card can be cast per turn."
		_build_board()
		return true

	var entry = _get_spell_panel_entry_at_position(owner, mouse_position)
	if entry.is_empty():
		return true
	var card_id = str(entry.get("card_id", ""))
	if card_id == "":
		return true

	if pending_spell_card_id == card_id and pending_spell_card_owner == owner:
		pending_spell_card_id = ""
		pending_spell_card_owner = ""
		selected_spell_card_id = ""
		selected_spell_card_owner = ""
		spell_teleport_source_square = INVALID_SQUARE
		status_message = "Spell cast canceled."
		_build_board()
		return true

	selected_spell_card_id = card_id
	selected_spell_card_owner = owner
	pending_spell_card_id = card_id
	pending_spell_card_owner = owner
	spell_teleport_source_square = INVALID_SQUARE
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	legal_drop_squares.clear()
	match card_id:
		"haste", "fortify":
			status_message = "Cast %s: click a target allied piece." % _spell_card_name(card_id)
		"assassinate":
			status_message = "Cast %s: click a target enemy non-king piece." % _spell_card_name(card_id)
		"teleport":
			status_message = "Cast %s: click an allied piece, then an empty destination square." % _spell_card_name(card_id)
		"barrier":
			status_message = "Cast %s: click any board square to block movement this turn." % _spell_card_name(card_id)
		_:
			status_message = "Cast %s: choose a target." % _spell_card_name(card_id)
	_build_board()
	return true

func _spell_panel_side_at_position(mouse_position: Vector2) -> String:
	if white_spell_panel_rect.has_point(mouse_position):
		return "white"
	if black_spell_panel_rect.has_point(mouse_position):
		return "black"
	return ""

func _get_spell_panel_entry_at_position(owner: String, mouse_position: Vector2) -> Dictionary:
	var viewport_rect: Rect2 = spell_panel_viewport_rects.get(owner, Rect2())
	if not viewport_rect.has_point(mouse_position):
		return {}
	var local_position = Vector2(
		mouse_position.x - viewport_rect.position.x,
		mouse_position.y - viewport_rect.position.y + int(spell_panel_scroll_offsets.get(owner, 0))
	)
	var entries: Array = spell_panel_entry_rects.get(owner, [])
	for entry in entries:
		if entry is Dictionary and Rect2(entry.get("rect", Rect2())).has_point(local_position):
			return entry
	return {}

func _begin_hud_scroll_drag(mouse_position: Vector2) -> bool:
	if drop_piece_drag_active:
		return false
	for owner in ["white", "black"]:
		var spell_view: Rect2 = spell_panel_viewport_rects.get(owner, Rect2())
		if spell_view.has_point(mouse_position):
			if not _get_spell_panel_entry_at_position(owner, mouse_position).is_empty():
				return false
			hud_scroll_drag_active = true
			hud_scroll_drag_kind = "spell"
			hud_scroll_drag_owner = owner
			hud_scroll_drag_last_mouse_position = mouse_position
			return true

	if not piece_dropping_enabled:
		return false
	for owner in ["white", "black"]:
		var pool_view: Rect2 = drop_pool_viewport_rects.get(owner, Rect2())
		if pool_view.has_point(mouse_position):
			if not _get_drop_pool_entry_at_position(owner, mouse_position).is_empty():
				return false
			hud_scroll_drag_active = true
			hud_scroll_drag_kind = "drop_pool"
			hud_scroll_drag_owner = owner
			hud_scroll_drag_last_mouse_position = mouse_position
			return true

	return false

func _update_hud_scroll_drag(mouse_position: Vector2) -> void:
	if not hud_scroll_drag_active:
		return
	var delta_y = mouse_position.y - hud_scroll_drag_last_mouse_position.y
	hud_scroll_drag_last_mouse_position = mouse_position
	if is_zero_approx(delta_y):
		return

	var owner = hud_scroll_drag_owner
	if hud_scroll_drag_kind == "spell":
		var view_rect: Rect2 = spell_panel_viewport_rects.get(owner, Rect2())
		var max_scroll = _hud_list_max_scroll(spell_panel_entry_rects.get(owner, []), view_rect.size.y)
		var next_scroll = clamp(int(spell_panel_scroll_offsets.get(owner, 0)) - int(round(delta_y)), 0, max_scroll)
		if next_scroll == int(spell_panel_scroll_offsets.get(owner, 0)):
			return
		spell_panel_scroll_offsets[owner] = next_scroll
		_build_board()
		return

	if hud_scroll_drag_kind == "drop_pool":
		var pool_view: Rect2 = drop_pool_viewport_rects.get(owner, Rect2())
		var pool_max_scroll = _hud_list_max_scroll(drop_pool_entry_rects.get(owner, []), pool_view.size.y)
		var next_pool_scroll = clamp(int(drop_pool_scroll_offsets.get(owner, 0)) - int(round(delta_y)), 0, pool_max_scroll)
		if next_pool_scroll == int(drop_pool_scroll_offsets.get(owner, 0)):
			return
		drop_pool_scroll_offsets[owner] = next_pool_scroll
		_build_board()

func _end_hud_scroll_drag() -> void:
	hud_scroll_drag_active = false
	hud_scroll_drag_kind = ""
	hud_scroll_drag_owner = ""

func _update_hud_panel_scroll(mouse_position: Vector2, direction: int) -> bool:
	if direction == 0:
		return false

	for owner in ["white", "black"]:
		var spell_view: Rect2 = spell_panel_viewport_rects.get(owner, Rect2())
		if spell_view.has_point(mouse_position):
			var max_scroll = _hud_list_max_scroll(spell_panel_entry_rects.get(owner, []), spell_view.size.y)
			var next_scroll = clamp(int(spell_panel_scroll_offsets.get(owner, 0)) + direction * 24, 0, max_scroll)
			if next_scroll == int(spell_panel_scroll_offsets.get(owner, 0)):
				return true
			spell_panel_scroll_offsets[owner] = next_scroll
			_build_board()
			return true

	if piece_dropping_enabled:
		for owner in ["white", "black"]:
			var pool_view: Rect2 = drop_pool_viewport_rects.get(owner, Rect2())
			if pool_view.has_point(mouse_position):
				var max_scroll = _hud_list_max_scroll(drop_pool_entry_rects.get(owner, []), pool_view.size.y)
				var next_scroll = clamp(int(drop_pool_scroll_offsets.get(owner, 0)) + direction * 24, 0, max_scroll)
				if next_scroll == int(drop_pool_scroll_offsets.get(owner, 0)):
					return true
				drop_pool_scroll_offsets[owner] = next_scroll
				_build_board()
				return true

	return false

func _hud_list_max_scroll(entries: Array, viewport_height: float) -> int:
	var total_height = 0.0
	for entry in entries:
		total_height = max(total_height, Rect2(entry.get("rect", Rect2())).end.y)
	return max(int(ceil(total_height - viewport_height)), 0)

func _try_cast_pending_spell_at_square(target_square: Vector2i) -> bool:
	if pending_spell_card_id == "" or pending_spell_card_owner != current_turn:
		return false
	spell_keep_selection_after_cast = false

	match pending_spell_card_id:
		"haste":
			if not pieces.has(target_square):
				status_message = "Target square has no piece for %s." % _spell_card_name(pending_spell_card_id)
				_build_board()
				return false
			return _cast_haste_on_square(target_square)
		"assassinate":
			if not pieces.has(target_square):
				status_message = "Target square has no piece for %s." % _spell_card_name(pending_spell_card_id)
				_build_board()
				return false
			return _cast_assassinate_on_square(target_square)
		"fortify":
			if not pieces.has(target_square):
				status_message = "Target square has no piece for %s." % _spell_card_name(pending_spell_card_id)
				_build_board()
				return false
			return _cast_fortify_on_square(target_square)
		"teleport":
			return _cast_teleport_on_square(target_square)
		"barrier":
			return _cast_barrier_on_square(target_square)
		_:
			status_message = "Spell %s is not implemented yet." % _spell_card_name(pending_spell_card_id)
			_build_board()
			return false

func _cast_haste_on_square(target_square: Vector2i) -> bool:
	var target_piece: Dictionary = pieces[target_square]
	if str(target_piece.get("color", "")) != current_turn:
		status_message = "Haste must target an allied piece."
		_build_board()
		return false
	undo_snapshots.append(_capture_undo_snapshot())
	if not _consume_spell_card_from_hand(current_turn, "haste"):
		undo_snapshots.pop_back()
		status_message = "Haste is no longer in hand."
		_build_board()
		return false
	spell_haste_active = true
	spell_haste_owner = current_turn
	spell_haste_piece_square = target_square
	spell_haste_moves_remaining = 2
	spell_cast_this_turn = true
	status_message = "%s casts Haste on %s at %s." % [_display_color(current_turn), _get_piece_symbol(str(target_piece.get("piece_id", ""))), _square_to_notation(target_square)]
	_record_spell_cast_in_history(current_turn, "haste", "on %s @ %s" % [_get_piece_symbol(str(target_piece.get("piece_id", ""))), _square_to_notation(target_square)])
	_pending_spell_cleanup()
	_publish_turn_state_to_peer()
	return true

func _cast_assassinate_on_square(target_square: Vector2i) -> bool:
	var target_piece: Dictionary = pieces[target_square]
	if str(target_piece.get("color", "")) == current_turn:
		status_message = "Assassinate must target an enemy piece."
		_build_board()
		return false
	if str(target_piece.get("piece_id", "")) == "king":
		status_message = "Assassinate cannot target a king."
		_build_board()
		return false
	undo_snapshots.append(_capture_undo_snapshot())
	if not _consume_spell_card_from_hand(current_turn, "assassinate"):
		undo_snapshots.pop_back()
		status_message = "Assassinate is no longer in hand."
		_build_board()
		return false

	pieces.erase(target_square)
	if capture_to_drop_pool_enabled:
		_add_piece_to_drop_pool(current_turn, str(target_piece.get("piece_id", "")))
	else:
		_record_capture(current_turn, target_piece)
	spell_cast_this_turn = true
	status_message = "%s casts Assassinate at %s." % [_display_color(current_turn), _square_to_notation(target_square)]
	_record_spell_cast_in_history(current_turn, "assassinate", "x %s @ %s" % [_get_piece_symbol(str(target_piece.get("piece_id", ""))), _square_to_notation(target_square)])
	_pending_spell_cleanup()
	return true

func _cast_fortify_on_square(target_square: Vector2i) -> bool:
	var target_piece: Dictionary = pieces[target_square]
	if str(target_piece.get("color", "")) != current_turn:
		status_message = "Fortify must target an allied piece."
		_build_board()
		return false
	undo_snapshots.append(_capture_undo_snapshot())
	if not _consume_spell_card_from_hand(current_turn, "fortify"):
		undo_snapshots.pop_back()
		status_message = "Fortify is no longer in hand."
		_build_board()
		return false
	spell_fortify_active = true
	spell_fortify_owner = current_turn
	spell_fortify_piece_square = target_square
	spell_cast_this_turn = true
	status_message = "%s casts Fortify on %s at %s." % [_display_color(current_turn), _get_piece_symbol(str(target_piece.get("piece_id", ""))), _square_to_notation(target_square)]
	_record_spell_cast_in_history(current_turn, "fortify", "on %s @ %s" % [_get_piece_symbol(str(target_piece.get("piece_id", ""))), _square_to_notation(target_square)])
	_pending_spell_cleanup()
	_publish_turn_state_to_peer()
	return true

func _cast_teleport_on_square(target_square: Vector2i) -> bool:
	if spell_teleport_source_square == INVALID_SQUARE:
		if not pieces.has(target_square):
			status_message = "Teleport: select an allied piece first."
			_build_board()
			return false
		var source_piece: Dictionary = pieces[target_square]
		if str(source_piece.get("color", "")) != current_turn:
			status_message = "Teleport must start from an allied piece."
			_build_board()
			return false
		spell_teleport_source_square = target_square
		status_message = "Teleport selected %s at %s. Choose an empty destination square." % [_get_piece_symbol(str(source_piece.get("piece_id", ""))), _square_to_notation(target_square)]
		_build_board()
		return false

	if target_square == spell_teleport_source_square:
		status_message = "Teleport destination must be a different square."
		_build_board()
		return false
	if pieces.has(target_square):
		status_message = "Teleport destination must be empty."
		_build_board()
		return false
	if spell_barrier_active and (target_square == spell_barrier_square or spell_teleport_source_square == spell_barrier_square):
		status_message = "Barrier blocks movement through that square this turn."
		_build_board()
		return false

	var moving_piece: Dictionary = pieces.get(spell_teleport_source_square, {})
	if moving_piece.is_empty() or str(moving_piece.get("color", "")) != current_turn:
		spell_teleport_source_square = INVALID_SQUARE
		status_message = "Teleport source is no longer valid."
		_build_board()
		return false

	var simulated_board = pieces.duplicate(true)
	simulated_board.erase(spell_teleport_source_square)
	var simulated_piece = moving_piece.duplicate(true)
	simulated_piece["has_moved"] = true
	simulated_board[target_square] = simulated_piece
	if _is_king_in_check(current_turn, simulated_board):
		status_message = "Teleport cannot leave your king in check."
		_build_board()
		return false

	undo_snapshots.append(_capture_undo_snapshot())
	if not _consume_spell_card_from_hand(current_turn, "teleport"):
		undo_snapshots.pop_back()
		status_message = "Teleport is no longer in hand."
		_build_board()
		return false

	pieces.erase(spell_teleport_source_square)
	var moved_piece = moving_piece.duplicate(true)
	moved_piece["has_moved"] = true
	pieces[target_square] = moved_piece
	if spell_fortify_active and spell_fortify_owner == current_turn and spell_fortify_piece_square == spell_teleport_source_square:
		spell_fortify_piece_square = target_square
	spell_cast_this_turn = true
	status_message = "%s casts Teleport to %s." % [_display_color(current_turn), _square_to_notation(target_square)]
	_record_spell_cast_in_history(current_turn, "teleport", "%s %s -> %s" % [_get_piece_symbol(str(moved_piece.get("piece_id", ""))), _square_to_notation(spell_teleport_source_square), _square_to_notation(target_square)])
	_pending_spell_cleanup()
	return true

func _cast_barrier_on_square(target_square: Vector2i) -> bool:
	if target_square.x < 0 or target_square.y < 0 or target_square.x >= board_width or target_square.y >= board_height:
		status_message = "Barrier target is outside the board."
		_build_board()
		return false
	undo_snapshots.append(_capture_undo_snapshot())
	if not _consume_spell_card_from_hand(current_turn, "barrier"):
		undo_snapshots.pop_back()
		status_message = "Barrier is no longer in hand."
		_build_board()
		return false
	spell_barrier_active = true
	spell_barrier_owner = current_turn
	spell_barrier_square = target_square
	spell_cast_this_turn = true
	status_message = "%s casts Barrier on %s." % [_display_color(current_turn), _square_to_notation(target_square)]
	_record_spell_cast_in_history(current_turn, "barrier", "on %s" % _square_to_notation(target_square))
	_pending_spell_cleanup()
	_publish_turn_state_to_peer()
	return true

func _consume_spell_card_from_hand(owner: String, card_id: String) -> bool:
	var hand: Array = spell_card_hands.get(owner, [])
	var index = hand.find(card_id)
	if index == -1:
		return false
	hand.remove_at(index)
	spell_card_hands[owner] = hand
	if spell_cards_random and spell_draw_replacement_after_cast:
		_spell_fill_hand_randomly(owner, _spell_hand_size_for_owner(owner))
	return true

func _pending_spell_cleanup() -> void:
	pending_spell_card_id = ""
	pending_spell_card_owner = ""
	selected_spell_card_id = ""
	selected_spell_card_owner = ""
	spell_teleport_source_square = INVALID_SQUARE

func _record_spell_cast_in_history(owner: String, card_id: String, detail: String = "") -> void:
	var card_name = _spell_card_name(card_id)
	var detail_text = ""
	if detail != "":
		detail_text = " %s" % detail
	move_history.append("%s | casts %s%s" % [_display_color(owner), card_name, detail_text])

func _draw_drop_pool_panel(panel_position: Vector2, panel_size: Vector2, title: String, owner: String) -> void:
	var background = ColorRect.new()
	background.position = panel_position
	background.size = panel_size
	background.color = _drop_pool_panel_color(owner, drop_pool_hover_owner == owner)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	add_child(_create_colored_border(panel_position, panel_size, DROP_POOL_PANEL_BORDER))

	var title_label = Label.new()
	title_label.position = panel_position + Vector2(TURN_INDICATOR_PADDING, TURN_INDICATOR_PADDING - 2.0)
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", _hud_font_size(0.18, 12, 18))
	title_label.add_theme_color_override("font_color", Color(0.95, 0.97, 1.0, 1.0))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_label)

	var entry_rects: Array = []
	var row_height = max(tile_size * 0.30, 18.0)
	var content_x = panel_position.x + TURN_INDICATOR_PADDING
	var content_width = panel_size.x - TURN_INDICATOR_PADDING * 2.0
	var current_y = panel_position.y + TURN_INDICATOR_PADDING + 22.0
	var helper_height = row_height if owner == current_turn else 0.0
	var body_height = max(panel_size.y - (TURN_INDICATOR_PADDING + 28.0 + helper_height), row_height)
	var entries = _get_drop_pool_display_entries(owner)
	drop_pool_viewport_rects[owner] = Rect2(content_x, current_y, content_width, body_height)

	if entries.is_empty():
		drop_pool_scroll_offsets[owner] = 0
		var empty_label = Label.new()
		empty_label.position = Vector2(content_x, current_y)
		empty_label.size = Vector2(content_width, body_height)
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.text = "(empty)"
		if owner == current_turn:
			empty_label.text = "(empty)\nDrag from this pool to board"
		empty_label.add_theme_font_size_override("font_size", _hud_font_size(0.15, 11, 14))
		empty_label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0, 1.0))
		empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(empty_label)
		drop_pool_entry_rects[owner] = entry_rects
		return

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(content_x, current_y)
	scroll.size = Vector2(content_width, body_height)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scroll)

	var rows = VBoxContainer.new()
	rows.custom_minimum_size = Vector2(content_width, 0.0)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 4)
	scroll.add_child(rows)

	var total_rows_height = entries.size() * row_height + max(entries.size() - 1, 0) * 4
	rows.custom_minimum_size = Vector2(content_width, max(body_height, total_rows_height))

	var y_offset = 0.0
	for entry in entries:
		var piece_id = str(entry.get("piece_id", ""))
		var count = int(entry.get("count", 0))
		var row_rect = Rect2(Vector2(0.0, y_offset), Vector2(content_width, row_height))
		var selected = owner == selected_drop_piece_owner and piece_id == selected_drop_piece_id

		var row_label = Label.new()
		row_label.custom_minimum_size = Vector2(content_width, row_height)
		row_label.text = "%s%s x%d" % ["> " if selected else "", _get_piece_symbol(piece_id), count]
		row_label.add_theme_font_size_override("font_size", _hud_font_size(0.15, 11, 14))
		row_label.add_theme_color_override("font_color", Color(0.99, 0.99, 1.0, 1.0) if selected else Color(0.94, 0.96, 1.0, 1.0))
		row_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rows.add_child(row_label)

		entry_rects.append({
			"piece_id": piece_id,
			"rect": row_rect
		})
		y_offset += row_height + 4.0

	var saved_scroll = int(drop_pool_scroll_offsets.get(owner, 0))
	var max_scroll = max(int(ceil(total_rows_height - body_height)), 0)
	scroll.scroll_vertical = clamp(saved_scroll, 0, max_scroll)
	drop_pool_scroll_offsets[owner] = scroll.scroll_vertical

	if owner == current_turn:
		var helper_label = Label.new()
		helper_label.position = Vector2(content_x, panel_position.y + panel_size.y - row_height - 2.0)
		helper_label.size = Vector2(content_width, row_height)
		helper_label.text = "Drag from pool to board"
		helper_label.add_theme_font_size_override("font_size", _hud_font_size(0.12, 10, 12))
		helper_label.add_theme_color_override("font_color", Color(0.8, 0.85, 0.94, 1.0))
		helper_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(helper_label)

	drop_pool_entry_rects[owner] = entry_rects

func _create_colored_border(position: Vector2, size: Vector2, border_color: Color) -> Line2D:
	var border = Line2D.new()
	border.width = 2.0
	border.default_color = border_color
	border.closed = true
	border.position = position
	border.points = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(size.x, 0.0),
		Vector2(size.x, size.y),
		Vector2(0.0, size.y)
	])
	return border

func _get_drop_pool_display_entries(owner: String) -> Array[Dictionary]:
	var pool_contents: Array = drop_pools.get(owner, [])
	var count_by_piece = {}
	for piece_id in pool_contents:
		var key = str(piece_id)
		count_by_piece[key] = int(count_by_piece.get(key, 0)) + 1

	var keys = count_by_piece.keys()
	keys.sort()
	var entries: Array[Dictionary] = []
	for key in keys:
		entries.append({
			"piece_id": str(key),
			"count": int(count_by_piece[key])
		})
	return entries

func _get_legal_drop_squares(piece_id: String, owner: String) -> Array[Vector2i]:
	var valid_squares: Array[Vector2i] = []
	for y in board_height:
		for x in board_width:
			var square = Vector2i(x, y)
			if _is_legal_drop_piece_from_pool(piece_id, owner, square):
				valid_squares.append(square)
	return valid_squares

func _draw_move_history_panel() -> void:
	var history_lines: Array[String] = []
	if move_history.is_empty():
		history_lines.append("No moves yet")
	else:
		for index in range(move_history.size()):
			history_lines.append("%d. %s" % [index + 1, move_history[index]])

	var viewport_size = get_viewport_rect().size
	var panel_width = clampf(max(tile_size * 2.8, 180.0), 180.0, max(210.0, min(viewport_size.x * 0.36, 320.0)))
	var panel_height = clampf(max(tile_size * 3.2, 180.0), 170.0, max(210.0, min(viewport_size.y * 0.56, 420.0)))
	if _is_tiny_board():
		panel_width = clampf(panel_width, 168.0, min(viewport_size.x * 0.30, 240.0))
		panel_height = clampf(panel_height, 132.0, min(viewport_size.y * 0.42, 260.0))
	var panel_position = Vector2(
		viewport_size.x - panel_width - TURN_INDICATOR_PADDING,
		TURN_INDICATOR_PADDING
	)

	var panel_size = Vector2(panel_width, panel_height)
	var background = ColorRect.new()
	background.position = panel_position
	background.size = panel_size
	background.color = TURN_INDICATOR_BACKGROUND
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	add_child(_create_indicator_border(panel_position, panel_size))

	var title_label = Label.new()
	title_label.position = panel_position + Vector2(TURN_INDICATOR_PADDING, TURN_INDICATOR_PADDING - 2.0)
	title_label.size = Vector2(panel_size.x - TURN_INDICATOR_PADDING * 2.0, 20.0)
	title_label.text = "Move History"
	title_label.add_theme_font_size_override("font_size", _hud_font_size(0.17, 12, 16))
	title_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_label)

	var scroll = ScrollContainer.new()
	scroll.position = panel_position + Vector2(TURN_INDICATOR_PADDING, TURN_INDICATOR_PADDING + 20.0)
	scroll.size = panel_size - Vector2(TURN_INDICATOR_PADDING * 2.0, TURN_INDICATOR_PADDING * 2.0 + 22.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	add_child(scroll)

	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 2)
	scroll.add_child(content)

	for index in range(history_lines.size()):
		var line = history_lines[index]
		var owner = _history_entry_owner(index, line)
		var row_background = _player_color(owner)
		row_background.a = 0.88
		var row_border = _high_contrast_text_color(row_background)
		row_border.a = 0.9

		var row_panel = PanelContainer.new()
		row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var row_style = StyleBoxFlat.new()
		row_style.bg_color = row_background
		row_style.set_corner_radius_all(4)
		if row_border.a > 0.0:
			row_style.border_width_left = 1
			row_style.border_width_top = 1
			row_style.border_width_right = 1
			row_style.border_width_bottom = 1
			row_style.border_color = row_border
		row_panel.add_theme_stylebox_override("panel", row_style)
		content.add_child(row_panel)

		var line_label = Label.new()
		line_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line_label.text = line
		line_label.add_theme_font_size_override("font_size", _hud_font_size(0.14, 10, 14))
		line_label.add_theme_color_override("font_color", _high_contrast_text_color(row_background))
		line_label.add_theme_constant_override("outline_size", 0)
		row_panel.add_child(line_label)

	_draw_export_move_history_button(panel_position, panel_size)

func _draw_export_move_history_button(history_panel_position: Vector2, history_panel_size: Vector2) -> void:
	var viewport_size = get_viewport_rect().size
	var button_height = clampf(tile_size * 0.5, 28.0, 38.0)
	var button_width = clampf(history_panel_size.x * 0.86, 140.0, history_panel_size.x)
	var button = Button.new()
	button.text = "Export Move History"
	button.size = Vector2(button_width, button_height)
	button.position = Vector2(
		history_panel_position.x + history_panel_size.x - button_width,
		min(
			history_panel_position.y + history_panel_size.y + 8.0,
			viewport_size.y - button_height - TURN_INDICATOR_PADDING
		)
	)
	button.pressed.connect(_on_export_move_history_pressed)
	add_child(button)

func _on_export_move_history_pressed() -> void:
	_ensure_export_file_dialog()
	if export_file_dialog == null:
		_show_export_feedback("Export failed: could not open file picker.")
		return
	var timestamp = Time.get_datetime_string_from_system(false).replace(":", "-").replace(" ", "_")
	export_file_dialog.current_file = "move_history_%s.txt" % timestamp
	export_file_dialog.popup_centered_ratio(0.75)

func _on_export_move_history_file_selected(path: String) -> void:
	var selected_path = path.strip_edges()
	if selected_path == "":
		_show_export_feedback("Export failed: no file path selected.")
		return
	if selected_path.get_extension().to_lower() != "txt":
		selected_path += ".txt"

	var export_file = FileAccess.open(selected_path, FileAccess.WRITE)
	if export_file == null:
		_show_export_feedback("Export failed: could not write %s" % selected_path)
		return

	export_file.store_line("Chesslike Move History")
	export_file.store_line("Exported: %s" % Time.get_datetime_string_from_system())
	export_file.store_line("")
	if move_history.is_empty():
		export_file.store_line("No moves yet")
		_show_export_feedback("Move history exported to: %s" % selected_path)
		return
	for index in range(move_history.size()):
		export_file.store_line("%d. %s" % [index + 1, move_history[index]])
	_show_export_feedback("Move history exported to: %s" % selected_path)

func _show_export_feedback(message: String) -> void:
	_ensure_export_feedback_popup()
	if export_feedback_popup == null:
		push_warning(message)
		return
	export_feedback_serial += 1
	var serial = export_feedback_serial
	export_feedback_popup.title = "Export Failed" if message.begins_with("Export failed") else "Move History Export"
	export_feedback_popup.dialog_text = message
	export_feedback_popup.popup_centered(Vector2i(620, 130))
	_hide_export_feedback_after_delay(serial)

func _hide_export_feedback_after_delay(serial: int) -> void:
	await get_tree().create_timer(5.0).timeout
	if serial != export_feedback_serial:
		return
	if export_feedback_popup != null and export_feedback_popup.visible:
		export_feedback_popup.hide()

func _ensure_export_feedback_popup() -> void:
	if export_feedback_popup != null:
		return
	if promotion_picker_layer == null:
		_ensure_promotion_picker()
	if promotion_picker_layer == null:
		return
	export_feedback_popup = AcceptDialog.new()
	export_feedback_popup.dialog_text = ""
	export_feedback_popup.exclusive = false
	var ok_button = export_feedback_popup.get_ok_button()
	if ok_button != null:
		ok_button.text = "OK"
	promotion_picker_layer.add_child(export_feedback_popup)

func _ensure_export_file_dialog() -> void:
	if export_file_dialog != null:
		return
	if promotion_picker_layer == null:
		_ensure_promotion_picker()
	if promotion_picker_layer == null:
		return
	export_file_dialog = FileDialog.new()
	export_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	export_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	export_file_dialog.title = "Export Move History"
	export_file_dialog.filters = PackedStringArray(["*.txt ; Text Files"])
	var user_dir = DirAccess.open("user://")
	if user_dir != null:
		user_dir.make_dir_recursive("exports")
	var default_export_dir = ProjectSettings.globalize_path("user://exports")
	export_file_dialog.current_dir = default_export_dir
	export_file_dialog.file_selected.connect(_on_export_move_history_file_selected)
	promotion_picker_layer.add_child(export_file_dialog)

func _history_entry_owner(entry_index: int, entry_line: String) -> String:
	var lower_line = entry_line.to_lower()
	var mover_segment = lower_line
	var delimiter_index = lower_line.find("|")
	if delimiter_index != -1:
		mover_segment = lower_line.substr(0, delimiter_index)
	if mover_segment.find("player 1") != -1:
		return "white"
	if mover_segment.find("player 2") != -1:
		return "black"
	if lower_line == "no moves yet":
		return "white"
	return "white" if entry_index % 2 == 0 else "black"

func _debug_validate_history_entry_owner_parsing() -> void:
	var fixtures = [
		{"line": "Player 1 | P e2 -> e4", "expected": "white"},
		{"line": "Player 2 | N g8 -> f6", "expected": "black"},
		{"line": "Player 1 | B c4 x f7 (Player 2 P)", "expected": "white"},
		{"line": "Player 2 | Q h4 x e1 (Player 1 K)", "expected": "black"},
		{"line": "No moves yet", "expected": "white"}
	]
	for fixture in fixtures:
		var line = str(fixture.get("line", ""))
		var expected = str(fixture.get("expected", "white"))
		var actual = _history_entry_owner(0, line)
		if actual != expected:
			push_warning("History owner parse regression for line '%s': expected %s, got %s" % [line, expected, actual])

func _high_contrast_text_color(background: Color) -> Color:
	if _color_luma(background) < 0.5:
		return Color(1.0, 1.0, 1.0, 1.0)
	return Color(0.0, 0.0, 0.0, 1.0)

func _draw_game_over_banner() -> void:
	if not game_over or status_message == "":
		return
	var viewport_size = get_viewport_rect().size
	var banner_width = clampf(viewport_size.x * 0.72, 280.0, 760.0)
	var banner_height = clampf(viewport_size.y * 0.18, 90.0, 180.0)
	var banner_position = Vector2((viewport_size.x - banner_width) * 0.5, (viewport_size.y - banner_height) * 0.5)

	var background = ColorRect.new()
	background.position = banner_position
	background.size = Vector2(banner_width, banner_height)
	background.color = Color(0.05, 0.05, 0.05, 0.9)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	add_child(_create_colored_border(banner_position, Vector2(banner_width, banner_height), Color(1.0, 0.94, 0.72, 1.0)))

	var result_label = Label.new()
	result_label.position = banner_position + Vector2(16.0, 12.0)
	result_label.size = Vector2(banner_width - 32.0, banner_height - 24.0)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.text = status_message
	result_label.add_theme_font_size_override("font_size", int(clampf(banner_height * 0.34, 22.0, 46.0)))
	result_label.add_theme_color_override("font_color", Color(1.0, 0.98, 0.9, 1.0))
	result_label.add_theme_constant_override("outline_size", 2)
	result_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	result_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(result_label)

func _draw_hud_panel(panel_position: Vector2, panel_size: Vector2, title: String, lines: Array) -> void:
	var background = ColorRect.new()
	background.position = panel_position
	background.size = panel_size
	background.color = TURN_INDICATOR_BACKGROUND
	add_child(background)

	add_child(_create_indicator_border(panel_position, panel_size))

	var title_label = Label.new()
	title_label.position = panel_position + Vector2(TURN_INDICATOR_PADDING, TURN_INDICATOR_PADDING - 2.0)
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", _hud_font_size(0.17, 12, 16))
	title_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	add_child(title_label)

	var body_label = Label.new()
	body_label.position = panel_position + Vector2(TURN_INDICATOR_PADDING, TURN_INDICATOR_PADDING + 22.0)
	body_label.size = panel_size - Vector2(TURN_INDICATOR_PADDING * 2.0, TURN_INDICATOR_PADDING * 2.0 + 18.0)
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.text = "\n".join(lines)
	body_label.add_theme_font_size_override("font_size", _hud_font_size(0.14, 10, 14))
	body_label.add_theme_color_override("font_color", Color(0.14, 0.14, 0.14))
	add_child(body_label)

func _is_tiny_board() -> bool:
	return tile_size < 42.0

func _hud_font_size(ratio: float, min_size: int, max_size: int) -> int:
	return int(clampf(tile_size * ratio, float(min_size), float(max_size)))

func _get_hud_panel_size(width_tiles: float, height_tiles: float, min_width: float, min_height: float) -> Vector2:
	var viewport_size = get_viewport_rect().size
	var width_ratio = 0.26 if _is_tiny_board() else 0.32
	var height_ratio = 0.24 if _is_tiny_board() else 0.30
	var width_cap = 220.0 if _is_tiny_board() else 300.0
	var height_cap = 150.0 if _is_tiny_board() else 190.0
	var max_width = max(min_width, min(viewport_size.x * width_ratio, width_cap))
	var max_height = max(min_height, min(viewport_size.y * height_ratio, height_cap))
	return Vector2(
		clampf(tile_size * width_tiles, min_width, max_width),
		clampf(tile_size * height_tiles, min_height, max_height)
	)

func _hud_side_reserve_width(viewport_size: Vector2) -> float:
	if board_width > 4 and board_height > 4:
		return viewport_size.x * 0.05
	var base_reserve = 188.0 if piece_dropping_enabled else 176.0
	return clampf(max(base_reserve, viewport_size.x * 0.18), 160.0, 240.0)

func _hud_top_reserve_height(viewport_size: Vector2) -> float:
	var baseline_reserve = viewport_size.y * BOARD_MARGIN_RATIO
	if board_width <= 4 or board_height <= 4:
		baseline_reserve = clampf(max(74.0, viewport_size.y * 0.12), 68.0, 130.0)
	var banner_reserve = clampf(max(88.0, viewport_size.y * 0.12), 88.0, 150.0)
	banner_reserve = max(banner_reserve, clampf(max(132.0, viewport_size.y * 0.18), 132.0, 220.0))
	if allow_undo_enabled:
		banner_reserve = max(banner_reserve, clampf(max(172.0, viewport_size.y * 0.24), 172.0, 280.0))
	return max(baseline_reserve, banner_reserve)

func _hud_bottom_reserve_height(viewport_size: Vector2) -> float:
	if board_width > 4 and board_height > 4:
		return viewport_size.y * BOARD_MARGIN_RATIO
	var base_reserve = 170.0 if piece_dropping_enabled else 154.0
	return clampf(max(base_reserve, viewport_size.y * 0.22), 138.0, 220.0)

func _drop_pool_panel_color(owner: String, hovered: bool) -> Color:
	var base_color = _player_color(owner)
	var bright = 0.26 if hovered else 0.20
	return Color(
		clampf(base_color.r * 0.55 + bright, 0.0, 1.0),
		clampf(base_color.g * 0.55 + bright, 0.0, 1.0),
		clampf(base_color.b * 0.55 + bright, 0.0, 1.0),
		0.96 if hovered else 0.92
	)

func _create_indicator_border(position: Vector2, size: Vector2) -> Line2D:
	var border = Line2D.new()
	border.width = 2.0
	border.default_color = TURN_INDICATOR_BORDER
	border.closed = true
	border.position = position
	border.points = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(size.x, 0.0),
		Vector2(size.x, size.y),
		Vector2(0.0, size.y)
	])
	return border

func _display_color(color: String) -> String:
	if color == "white":
		return "Player 1"
	if color == "black":
		return "Player 2"
	return color.capitalize()

func _turn_color_swatch(color: String) -> Color:
	return _player_color(color)

func _draw_highlights() -> void:
	for square in _get_pending_spell_target_squares():
		add_child(_create_square_overlay(square, SPELL_TARGET_HIGHLIGHT))

	for square in legal_drop_squares:
		add_child(_create_square_overlay(square, LEGAL_MOVE_HIGHLIGHT))

	if selected_square != INVALID_SQUARE:
		add_child(_create_square_overlay(selected_square, SELECTED_HIGHLIGHT))

	for square in legal_moves:
		if square != selected_square:
			add_child(_create_square_overlay(square, LEGAL_MOVE_HIGHLIGHT))

func _get_pending_spell_target_squares() -> Array[Vector2i]:
	var targets: Array[Vector2i] = []
	if pending_spell_card_id == "" or pending_spell_card_owner != current_turn:
		return targets

	var card_id = pending_spell_card_id
	if card_id == "barrier":
		for y in board_height:
			for x in board_width:
				targets.append(Vector2i(x, y))
		return targets
	if card_id == "teleport" and spell_teleport_source_square != INVALID_SQUARE:
		for y in board_height:
			for x in board_width:
				var square = Vector2i(x, y)
				if square == spell_teleport_source_square:
					continue
				if pieces.has(square):
					continue
				targets.append(square)
		return targets

	for square in pieces.keys():
		if not (square is Vector2i):
			continue
		var piece_data: Dictionary = pieces[square]
		match card_id:
			"haste":
				if str(piece_data.get("color", "")) == current_turn:
					targets.append(square)
			"fortify":
				if str(piece_data.get("color", "")) == current_turn:
					targets.append(square)
			"assassinate":
				if str(piece_data.get("color", "")) != current_turn and str(piece_data.get("piece_id", "")) != "king":
					targets.append(square)
			"teleport":
				if str(piece_data.get("color", "")) == current_turn:
					targets.append(square)
	return targets

func _is_board_view_flipped() -> bool:
	return online_mode and local_player_side == "black"

func _board_square_to_view_square(square: Vector2i) -> Vector2i:
	if not _is_board_view_flipped():
		return square
	return Vector2i(board_width - 1 - square.x, board_height - 1 - square.y)

func _view_square_to_board_square(square: Vector2i) -> Vector2i:
	# 180-degree rotation is its own inverse transform.
	return _board_square_to_view_square(square)

func _board_square_to_screen_position(square: Vector2i) -> Vector2:
	var view_square = _board_square_to_view_square(square)
	return board_origin + Vector2(view_square.x * tile_size, view_square.y * tile_size)

func _create_square_overlay(square: Vector2i, color: Color) -> Polygon2D:
	var overlay = Polygon2D.new()
	overlay.position = _board_square_to_screen_position(square)
	overlay.color = color
	overlay.polygon = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(tile_size, 0.0),
		Vector2(tile_size, tile_size),
		Vector2(0.0, tile_size)
	])
	return overlay

func _create_board_tile(square: Vector2i, tile_color: Color) -> Polygon2D:
	var tile = Polygon2D.new()
	tile.position = _board_square_to_screen_position(square)
	tile.color = tile_color
	tile.polygon = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(tile_size, 0.0),
		Vector2(tile_size, tile_size),
		Vector2(0.0, tile_size)
	])
	return tile

func _draw_pieces() -> void:
	for square in pieces.keys():
		var piece_data: Dictionary = pieces[square]
		var piece_node = _create_piece_node(piece_data)
		piece_node.position = _board_square_to_screen_position(square)
		add_child(piece_node)

func _draw_drop_piece_drag_preview() -> void:
	if not drop_piece_drag_active or selected_drop_piece_id == "":
		return
	var preview_piece = _create_piece_node({
		"piece_id": selected_drop_piece_id,
		"color": selected_drop_piece_owner
	})
	preview_piece.modulate = Color(1.0, 1.0, 1.0, 0.72)
	preview_piece.position = drop_piece_drag_position - Vector2(tile_size * 0.5, tile_size * 0.5)
	add_child(preview_piece)

func _create_piece_node(piece_data: Dictionary) -> Node2D:
	var piece_root = Node2D.new()
	var piece_id = str(piece_data.get("piece_id", ""))
	var path_strokes = $"/root/GameManager".get_piece_path_strokes(piece_id)
	if not path_strokes.is_empty():
		var icon_extent = max(tile_size * 0.68, 14.0)
		var icon_offset = (tile_size - icon_extent) * 0.5
		var stroke_width = icon_extent * $"/root/GameManager".get_piece_path_stroke_width(piece_id)
		_add_piece_path_visual(piece_root, path_strokes, Vector2(icon_offset, icon_offset), icon_extent, stroke_width, _piece_fill_color(piece_data.get("color", "white")), _piece_outline_color(piece_data.get("color", "white")))
		return piece_root

	var icon_texture = $"/root/GameManager".get_piece_icon_texture(piece_id)
	if icon_texture != null:
		var icon_extent = max(tile_size * 0.68, 14.0)
		var icon_offset = (tile_size - icon_extent) * 0.5
		var icon = TextureRect.new()
		icon.position = Vector2(icon_offset, icon_offset)
		icon.size = Vector2(icon_extent, icon_extent)
		icon.texture = icon_texture
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		piece_root.add_child(icon)
		return piece_root

	# Label placeholder for now; this wrapper node lets us replace it with an image sprite later.
	var label = Label.new()
	label.size = Vector2(tile_size, tile_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = _get_piece_symbol(piece_id)
	label.add_theme_font_size_override("font_size", int(tile_size * 0.55))
	label.add_theme_constant_override("outline_size", max(int(tile_size * 0.06), 2))
	label.add_theme_color_override("font_color", _piece_fill_color(piece_data.get("color", "white")))
	label.add_theme_color_override("font_outline_color", _piece_outline_color(piece_data.get("color", "white")))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece_root.add_child(label)

	return piece_root

func _add_piece_path_visual(parent: Node2D, path_strokes: Array, origin: Vector2, extent: float, stroke_width: float, fill_color: Color, outline_color: Color) -> void:
	for stroke_data in path_strokes:
		if not (stroke_data is Array):
			continue
		var points := PackedVector2Array()
		for point_data in stroke_data:
			if not (point_data is Dictionary):
				continue
			var px = clampf(float(point_data.get("x", 0.0)), 0.0, 1.0)
			var py = clampf(float(point_data.get("y", 0.0)), 0.0, 1.0)
			points.append(Vector2(origin.x + px * extent, origin.y + py * extent))
		if points.size() < 2:
			continue

		var outline_line = Line2D.new()
		outline_line.points = points
		outline_line.default_color = outline_color
		outline_line.width = stroke_width + max(2.0, stroke_width * 0.4)
		outline_line.joint_mode = Line2D.LINE_JOINT_ROUND
		outline_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		outline_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		parent.add_child(outline_line)

		var fill_line = Line2D.new()
		fill_line.points = points
		fill_line.default_color = fill_color
		fill_line.width = stroke_width
		fill_line.joint_mode = Line2D.LINE_JOINT_ROUND
		fill_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		fill_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		parent.add_child(fill_line)

func _piece_fill_color(piece_color: String) -> Color:
	return _player_color(piece_color)

func _piece_outline_color(piece_color: String) -> Color:
	var fill = _player_color(piece_color)
	return Color(0.08, 0.08, 0.08, 1.0) if _color_luma(fill) > 0.56 else Color(1.0, 1.0, 1.0, 1.0)

func _player_color(owner: String) -> Color:
	if owner == "black":
		return player_side_colors.get("black", DEFAULT_PLAYER2_COLOR)
	return player_side_colors.get("white", DEFAULT_PLAYER1_COLOR)

func _color_luma(color_value: Color) -> float:
	return color_value.r * 0.299 + color_value.g * 0.587 + color_value.b * 0.114

func _get_player_side_colors(serialized: Variant) -> Dictionary:
	var parsed = {
		"white": DEFAULT_PLAYER1_COLOR,
		"black": DEFAULT_PLAYER2_COLOR
	}
	if not (serialized is Dictionary):
		return parsed
	parsed["white"] = _color_from_variant(serialized.get("white", {}), DEFAULT_PLAYER1_COLOR)
	parsed["black"] = _color_from_variant(serialized.get("black", {}), DEFAULT_PLAYER2_COLOR)
	return parsed

func _get_board_tile_colors(serialized: Variant) -> Dictionary:
	var parsed = {
		"light": Color(1.0, 1.0, 1.0, 1.0),
		"dark": Color(0.41, 0.41, 0.41, 1.0)
	}
	if not (serialized is Dictionary):
		return parsed
	parsed["light"] = _color_from_variant(serialized.get("light", {}), parsed["light"])
	parsed["dark"] = _color_from_variant(serialized.get("dark", {}), parsed["dark"])
	return parsed

func _get_promotion_zone_rows(serialized: Variant) -> Dictionary:
	var parsed = {
		"white": 1,
		"black": 1
	}
	if not (serialized is Dictionary):
		return parsed
	parsed["white"] = max(int(serialized.get("white_rows", serialized.get("white", 1))), 1)
	parsed["black"] = max(int(serialized.get("black_rows", serialized.get("black", 1))), 1)
	return parsed

func _is_square_in_promotion_zone(piece_color: String, target_square: Vector2i) -> bool:
	if target_square == INVALID_SQUARE:
		return false
	var zone_rows = int(promotion_zone_rows.get(piece_color, 1))
	zone_rows = clamp(zone_rows, 1, max(board_height, 1))
	if piece_color == "white":
		return target_square.y < zone_rows
	return target_square.y >= board_height - zone_rows

func _color_from_variant(source: Variant, fallback: Color) -> Color:
	if source is Dictionary:
		return Color(
			float(source.get("r", fallback.r)),
			float(source.get("g", fallback.g)),
			float(source.get("b", fallback.b)),
			1.0
		)
	if source is Array and source.size() >= 3:
		return Color(float(source[0]), float(source[1]), float(source[2]), 1.0)
	return fallback

func _format_captured_piece_list(capturing_color: String) -> String:
	var piece_list: Array = captured_pieces.get(capturing_color, [])
	if piece_list.is_empty():
		return "-"

	var count_by_piece = {}
	for piece_data in piece_list:
		if piece_data is Dictionary:
			var piece_id = str(piece_data.get("piece_id", ""))
			count_by_piece[piece_id] = int(count_by_piece.get(piece_id, 0)) + 1

	var piece_ids = count_by_piece.keys()
	piece_ids.sort()
	var formatted_tags: Array[String] = []
	for piece_id in piece_ids:
		formatted_tags.append("%s x%d" % [_get_piece_symbol(piece_id), int(count_by_piece[piece_id])])
	return " | ".join(formatted_tags)

func _captured_piece_strength_total(capturing_color: String) -> int:
	var include_king = victory_condition == "total_war"
	var total = 0
	var piece_list: Array = captured_pieces.get(capturing_color, [])
	for piece_data in piece_list:
		if not (piece_data is Dictionary):
			continue
		total += int($"/root/GameManager".get_piece_strength(str(piece_data.get("piece_id", "")), include_king))
	return total

func _format_captured_strength_summary(capturing_color: String) -> String:
	var own_total = _captured_piece_strength_total(capturing_color)
	var enemy_total = _captured_piece_strength_total(_opponent_color(capturing_color))
	var diff = own_total - enemy_total
	return "%d (%+d)" % [own_total, diff]

func _square_to_notation(square: Vector2i) -> String:
	var file_name = "?"
	if square.x >= 0 and square.x < FILE_NAMES.length():
		file_name = FILE_NAMES.substr(square.x, 1)
	return "%s%s" % [file_name, board_height - square.y]

func _record_capture(capturing_color: String, captured_piece: Dictionary) -> void:
	var piece_list: Array = captured_pieces.get(capturing_color, [])
	piece_list.append(captured_piece.duplicate(true))
	captured_pieces[capturing_color] = piece_list

func _record_move(moving_piece: Dictionary, from_square: Vector2i, to_square: Vector2i, captured_piece: Dictionary, move_info: Dictionary) -> void:
	if bool(move_info.get("is_castling", false)):
		var castling_notation = "O-O"
		if to_square.x < from_square.x:
			castling_notation = "O-O-O"
		move_history.append("%s | %s" % [
			_display_color(str(moving_piece.get("color", "white"))),
			castling_notation
		])
		return

	var move_connector = " -> "
	var capture_suffix = ""
	if not captured_piece.is_empty():
		move_connector = " x "
		capture_suffix = " (%s %s)" % [
			_display_color(str(captured_piece.get("color", "white"))),
			_get_piece_symbol(str(captured_piece.get("piece_id", "")))
		]
	var promotion_suffix = ""
	if str(move_info.get("promotion_piece_id", "")) != "":
		promotion_suffix = "=%s" % _get_piece_symbol(str(move_info.get("promotion_piece_id", "")))
	var en_passant_suffix = ""
	if bool(move_info.get("is_en_passant", false)):
		en_passant_suffix = " e.p."

	move_history.append("%s | %s %s%s%s%s%s" % [
		_display_color(str(moving_piece.get("color", "white"))),
		_get_piece_symbol(str(moving_piece.get("piece_id", ""))),
		_square_to_notation(from_square),
		move_connector,
		_square_to_notation(to_square),
		promotion_suffix + capture_suffix,
		en_passant_suffix
	])

func _get_piece_definition(piece_id: String) -> Dictionary:
	var piece_definitions = $"/root/GameManager".PieceDefinitions
	if piece_definitions.has(piece_id):
		return piece_definitions[piece_id]
	return {}

func _get_piece_symbol(piece_id: String) -> String:
	var piece_definition = _get_piece_definition(piece_id)
	if not piece_definition.is_empty():
		return str(piece_definition.get("symbol", "?"))
	return "?"

func _handle_board_click(mouse_position: Vector2) -> void:
	if game_over:
		return
	if online_mode and not _is_local_turn():
		return

	var square = _screen_to_square(mouse_position)
	if square == INVALID_SQUARE:
		if pending_spell_card_id != "":
			status_message = "Select a valid target square for %s." % _spell_card_name(pending_spell_card_id)
			_build_board()
			return
		_clear_selection()
		_clear_drop_piece_selection()
		return

	if pending_spell_card_id != "":
		var pending_type = _spell_card_type(pending_spell_card_id)
		if _try_cast_pending_spell_at_square(square):
			if not spell_keep_selection_after_cast:
				_clear_selection()
			spell_keep_selection_after_cast = false
			_clear_drop_piece_selection()
			if pending_type == "power":
				_finalize_turn_after_move()
			else:
				_build_board()
		return

	if selected_square == INVALID_SQUARE:
		if spell_haste_active and square != spell_haste_piece_square:
			status_message = "Haste active: move the boosted piece at %s." % _square_to_notation(spell_haste_piece_square)
			_build_board()
			return
		if _is_current_turn_piece(square):
			_select_square(square)
		return

	if square == selected_square:
		_clear_selection()
		return

	if _is_square_in_legal_moves(square) and _try_move_piece(selected_square, square):
		_clear_drop_piece_selection()
		if last_piece_move_should_end_turn:
			_finalize_turn_after_move()
		else:
			_build_board()
		return

	if _is_current_turn_piece(square):
		_select_square(square)
	else:
		_clear_selection()

func _try_begin_drop_pool_drag(mouse_position: Vector2) -> bool:
	if not piece_dropping_enabled:
		return false
	if spell_haste_active and spell_haste_owner == current_turn and spell_haste_moves_remaining > 0:
		status_message = "Haste active: move the boosted piece before dropping."
		_build_board()
		return true
	if online_mode and not _is_local_turn():
		return true
	var owner = _drop_pool_side_at_position(mouse_position)
	if owner == "":
		return false

	if owner != current_turn:
		return true
	var selected_entry = _get_drop_pool_entry_at_position(owner, mouse_position)
	if selected_entry.is_empty():
		return true
	selected_drop_piece_owner = owner
	selected_drop_piece_id = str(selected_entry.get("piece_id", ""))
	legal_drop_squares = _get_legal_drop_squares(selected_drop_piece_id, owner)
	drop_piece_drag_active = true
	drop_piece_drag_position = mouse_position
	drop_pool_hover_owner = owner
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	_build_board()
	return true

func _drop_pool_side_at_position(mouse_position: Vector2) -> String:
	if white_drop_pool_panel_rect.has_point(mouse_position):
		return "white"
	if black_drop_pool_panel_rect.has_point(mouse_position):
		return "black"
	return ""

func _get_drop_pool_entry_at_position(owner: String, mouse_position: Vector2) -> Dictionary:
	var viewport_rect: Rect2 = drop_pool_viewport_rects.get(owner, Rect2())
	if not viewport_rect.has_point(mouse_position):
		return {}
	var local_position = Vector2(
		mouse_position.x - viewport_rect.position.x,
		mouse_position.y - viewport_rect.position.y + int(drop_pool_scroll_offsets.get(owner, 0))
	)
	var entries: Array = drop_pool_entry_rects.get(owner, [])
	for entry in entries:
		if entry is Dictionary and Rect2(entry.get("rect", Rect2())).has_point(local_position):
			return entry
	return {}

func _try_drop_piece_from_pool(target_square: Vector2i) -> bool:
	if not piece_dropping_enabled:
		return false
	if spell_haste_active and spell_haste_owner == current_turn and spell_haste_moves_remaining > 0:
		status_message = "Haste active: move the boosted piece before dropping."
		return false
	if selected_drop_piece_id == "" or selected_drop_piece_owner != current_turn:
		return false
	if not _is_legal_drop_piece_from_pool(selected_drop_piece_id, current_turn, target_square):
		return false

	var pool_contents: Array = drop_pools.get(current_turn, [])
	var remove_index = pool_contents.find(selected_drop_piece_id)
	if remove_index == -1:
		return false
	undo_snapshots.append(_capture_undo_snapshot())
	pool_contents.remove_at(remove_index)
	drop_pools[current_turn] = pool_contents
	_add_piece(target_square, selected_drop_piece_id, current_turn)
	move_history.append("%s | drops %s @ %s" % [
		_display_color(current_turn),
		_get_piece_symbol(selected_drop_piece_id),
		_square_to_notation(target_square)
	])
	_clear_drop_piece_selection()
	return true

func _is_legal_drop_piece_from_pool(piece_id: String, owner: String, target_square: Vector2i) -> bool:
	if target_square == INVALID_SQUARE:
		return false
	if spell_barrier_active and target_square == spell_barrier_square:
		return false
	if pieces.has(target_square):
		return false
	if owner == "" or piece_id == "":
		return false
	var simulated_board = pieces.duplicate(true)
	simulated_board[target_square] = {
		"piece_id": piece_id,
		"color": owner,
		"has_moved": false
	}
	if _is_king_in_check(owner, simulated_board):
		return false
	return _is_drop_allowed_by_army_strength(piece_id, owner, target_square, pieces, drop_pools)

func _clear_drop_piece_selection() -> void:
	selected_drop_piece_id = ""
	selected_drop_piece_owner = ""
	legal_drop_squares.clear()
	drop_piece_drag_active = false
	drop_pool_hover_owner = ""

func _select_square(square: Vector2i) -> void:
	selected_square = square
	legal_moves = _get_legal_moves(square)
	_build_board()

func _clear_selection() -> void:
	if selected_square == INVALID_SQUARE and legal_moves.is_empty():
		return
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	_build_board()

func _is_current_turn_piece(square: Vector2i) -> bool:
	if not pieces.has(square):
		return false
	var piece_data: Dictionary = pieces[square]
	return piece_data.get("color", "") == current_turn

func _is_square_in_legal_moves(square: Vector2i) -> bool:
	for legal_square in legal_moves:
		if legal_square == square:
			return true
	return false

func _get_legal_moves(from_square: Vector2i) -> Array[Vector2i]:
	var available_moves: Array[Vector2i] = []
	if not pieces.has(from_square):
		return available_moves

	var moving_piece: Dictionary = pieces[from_square]
	if moving_piece.get("color", "") != current_turn:
		return available_moves

	for y in board_height:
		for x in board_width:
			var to_square = Vector2i(x, y)
			var move_info = _analyze_move(moving_piece, from_square, to_square, pieces, true)
			if bool(move_info.get("is_legal", false)):
				available_moves.append(to_square)

	return available_moves

func _get_legal_moves_for_piece(from_square: Vector2i) -> Array[Vector2i]:
	var available_moves: Array[Vector2i] = []
	if not pieces.has(from_square):
		return available_moves

	var moving_piece: Dictionary = pieces[from_square]
	for y in board_height:
		for x in board_width:
			var to_square = Vector2i(x, y)
			var move_info = _analyze_move(moving_piece, from_square, to_square, pieces, true)
			if bool(move_info.get("is_legal", false)):
				available_moves.append(to_square)

	return available_moves

func _opponent_color(color: String) -> String:
	if color == "white":
		return "black"
	return "white"

func _screen_to_square(mouse_position: Vector2) -> Vector2i:
	if mouse_position.x < board_origin.x or mouse_position.y < board_origin.y:
		return Vector2i(-1, -1)

	var local_position = mouse_position - board_origin
	var square_x = int(floor(local_position.x / tile_size))
	var square_y = int(floor(local_position.y / tile_size))

	if square_x < 0 or square_y < 0 or square_x >= board_width or square_y >= board_height:
		return Vector2i(-1, -1)

	return _view_square_to_board_square(Vector2i(square_x, square_y))

func _finalize_turn_after_move() -> void:
	_pending_spell_cleanup()
	spell_cast_this_turn = false
	if spell_haste_active and spell_haste_owner == current_turn:
		spell_haste_active = false
		spell_haste_owner = ""
		spell_haste_piece_square = INVALID_SQUARE
		spell_haste_moves_remaining = 0
	if spell_barrier_active and spell_barrier_owner == current_turn:
		spell_barrier_active = false
		spell_barrier_owner = ""
		spell_barrier_square = INVALID_SQUARE
	last_piece_move_should_end_turn = true
	current_turn = _opponent_color(current_turn)
	if spell_fortify_active and current_turn == spell_fortify_owner:
		spell_fortify_active = false
		spell_fortify_owner = ""
		spell_fortify_piece_square = INVALID_SQUARE
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	legal_drop_squares.clear()
	_update_game_state(true)
	_build_board()
	_publish_turn_state_to_peer()

func _try_move_piece(from_square: Vector2i, to_square: Vector2i) -> bool:
	if promotion_pending:
		return false
	if not pieces.has(from_square):
		return false
	if spell_haste_active and spell_haste_owner == current_turn and spell_haste_moves_remaining > 0 and from_square != spell_haste_piece_square:
		status_message = "Haste active: move the boosted piece at %s." % _square_to_notation(spell_haste_piece_square)
		return false

	var moving_piece: Dictionary = pieces[from_square]
	var move_info = _analyze_move(moving_piece, from_square, to_square, pieces, true)
	if not bool(move_info.get("is_legal", false)):
		return false
	if bool(move_info.get("requires_promotion", false)) and promotion_enabled:
		promotion_pending = true
		pending_promotion_move = {
			"from": from_square,
			"to": to_square,
			"move_info": move_info.duplicate(true)
		}
		_show_promotion_picker(str(moving_piece.get("color", "white")))
		return false

	return _commit_move(from_square, to_square, moving_piece, move_info)

func _commit_move(from_square: Vector2i, to_square: Vector2i, moving_piece: Dictionary, move_info: Dictionary) -> bool:
	if not pieces.has(from_square):
		return false
	undo_snapshots.append(_capture_undo_snapshot())

	var captured_piece: Dictionary = {}
	var capture_square = move_info.get("capture_square", INVALID_SQUARE)
	if capture_square != INVALID_SQUARE and pieces.has(capture_square):
		captured_piece = pieces[capture_square].duplicate(true)
		pieces.erase(capture_square)

	pieces.erase(from_square)
	var moved_piece = moving_piece.duplicate(true)
	moved_piece["has_moved"] = true
	if str(move_info.get("promotion_piece_id", "")) != "":
		moved_piece["piece_id"] = str(move_info.get("promotion_piece_id", ""))
	pieces[to_square] = moved_piece

	if bool(move_info.get("is_castling", false)):
		var rook_from = move_info.get("rook_from", INVALID_SQUARE)
		var rook_to = move_info.get("rook_to", INVALID_SQUARE)
		if rook_from != INVALID_SQUARE and rook_to != INVALID_SQUARE and pieces.has(rook_from):
			var rook_piece: Dictionary = pieces[rook_from].duplicate(true)
			pieces.erase(rook_from)
			rook_piece["has_moved"] = true
			pieces[rook_to] = rook_piece

	en_passant_target_square = move_info.get("new_en_passant_target", INVALID_SQUARE)

	if not captured_piece.is_empty():
		if capture_to_drop_pool_enabled:
			_add_piece_to_drop_pool(str(moving_piece.get("color", "white")), str(captured_piece.get("piece_id", "")))
		else:
			_record_capture(str(moving_piece.get("color", "white")), captured_piece)
	if spell_fortify_active and spell_fortify_piece_square == from_square and spell_fortify_owner == str(moving_piece.get("color", "")):
		spell_fortify_piece_square = to_square
	if spell_fortify_active and not pieces.has(spell_fortify_piece_square):
		spell_fortify_active = false
		spell_fortify_owner = ""
		spell_fortify_piece_square = INVALID_SQUARE

	last_piece_move_should_end_turn = true
	if spell_haste_active and spell_haste_owner == str(moving_piece.get("color", "")) and spell_haste_piece_square == from_square and spell_haste_moves_remaining > 0:
		spell_haste_piece_square = to_square
		spell_haste_moves_remaining -= 1
		if spell_haste_moves_remaining > 0:
			last_piece_move_should_end_turn = false
		else:
			spell_haste_active = false
			spell_haste_owner = ""
			spell_haste_piece_square = INVALID_SQUARE
			spell_haste_moves_remaining = 0

	_record_move(moving_piece, from_square, to_square, captured_piece, move_info)
	return true

func _add_piece_to_drop_pool(owner: String, piece_id: String) -> void:
	if piece_id == "":
		return
	var pool_contents: Array = drop_pools.get(owner, [])
	pool_contents.append(piece_id)
	drop_pools[owner] = pool_contents

func _is_legal_piece_move(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i) -> bool:
	return _is_legal_piece_move_on_board(piece_data, from_square, to_square, pieces)

func _is_legal_piece_move_on_board(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary) -> bool:
	var move_info = _analyze_move(piece_data, from_square, to_square, board_state, true)
	return bool(move_info.get("is_legal", false))

func _create_move_info() -> Dictionary:
	return {
		"is_legal": false,
		"capture_square": INVALID_SQUARE,
		"rook_from": INVALID_SQUARE,
		"rook_to": INVALID_SQUARE,
		"promotion_piece_id": "",
		"requires_promotion": false,
		"new_en_passant_target": INVALID_SQUARE,
		"is_en_passant": false,
		"is_castling": false
	}

func _analyze_move(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary, validate_king_safety: bool, drop_pool_state: Dictionary = {}) -> Dictionary:
	var move_info = _create_move_info()
	if not _is_base_legal_piece_move(piece_data, from_square, to_square, board_state, move_info):
		return move_info
	if spell_barrier_active and (from_square == spell_barrier_square or to_square == spell_barrier_square):
		return move_info
	var capture_square = move_info.get("capture_square", INVALID_SQUARE)
	if spell_fortify_active and capture_square == spell_fortify_piece_square and str(piece_data.get("color", "")) != spell_fortify_owner:
		return move_info

	if validate_king_safety:
		var simulated_board = _simulate_move_with_info(board_state, from_square, to_square, piece_data, move_info)
		if _is_king_in_check(str(piece_data.get("color", "white")), simulated_board):
			return move_info

	var effective_drop_pools = drop_pool_state
	if effective_drop_pools.is_empty():
		effective_drop_pools = drop_pools
	if not _is_move_allowed_by_army_strength(piece_data, from_square, to_square, board_state, move_info, effective_drop_pools):
		return move_info

	move_info["is_legal"] = true
	return move_info

func _is_base_legal_piece_move(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary, move_info: Dictionary) -> bool:
	if from_square == to_square:
		return false
	if board_state.has(to_square):
		var target_piece: Dictionary = board_state[to_square]
		if target_piece.get("color", "") == piece_data.get("color", ""):
			return false
		if target_piece.get("piece_id", "") == "king":
			return false
		move_info["capture_square"] = to_square

	var piece_definition = _get_piece_definition(str(piece_data.get("piece_id", "")))
	match piece_definition.get("move_type", ""):
		"pawn":
			return _is_pawn_move_legal(piece_data, from_square, to_square, board_state, move_info)
		"shogi_pawn":
			return _is_shogi_pawn_move_legal(piece_data, from_square, to_square, board_state)
		"lance_forward_slide":
			return _is_lance_move_legal(piece_data, from_square, to_square, board_state)
		"shogi_knight_jump":
			return _is_shogi_knight_move_legal(piece_data, from_square, to_square)
		"silver_general_step":
			return _is_silver_general_move_legal(piece_data, from_square, to_square)
		"gold_general_step":
			return _is_gold_general_move_legal(piece_data, from_square, to_square)
		"knight_jump":
			return _is_knight_move_legal(from_square, to_square)
		"diagonal_slide":
			return _is_bishop_move_legal(from_square, to_square, board_state)
		"cardinal_slide":
			return _is_rook_move_legal(from_square, to_square, board_state)
		"omni_slide":
			return _is_queen_move_legal(from_square, to_square, board_state)
		"king_step":
			if _is_king_move_legal(from_square, to_square):
				return true
			return _is_castling_move_legal(piece_data, from_square, to_square, board_state, move_info)
		"custom":
			var is_capture = move_info.get("capture_square", INVALID_SQUARE) != INVALID_SQUARE
			return _is_custom_move_legal(piece_data, from_square, to_square, board_state, is_capture, false)
		_:
			return false

func _simulate_move_with_info(board_state: Dictionary, from_square: Vector2i, to_square: Vector2i, piece_data: Dictionary, move_info: Dictionary) -> Dictionary:
	var simulated_board = board_state.duplicate(true)
	var moving_piece: Dictionary = piece_data.duplicate(true)
	var capture_square = move_info.get("capture_square", INVALID_SQUARE)
	if capture_square != INVALID_SQUARE:
		simulated_board.erase(capture_square)
	simulated_board.erase(from_square)
	moving_piece["has_moved"] = true
	if str(move_info.get("promotion_piece_id", "")) != "":
		moving_piece["piece_id"] = str(move_info.get("promotion_piece_id", ""))
	simulated_board[to_square] = moving_piece

	if bool(move_info.get("is_castling", false)):
		var rook_from = move_info.get("rook_from", INVALID_SQUARE)
		var rook_to = move_info.get("rook_to", INVALID_SQUARE)
		if rook_from != INVALID_SQUARE and rook_to != INVALID_SQUARE and simulated_board.has(rook_from):
			var rook_piece: Dictionary = simulated_board[rook_from].duplicate(true)
			simulated_board.erase(rook_from)
			rook_piece["has_moved"] = true
			simulated_board[rook_to] = rook_piece

	return simulated_board

func _is_king_in_check(piece_color: String, board_state: Dictionary) -> bool:
	var king_square = _find_king_square(piece_color, board_state)
	if king_square == INVALID_SQUARE:
		return false

	for from_square in board_state.keys():
		var piece_data: Dictionary = board_state[from_square]
		if piece_data.get("color", "") == piece_color:
			continue
		if _can_piece_attack_square(piece_data, from_square, king_square, board_state):
			return true

	return false

func _find_king_square(piece_color: String, board_state: Dictionary) -> Vector2i:
	for square in board_state.keys():
		var piece_data: Dictionary = board_state[square]
		if piece_data.get("color", "") == piece_color and piece_data.get("piece_id", "") == "king":
			return square
	return INVALID_SQUARE

func _can_piece_attack_square(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary) -> bool:
	var piece_definition = _get_piece_definition(str(piece_data.get("piece_id", "")))
	match piece_definition.get("move_type", ""):
		"pawn":
			return _is_pawn_attack_legal(piece_data, from_square, to_square)
		"shogi_pawn":
			return _is_shogi_pawn_attack_legal(piece_data, from_square, to_square)
		"lance_forward_slide":
			return _is_lance_move_legal(piece_data, from_square, to_square, board_state)
		"shogi_knight_jump":
			return _is_shogi_knight_move_legal(piece_data, from_square, to_square)
		"silver_general_step":
			return _is_silver_general_move_legal(piece_data, from_square, to_square)
		"gold_general_step":
			return _is_gold_general_move_legal(piece_data, from_square, to_square)
		"knight_jump":
			return _is_knight_move_legal(from_square, to_square)
		"diagonal_slide":
			return _is_bishop_move_legal(from_square, to_square, board_state)
		"cardinal_slide":
			return _is_rook_move_legal(from_square, to_square, board_state)
		"omni_slide":
			return _is_queen_move_legal(from_square, to_square, board_state)
		"king_step":
			return _is_king_move_legal(from_square, to_square)
		"custom":
			return _is_custom_move_legal(piece_data, from_square, to_square, board_state, true, true)
		_:
			return false

func _is_custom_move_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary, is_capture: bool, allow_virtual_capture_target: bool) -> bool:
	var piece_id = str(piece_data.get("piece_id", ""))
	var delta = to_square - from_square
	if delta == Vector2i.ZERO:
		return false
	var initial_move = not bool(piece_data.get("has_moved", false))

	for movement_rule in _get_custom_movement_rules(piece_id):
		if not _custom_rule_allows_context(movement_rule, is_capture, initial_move, allow_virtual_capture_target):
			continue

		var rule_kind = str(movement_rule.get("kind", CUSTOM_MOVE_KIND_JUMP))
		var rule_delta: Vector2i = movement_rule.get("offset", Vector2i.ZERO)
		if rule_kind == CUSTOM_MOVE_KIND_JUMP:
			if rule_delta == delta:
				return true
			continue

		if str(movement_rule.get("slide_scope", CUSTOM_SLIDE_SCOPE_INFINITE)) == CUSTOM_SLIDE_SCOPE_HALTING:
			if rule_delta != delta:
				continue
			var halt_step = _normalize_direction_vector(rule_delta)
			if halt_step == Vector2i.ZERO:
				continue
			var halt_steps = _count_slide_steps(rule_delta, halt_step)
			if halt_steps <= 0:
				continue
			if _is_custom_slide_path_clear(from_square, halt_step, halt_steps, board_state):
				return true
			continue

		var steps = _count_slide_steps(delta, rule_delta)
		if steps <= 0:
			continue
		if _is_custom_slide_path_clear(from_square, rule_delta, steps, board_state):
			return true

	return false

func _custom_rule_allows_context(rule: Dictionary, is_capture: bool, initial_move: bool, allow_virtual_capture_target: bool) -> bool:
	if bool(rule.get("initial_only", false)) and not initial_move:
		return false

	var capture_mode = _normalize_custom_capture_mode(rule.get("capture_mode", CUSTOM_CAPTURE_MODE_ANY))
	if capture_mode == CUSTOM_CAPTURE_MODE_CAPTURE_ONLY:
		return is_capture or allow_virtual_capture_target
	if capture_mode == CUSTOM_CAPTURE_MODE_NON_CAPTURE:
		return not is_capture
	return true

func _normalize_custom_capture_mode(value: Variant) -> String:
	var capture_mode = str(value).to_lower().strip_edges()
	if capture_mode == CUSTOM_CAPTURE_MODE_NON_CAPTURE:
		return CUSTOM_CAPTURE_MODE_NON_CAPTURE
	if capture_mode == CUSTOM_CAPTURE_MODE_CAPTURE_ONLY:
		return CUSTOM_CAPTURE_MODE_CAPTURE_ONLY
	return CUSTOM_CAPTURE_MODE_ANY

func _normalize_custom_slide_scope(value: Variant) -> String:
	var slide_scope = str(value).to_lower().strip_edges()
	if slide_scope == CUSTOM_SLIDE_SCOPE_HALTING:
		return CUSTOM_SLIDE_SCOPE_HALTING
	return CUSTOM_SLIDE_SCOPE_INFINITE

func _get_custom_movement_rules(piece_id: String) -> Array[Dictionary]:
	var movement_rules: Array[Dictionary] = []
	if not $"/root/GameManager".PieceDefinitions.has(piece_id):
		return movement_rules
	var piece_definition: Dictionary = $"/root/GameManager".PieceDefinitions[piece_id]

	var seen_keys = {}
	var raw_rules = piece_definition.get("movement_rules", [])
	if raw_rules is Array:
		for raw_rule in raw_rules:
			if not (raw_rule is Dictionary):
				continue
			var move_kind = str(raw_rule.get("kind", CUSTOM_MOVE_KIND_JUMP)).to_lower()
			if move_kind != CUSTOM_MOVE_KIND_SLIDE:
				move_kind = CUSTOM_MOVE_KIND_JUMP

			var delta = Vector2i(int(raw_rule.get("x", 0)), int(raw_rule.get("y", 0)))
			if delta == Vector2i.ZERO and raw_rule.has("offset"):
				delta = _parse_custom_rule_offset(raw_rule.get("offset"))
			if delta == Vector2i.ZERO:
				continue

			var slide_scope = _normalize_custom_slide_scope(raw_rule.get("slide_scope", CUSTOM_SLIDE_SCOPE_INFINITE))
			if move_kind == CUSTOM_MOVE_KIND_SLIDE and slide_scope == CUSTOM_SLIDE_SCOPE_INFINITE:
				delta = _normalize_direction_vector(delta)
				if delta == Vector2i.ZERO:
					continue
			if move_kind != CUSTOM_MOVE_KIND_SLIDE:
				slide_scope = CUSTOM_SLIDE_SCOPE_INFINITE

			var capture_mode = _normalize_custom_capture_mode(raw_rule.get("capture_mode", CUSTOM_CAPTURE_MODE_ANY))
			var initial_only = bool(raw_rule.get("initial_only", false))
			var rule_key = "%s|%d|%d|%s|%d|%s" % [move_kind, delta.x, delta.y, capture_mode, int(initial_only), slide_scope]
			if seen_keys.has(rule_key):
				continue
			seen_keys[rule_key] = true
			movement_rules.append({
				"kind": move_kind,
				"offset": delta,
				"capture_mode": capture_mode,
				"initial_only": initial_only,
				"slide_scope": slide_scope
			})

	if not movement_rules.is_empty():
		return movement_rules

	for jump_offset in _get_custom_offsets(piece_id, "jump_offsets"):
		var jump_key = "%s|%d|%d|%s|0" % [CUSTOM_MOVE_KIND_JUMP, jump_offset.x, jump_offset.y, CUSTOM_CAPTURE_MODE_ANY]
		if seen_keys.has(jump_key):
			continue
		seen_keys[jump_key] = true
		movement_rules.append({
			"kind": CUSTOM_MOVE_KIND_JUMP,
			"offset": jump_offset,
			"capture_mode": CUSTOM_CAPTURE_MODE_ANY,
			"initial_only": false
		})

	for slide_step in _get_custom_offsets(piece_id, "slide_directions"):
		var normalized_slide = _normalize_direction_vector(slide_step)
		if normalized_slide == Vector2i.ZERO:
			continue
		var slide_key = "%s|%d|%d|%s|0" % [CUSTOM_MOVE_KIND_SLIDE, normalized_slide.x, normalized_slide.y, CUSTOM_CAPTURE_MODE_ANY]
		if seen_keys.has(slide_key):
			continue
		seen_keys[slide_key] = true
		movement_rules.append({
			"kind": CUSTOM_MOVE_KIND_SLIDE,
			"offset": normalized_slide,
			"capture_mode": CUSTOM_CAPTURE_MODE_ANY,
			"initial_only": false,
			"slide_scope": CUSTOM_SLIDE_SCOPE_INFINITE
		})

	return movement_rules

func _parse_custom_rule_offset(value: Variant) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Dictionary:
		return Vector2i(int(value.get("x", 0)), int(value.get("y", 0)))
	if value is Array and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

func _normalize_direction_vector(delta: Vector2i) -> Vector2i:
	var gcd_value = _gcd(abs(delta.x), abs(delta.y))
	if gcd_value <= 0:
		return Vector2i.ZERO
	return Vector2i(int(delta.x / gcd_value), int(delta.y / gcd_value))

func _gcd(a: int, b: int) -> int:
	var x = abs(a)
	var y = abs(b)
	while y != 0:
		var remainder = x % y
		x = y
		y = remainder
	return max(x, 1)

func _get_custom_offsets(piece_id: String, property_name: String) -> Array[Vector2i]:
	var offsets: Array[Vector2i] = []
	if not $"/root/GameManager".PieceDefinitions.has(piece_id):
		return offsets
	var piece_definition: Dictionary = $"/root/GameManager".PieceDefinitions[piece_id]
	var values = piece_definition.get(property_name, [])
	if not (values is Array):
		return offsets

	for value in values:
		if not (value is Dictionary):
			continue
		var offset = Vector2i(int(value.get("x", 0)), int(value.get("y", 0)))
		if offset == Vector2i.ZERO:
			continue
		if offsets.has(offset):
			continue
		offsets.append(offset)
	return offsets

func _count_slide_steps(delta: Vector2i, slide_step: Vector2i) -> int:
	if slide_step == Vector2i.ZERO:
		return -1

	if slide_step.x == 0:
		if delta.x != 0 or delta.y % slide_step.y != 0:
			return -1
		var k = int(delta.y / slide_step.y)
		return k if k > 0 else -1

	if slide_step.y == 0:
		if delta.y != 0 or delta.x % slide_step.x != 0:
			return -1
		var k = int(delta.x / slide_step.x)
		return k if k > 0 else -1

	if delta.x % slide_step.x != 0 or delta.y % slide_step.y != 0:
		return -1
	var kx = int(delta.x / slide_step.x)
	var ky = int(delta.y / slide_step.y)
	if kx != ky or kx <= 0:
		return -1
	return kx

func _is_custom_slide_path_clear(from_square: Vector2i, slide_step: Vector2i, steps: int, board_state: Dictionary) -> bool:
	for step_index in range(1, steps):
		var intermediate_square = from_square + Vector2i(slide_step.x * step_index, slide_step.y * step_index)
		if board_state.has(intermediate_square):
			return false
	return true

func _is_square_attacked(square: Vector2i, defended_color: String, board_state: Dictionary) -> bool:
	for from_square in board_state.keys():
		var attacker_piece: Dictionary = board_state[from_square]
		if attacker_piece.get("color", "") == defended_color:
			continue
		if _can_piece_attack_square(attacker_piece, from_square, square, board_state):
			return true
	return false

func _has_any_legal_moves(piece_color: String) -> bool:
	for from_square in pieces.keys():
		var piece_data: Dictionary = pieces[from_square]
		if piece_data.get("color", "") != piece_color:
			continue
		for y in board_height:
			for x in board_width:
				var move_info = _analyze_move(piece_data, from_square, Vector2i(x, y), pieces, true, drop_pools)
				if bool(move_info.get("is_legal", false)):
					return true

	if piece_dropping_enabled:
		var pool_contents: Array = drop_pools.get(piece_color, [])
		if not pool_contents.is_empty():
			for piece_id in pool_contents:
				for y in board_height:
					for x in board_width:
						if _is_legal_drop_piece_from_pool(str(piece_id), piece_color, Vector2i(x, y)):
							return true
	return false

func _update_game_state(record_history: bool) -> void:
	if limit_army_strength_enabled and not _state_respects_army_strength(pieces, drop_pools):
		game_over = true
		status_message = "Army strength limit exceeded"
		if record_history:
			move_history.append("Army strength limit exceeded.")
		return

	if victory_condition == "total_war":
		var white_piece_count = _count_pieces_on_board("white")
		var black_piece_count = _count_pieces_on_board("black")
		status_message = ""
		game_over = false

		if white_piece_count == 0 and black_piece_count == 0:
			game_over = true
			status_message = "Draw - Total War"
			if record_history:
				move_history.append("Total War draw.")
			return

		if white_piece_count == 0:
			game_over = true
			status_message = "%s wins - Total War" % _display_color("black")
			if record_history:
				move_history.append("Total War. %s wins." % _display_color("black"))
			return

		if black_piece_count == 0:
			game_over = true
			status_message = "%s wins - Total War" % _display_color("white")
			if record_history:
				move_history.append("Total War. %s wins." % _display_color("white"))
			return

		if _is_total_war_dead_position():
			game_over = true
			status_message = "Draw - Total War Stalemate"
			if record_history:
				move_history.append("Total War stalemate.")
			return

	var in_check = _is_king_in_check(current_turn, pieces)
	var has_moves = _has_any_legal_moves(current_turn)
	status_message = ""
	game_over = false

	if in_check and not has_moves:
		game_over = true
		status_message = "%s wins - Checkmate" % _display_color(_opponent_color(current_turn))
		if record_history:
			move_history.append("Checkmate. %s wins." % _display_color(_opponent_color(current_turn)))
		return

	if not in_check and not has_moves:
		game_over = true
		status_message = "Draw - Stalemate"
		if record_history:
			move_history.append("Stalemate.")
		return

	if in_check:
		status_message = "%s in check" % _display_color(current_turn)

func _count_pieces_on_board(piece_color: String) -> int:
	var count = 0
	for square in pieces.keys():
		var piece_data: Dictionary = pieces[square]
		if piece_data.get("color", "") == piece_color:
			count += 1
	return count

func _has_any_legal_captures(piece_color: String) -> bool:
	for from_square in pieces.keys():
		var piece_data: Dictionary = pieces[from_square]
		if piece_data.get("color", "") != piece_color:
			continue
		for to_square in pieces.keys():
			var target_piece: Dictionary = pieces[to_square]
			if target_piece.get("color", "") == piece_color:
				continue
			var move_info = _analyze_move(piece_data, from_square, to_square, pieces, true)
			if bool(move_info.get("is_legal", false)) and move_info.get("capture_square", INVALID_SQUARE) != INVALID_SQUARE:
				return true
	return false

func _has_any_drop_pool_pieces() -> bool:
	for owner in ["white", "black"]:
		var pool_contents: Array = drop_pools.get(owner, [])
		if not pool_contents.is_empty():
			return true
	return false


func _is_total_war_dead_position() -> bool:
	if _is_opposite_color_bishop_dead_position():
		return true
	var state = {
		"board": pieces.duplicate(true),
		"turn": current_turn,
		"drop_pools": _duplicate_drop_pools(drop_pools),
		"en_passant_target": en_passant_target_square
	}
	var memo = {}
	var active = {}
	return not _can_reach_future_capture(state, memo, active)

func _is_opposite_color_bishop_dead_position() -> bool:
	if _has_any_drop_pool_pieces():
		return false
	var white_bishop_colors = {}
	var black_bishop_colors = {}
	for square in pieces.keys():
		var piece_data: Dictionary = pieces[square]
		if str(piece_data.get("piece_id", "")) != "bishop":
			return false
		var square_color = (square.x + square.y) % 2
		if piece_data.get("color", "") == "white":
			white_bishop_colors[square_color] = true
		elif piece_data.get("color", "") == "black":
			black_bishop_colors[square_color] = true

	if white_bishop_colors.is_empty() or black_bishop_colors.is_empty():
		return false
	for square_color in white_bishop_colors.keys():
		if black_bishop_colors.has(square_color):
			return false
	return true

func _can_reach_future_capture(state: Dictionary, memo: Dictionary, active: Dictionary) -> bool:
	var state_key = _build_total_war_state_key(state)
	if memo.has(state_key):
		return bool(memo[state_key])
	if active.has(state_key):
		return false

	active[state_key] = true
	var turn_color = str(state.get("turn", "white"))
	var board_state: Dictionary = state.get("board", {})
	var drop_pool_state: Dictionary = state.get("drop_pools", {})
	var en_passant_target: Vector2i = state.get("en_passant_target", INVALID_SQUARE)

	if _has_any_legal_captures_on_state(turn_color, board_state, en_passant_target, drop_pool_state):
		active.erase(state_key)
		memo[state_key] = true
		return true

	for next_state in _generate_non_capturing_total_war_successors(state):
		if _can_reach_future_capture(next_state, memo, active):
			active.erase(state_key)
			memo[state_key] = true
			return true

	active.erase(state_key)
	memo[state_key] = false
	return false

func _generate_non_capturing_total_war_successors(state: Dictionary) -> Array[Dictionary]:
	var successors: Array[Dictionary] = []
	var board_state: Dictionary = state.get("board", {})
	var turn_color = str(state.get("turn", "white"))
	var drop_pool_state: Dictionary = state.get("drop_pools", {})
	var en_passant_target: Vector2i = state.get("en_passant_target", INVALID_SQUARE)

	for from_square in board_state.keys():
		var piece_data: Dictionary = board_state[from_square]
		if piece_data.get("color", "") != turn_color:
			continue
		for y in board_height:
			for x in board_width:
				var to_square = Vector2i(x, y)
				var move_info = _analyze_move_on_state(piece_data, from_square, to_square, board_state, true, en_passant_target, drop_pool_state)
				if not bool(move_info.get("is_legal", false)):
					continue
				if move_info.get("capture_square", INVALID_SQUARE) != INVALID_SQUARE:
					continue
				for promotion_piece_id in _get_promotion_results_for_state(move_info):
					var next_move_info = move_info.duplicate(true)
					next_move_info["promotion_piece_id"] = promotion_piece_id
					var next_board = _simulate_move_with_info(board_state, from_square, to_square, piece_data, next_move_info)
					successors.append({
						"board": next_board,
						"turn": _opponent_color(turn_color),
						"drop_pools": _duplicate_drop_pools(drop_pool_state),
						"en_passant_target": next_move_info.get("new_en_passant_target", INVALID_SQUARE)
					})

	if piece_dropping_enabled:
		var seen_drop_piece_ids = {}
		var pool_contents: Array = drop_pool_state.get(turn_color, [])
		for piece_id in pool_contents:
			var piece_key = str(piece_id)
			if seen_drop_piece_ids.has(piece_key):
				continue
			seen_drop_piece_ids[piece_key] = true
			for y in board_height:
				for x in board_width:
					var target_square = Vector2i(x, y)
					if not _is_legal_drop_piece_on_state(piece_key, turn_color, target_square, board_state, drop_pool_state):
						continue
					var next_board = board_state.duplicate(true)
					next_board[target_square] = {
						"piece_id": piece_key,
						"color": turn_color,
						"has_moved": false
					}
					var next_drop_pools = _duplicate_drop_pools(drop_pool_state)
					var next_pool_contents: Array = next_drop_pools.get(turn_color, [])
					var remove_index = next_pool_contents.find(piece_key)
					if remove_index != -1:
						next_pool_contents.remove_at(remove_index)
						next_drop_pools[turn_color] = next_pool_contents
					successors.append({
						"board": next_board,
						"turn": _opponent_color(turn_color),
						"drop_pools": next_drop_pools,
						"en_passant_target": INVALID_SQUARE
					})

	return successors

func _has_any_legal_captures_on_state(piece_color: String, board_state: Dictionary, en_passant_target: Vector2i, drop_pool_state: Dictionary) -> bool:
	for from_square in board_state.keys():
		var piece_data: Dictionary = board_state[from_square]
		if piece_data.get("color", "") != piece_color:
			continue
		for to_square in board_state.keys():
			var target_piece: Dictionary = board_state[to_square]
			if target_piece.get("color", "") == piece_color:
				continue
			var move_info = _analyze_move_on_state(piece_data, from_square, to_square, board_state, true, en_passant_target, drop_pool_state)
			if bool(move_info.get("is_legal", false)) and move_info.get("capture_square", INVALID_SQUARE) != INVALID_SQUARE:
				return true
	return false

func _analyze_move_on_state(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary, validate_king_safety: bool, en_passant_target: Vector2i, drop_pool_state: Dictionary) -> Dictionary:
	var previous_en_passant_target = en_passant_target_square
	en_passant_target_square = en_passant_target
	var move_info = _analyze_move(piece_data, from_square, to_square, board_state, validate_king_safety, drop_pool_state)
	en_passant_target_square = previous_en_passant_target
	return move_info

func _is_legal_drop_piece_on_state(piece_id: String, owner: String, target_square: Vector2i, board_state: Dictionary, drop_pool_state: Dictionary) -> bool:
	if target_square == INVALID_SQUARE:
		return false
	if board_state.has(target_square):
		return false
	if owner == "" or piece_id == "":
		return false
	var simulated_board = board_state.duplicate(true)
	simulated_board[target_square] = {
		"piece_id": piece_id,
		"color": owner,
		"has_moved": false
	}
	if _is_king_in_check(owner, simulated_board):
		return false
	return _is_drop_allowed_by_army_strength(piece_id, owner, target_square, board_state, drop_pool_state)

func _get_promotion_results_for_state(move_info: Dictionary) -> Array[String]:
	if not bool(move_info.get("requires_promotion", false)) or not promotion_enabled:
		return [str(move_info.get("promotion_piece_id", ""))]
	var results = _get_promotion_piece_pool().duplicate()
	if results.is_empty():
		results.append("queen")
	return results

func _duplicate_drop_pools(source_drop_pools: Dictionary) -> Dictionary:
	return {
		"white": (source_drop_pools.get("white", []) as Array).duplicate(true),
		"black": (source_drop_pools.get("black", []) as Array).duplicate(true)
	}

func _piece_strength(piece_id: String) -> int:
	var include_king = victory_condition == "total_war"
	return int($"/root/GameManager".get_piece_strength(piece_id, include_king))

func _army_strength_for_owner_on_state(owner: String, board_state: Dictionary, drop_pool_state: Dictionary) -> int:
	var total = 0
	for square in board_state.keys():
		var piece_data: Dictionary = board_state[square]
		if str(piece_data.get("color", "")) != owner:
			continue
		total += _piece_strength(str(piece_data.get("piece_id", "")))
	var pool_contents: Array = drop_pool_state.get(owner, [])
	for piece_id in pool_contents:
		total += _piece_strength(str(piece_id))
	return total

func _state_respects_army_strength(board_state: Dictionary, drop_pool_state: Dictionary) -> bool:
	if not limit_army_strength_enabled:
		return true
	for owner in ["white", "black"]:
		if _army_strength_for_owner_on_state(owner, board_state, drop_pool_state) > _army_strength_cap_for_owner(owner):
			return false
	return true

func _army_strength_cap_for_owner(owner: String) -> int:
	if unbalanced_armies_enabled:
		if owner == "white":
			return army_strength_cap_white
		if owner == "black":
			return army_strength_cap_black
	return army_strength_cap

func _is_move_allowed_by_army_strength(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary, move_info: Dictionary, drop_pool_state: Dictionary) -> bool:
	if not limit_army_strength_enabled:
		return true
	var moving_color = str(piece_data.get("color", "white"))
	var next_board = _simulate_move_with_info(board_state, from_square, to_square, piece_data, move_info)
	var next_drop_pools = _duplicate_drop_pools(drop_pool_state)
	if capture_to_drop_pool_enabled:
		var capture_square = move_info.get("capture_square", INVALID_SQUARE)
		if capture_square != INVALID_SQUARE and board_state.has(capture_square):
			var captured_piece: Dictionary = board_state[capture_square]
			var pool_contents: Array = next_drop_pools.get(moving_color, [])
			pool_contents.append(str(captured_piece.get("piece_id", "")))
			next_drop_pools[moving_color] = pool_contents
	return _state_respects_army_strength(next_board, next_drop_pools)

func _is_drop_allowed_by_army_strength(piece_id: String, owner: String, target_square: Vector2i, board_state: Dictionary, drop_pool_state: Dictionary) -> bool:
	if not limit_army_strength_enabled:
		return true
	var next_board = board_state.duplicate(true)
	next_board[target_square] = {
		"piece_id": piece_id,
		"color": owner,
		"has_moved": false
	}
	var next_drop_pools = _duplicate_drop_pools(drop_pool_state)
	var pool_contents: Array = next_drop_pools.get(owner, [])
	var remove_index = pool_contents.find(piece_id)
	if remove_index != -1:
		pool_contents.remove_at(remove_index)
		next_drop_pools[owner] = pool_contents
	return _state_respects_army_strength(next_board, next_drop_pools)

func _build_total_war_state_key(state: Dictionary) -> String:
	var board_state: Dictionary = state.get("board", {})
	var board_entries: Array[String] = []
	var squares = board_state.keys()
	squares.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.x == b.x:
			return a.y < b.y
		return a.x < b.x
	)
	for square in squares:
		var piece_data: Dictionary = board_state[square]
		board_entries.append("%d,%d,%s,%s,%s" % [
			square.x,
			square.y,
			str(piece_data.get("piece_id", "")),
			str(piece_data.get("color", "")),
			str(bool(piece_data.get("has_moved", false)))
		])

	var drop_pool_state: Dictionary = state.get("drop_pools", {})
	var white_pool: Array = (drop_pool_state.get("white", []) as Array).duplicate(true)
	var black_pool: Array = (drop_pool_state.get("black", []) as Array).duplicate(true)
	white_pool.sort()
	black_pool.sort()
	var en_passant_target: Vector2i = state.get("en_passant_target", INVALID_SQUARE)
	return "%s|%s|%s|%s|%d,%d" % [
		str(state.get("turn", "white")),
		";".join(board_entries),
		",".join(PackedStringArray(white_pool)),
		",".join(PackedStringArray(black_pool)),
		en_passant_target.x,
		en_passant_target.y
	]

func _is_pawn_move_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary, move_info: Dictionary) -> bool:
	var direction = 1
	var start_rank = 1
	var piece_color = str(piece_data.get("color", "white"))
	if str(piece_data.get("color", "white")) == "white":
		direction = -1
		start_rank = board_height - 2

	var delta_x = to_square.x - from_square.x
	var delta_y = to_square.y - from_square.y
	var destination_occupied = board_state.has(to_square)

	if delta_x == 0:
		if delta_y == direction and not destination_occupied:
			if promotion_enabled and _is_square_in_promotion_zone(piece_color, to_square):
				move_info["requires_promotion"] = true
			return true
		if delta_y == direction * 2 and from_square.y == start_rank and not destination_occupied:
			var intermediate_square = Vector2i(from_square.x, from_square.y + direction)
			if not board_state.has(intermediate_square):
				if en_passant_enabled:
					move_info["new_en_passant_target"] = intermediate_square
				return true
			return false
		return false

	if abs(delta_x) == 1 and delta_y == direction:
		if destination_occupied:
			var target_piece: Dictionary = board_state[to_square]
			if target_piece.get("color", "") == piece_data.get("color", ""):
				return false
			if promotion_enabled and _is_square_in_promotion_zone(piece_color, to_square):
				move_info["requires_promotion"] = true
			return true

		if en_passant_enabled and to_square == en_passant_target_square:
			var capture_square = Vector2i(to_square.x, from_square.y)
			if board_state.has(capture_square):
				var target_pawn: Dictionary = board_state[capture_square]
				if target_pawn.get("piece_id", "") == "pawn" and target_pawn.get("color", "") != piece_data.get("color", ""):
					move_info["capture_square"] = capture_square
					move_info["is_en_passant"] = true
					if promotion_enabled and _is_square_in_promotion_zone(piece_color, to_square):
						move_info["requires_promotion"] = true
					return true

	return false

func _is_pawn_attack_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i) -> bool:
	var direction = 1
	if str(piece_data.get("color", "white")) == "white":
		direction = -1
	return abs(to_square.x - from_square.x) == 1 and to_square.y - from_square.y == direction

func _is_knight_move_legal(from_square: Vector2i, to_square: Vector2i) -> bool:
	var delta_x = abs(to_square.x - from_square.x)
	var delta_y = abs(to_square.y - from_square.y)
	return (delta_x == 2 and delta_y == 1) or (delta_x == 1 and delta_y == 2)

func _forward_direction(piece_color: String) -> int:
	if piece_color == "white":
		return -1
	return 1

func _is_shogi_pawn_move_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary) -> bool:
	var forward = _forward_direction(str(piece_data.get("color", "white")))
	if to_square.x != from_square.x:
		return false
	if to_square.y - from_square.y != forward:
		return false
	if board_state.has(to_square):
		var target_piece: Dictionary = board_state[to_square]
		if target_piece.get("color", "") == piece_data.get("color", ""):
			return false
	return true

func _is_shogi_pawn_attack_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i) -> bool:
	var forward = _forward_direction(str(piece_data.get("color", "white")))
	return to_square.x == from_square.x and to_square.y - from_square.y == forward

func _is_lance_move_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary) -> bool:
	if to_square.x != from_square.x:
		return false
	var forward = _forward_direction(str(piece_data.get("color", "white")))
	var delta_y = to_square.y - from_square.y
	if delta_y == 0 or signi(delta_y) != forward:
		return false
	return _is_path_clear(from_square, to_square, board_state)

func _is_shogi_knight_move_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i) -> bool:
	var forward = _forward_direction(str(piece_data.get("color", "white")))
	var delta_x = to_square.x - from_square.x
	var delta_y = to_square.y - from_square.y
	return abs(delta_x) == 1 and delta_y == forward * 2

func _is_silver_general_move_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i) -> bool:
	var forward = _forward_direction(str(piece_data.get("color", "white")))
	var delta_x = to_square.x - from_square.x
	var delta_y = to_square.y - from_square.y
	if abs(delta_x) > 1 or abs(delta_y) > 1:
		return false
	if delta_x == 0 and delta_y == forward:
		return true
	if abs(delta_x) == 1 and delta_y == forward:
		return true
	if abs(delta_x) == 1 and delta_y == -forward:
		return true
	return false

func _is_gold_general_move_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i) -> bool:
	var forward = _forward_direction(str(piece_data.get("color", "white")))
	var delta_x = to_square.x - from_square.x
	var delta_y = to_square.y - from_square.y
	if abs(delta_x) > 1 or abs(delta_y) > 1:
		return false
	if delta_x == 0 and abs(delta_y) == 1:
		return true
	if abs(delta_x) == 1 and delta_y == 0:
		return true
	if abs(delta_x) == 1 and delta_y == forward:
		return true
	return false

func _is_bishop_move_legal(from_square: Vector2i, to_square: Vector2i, board_state: Dictionary) -> bool:
	var delta_x = to_square.x - from_square.x
	var delta_y = to_square.y - from_square.y
	if abs(delta_x) != abs(delta_y):
		return false
	return _is_path_clear(from_square, to_square, board_state)

func _is_rook_move_legal(from_square: Vector2i, to_square: Vector2i, board_state: Dictionary) -> bool:
	if from_square.x != to_square.x and from_square.y != to_square.y:
		return false
	return _is_path_clear(from_square, to_square, board_state)


func _is_queen_move_legal(from_square: Vector2i, to_square: Vector2i, board_state: Dictionary) -> bool:
	return _is_rook_move_legal(from_square, to_square, board_state) or _is_bishop_move_legal(from_square, to_square, board_state)

func _is_king_move_legal(from_square: Vector2i, to_square: Vector2i) -> bool:
	var delta_x = abs(to_square.x - from_square.x)
	var delta_y = abs(to_square.y - from_square.y)
	return delta_x <= 1 and delta_y <= 1

func _is_castling_move_legal(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i, board_state: Dictionary, move_info: Dictionary) -> bool:
	if not castling_enabled:
		return false
	if bool(piece_data.get("has_moved", false)):
		return false
	if from_square.y != to_square.y:
		return false
	if abs(to_square.x - from_square.x) != 2:
		return false
	if board_state.has(to_square):
		return false
	if _is_king_in_check(str(piece_data.get("color", "white")), board_state):
		return false

	var direction = signi(to_square.x - from_square.x)
	var rook_from_x = 0
	if direction > 0:
		rook_from_x = board_width - 1
	var rook_from = Vector2i(rook_from_x, from_square.y)
	if not board_state.has(rook_from):
		return false

	var rook_piece: Dictionary = board_state[rook_from]
	if rook_piece.get("piece_id", "") != "rook":
		return false
	if rook_piece.get("color", "") != piece_data.get("color", ""):
		return false
	if bool(rook_piece.get("has_moved", false)):
		return false

	var min_x = min(from_square.x, rook_from_x)
	var max_x = max(from_square.x, rook_from_x)
	for x in range(min_x + 1, max_x):
		if board_state.has(Vector2i(x, from_square.y)):
			return false

	var through_square = Vector2i(from_square.x + direction, from_square.y)
	if _is_square_attacked(through_square, str(piece_data.get("color", "white")), board_state):
		return false
	if _is_square_attacked(to_square, str(piece_data.get("color", "white")), board_state):
		return false

	move_info["is_castling"] = true
	move_info["rook_from"] = rook_from
	move_info["rook_to"] = Vector2i(from_square.x + direction, from_square.y)
	return true

func _board_supports_castling() -> bool:
	return _has_piece_on_board("white", "king") and _has_piece_on_board("black", "king") and _has_piece_on_board("white", "rook") and _has_piece_on_board("black", "rook")

func _has_piece_on_board(piece_color: String, piece_id: String) -> bool:
	for square in pieces.keys():
		var piece_data: Dictionary = pieces[square]
		if piece_data.get("color", "") == piece_color and piece_data.get("piece_id", "") == piece_id:
			return true
	return false

func _is_path_clear(from_square: Vector2i, to_square: Vector2i, board_state: Dictionary) -> bool:
	var step_x = signi(to_square.x - from_square.x)
	var step_y = signi(to_square.y - from_square.y)
	var cursor = from_square + Vector2i(step_x, step_y)

	while cursor != to_square:
		if board_state.has(cursor):
			return false
		cursor += Vector2i(step_x, step_y)

	return true
