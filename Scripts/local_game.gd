extends Node2D

var WhiteTile = preload("res://Scenes/WhiteTile.tscn")
var BlackTile = preload("res://Scenes/BlackTile.tscn")
const BOARD_MARGIN_RATIO = 0.05
const BASE_TILE_SIZE = 100.0
const INVALID_SQUARE = Vector2i(-1, -1)
const SELECTED_HIGHLIGHT = Color(1.0, 0.84, 0.0, 0.38)
const LEGAL_MOVE_HIGHLIGHT = Color(0.18, 0.75, 0.3, 0.35)
const TURN_INDICATOR_PADDING = 12.0
const TURN_INDICATOR_BACKGROUND = Color(0.95, 0.93, 0.86, 0.94)
const TURN_INDICATOR_BORDER = Color(0.2, 0.2, 0.2, 1.0)
const WHITE_POOL_PANEL_BACKGROUND = Color(0.27, 0.35, 0.52, 0.92)
const WHITE_POOL_PANEL_HOVER_BACKGROUND = Color(0.36, 0.46, 0.66, 0.96)
const BLACK_POOL_PANEL_BACKGROUND = Color(0.43, 0.25, 0.24, 0.92)
const BLACK_POOL_PANEL_HOVER_BACKGROUND = Color(0.57, 0.33, 0.31, 0.96)
const DROP_POOL_PANEL_BORDER = Color(0.9, 0.92, 0.98, 1.0)
const HUD_PANEL_SPACING = 12.0
const FILE_NAMES = "abcdefghijklmnopqrstuvwxyz"
const DEFAULT_PROMOTION_PIECE_IDS = ["queen", "rook", "bishop", "knight"]

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
var drop_piece_drag_active = false
var drop_piece_drag_position = Vector2.ZERO
var drop_pool_hover_owner = ""

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_initialize_board_state()
	_ensure_promotion_picker()
	_build_board()

func _unhandled_input(event: InputEvent) -> void:
	if promotion_pending:
		return
	if event is InputEventMouseMotion and drop_piece_drag_active:
		drop_piece_drag_position = event.position
		drop_pool_hover_owner = _drop_pool_side_at_position(event.position)
		_build_board()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_handle_pointer_press(event.position)
		else:
			_handle_pointer_release(event.position)

func _handle_pointer_press(mouse_position: Vector2) -> void:
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
		_finalize_turn_after_move()
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
	piece_dropping_enabled = bool(special_rules.get("piece_dropping", false))
	capture_to_drop_pool_enabled = bool(special_rules.get("capture_to_drop_pool", false)) and piece_dropping_enabled
	limit_army_strength_enabled = bool(special_rules.get("limit_army_strength", false))
	unbalanced_armies_enabled = bool(special_rules.get("unbalanced_armies", false))
	army_strength_cap = max(int($"/root/GameManager".ArmyStrengthCap), 2)
	army_strength_cap_white = max(int($"/root/GameManager".ArmyStrengthCapWhite), 2)
	army_strength_cap_black = max(int($"/root/GameManager".ArmyStrengthCapBlack), 2)
	promotion_piece_options = _get_promotion_piece_pool()
	en_passant_target_square = INVALID_SQUARE
	drop_pools = _get_starting_drop_pools()
	selected_drop_piece_id = ""
	selected_drop_piece_owner = ""
	legal_drop_squares.clear()
	drop_pool_hover_owner = ""
	drop_pool_selection_index["white"] = 0
	drop_pool_selection_index["black"] = 0
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
			var tile
			if (x + y) % 2 == 0:
				tile = WhiteTile.instantiate()
			else:
				tile = BlackTile.instantiate()
			add_child(tile)
			tile.position = board_origin + Vector2(x * tile_size, y * tile_size)
			tile.scale = Vector2(tile_size / BASE_TILE_SIZE, tile_size / BASE_TILE_SIZE)

	_draw_highlights()
	_draw_pieces()
	_draw_drop_piece_drag_preview()
	var next_hud_position = _draw_turn_indicator()
	if piece_dropping_enabled:
		_draw_drop_pool_panels()
	else:
		_draw_captured_pieces_panels()
	_draw_move_history_panel(next_hud_position)
	_draw_game_over_banner()

func _draw_turn_indicator() -> Vector2:
	var font_size = _hud_font_size(0.22, 13, 24)
	var swatch_size = clampf(tile_size * 0.24, 14.0, 24.0)
	var indicator_position = Vector2(
		TURN_INDICATOR_PADDING,
		TURN_INDICATOR_PADDING
	)
	var viewport_size = get_viewport_rect().size
	var indicator_width = clampf(tile_size * 2.2, 150.0, min(viewport_size.x * 0.30, 260.0))
	var indicator_height = clampf(swatch_size + TURN_INDICATOR_PADDING * 2.0, 40.0, 56.0)
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
	turn_label.position = indicator_position + Vector2(TURN_INDICATOR_PADDING + swatch_size + 10.0, (indicator_size.y - font_size) / 2.0 - 2.0)
	turn_label.add_theme_font_size_override("font_size", font_size)
	turn_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	turn_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(turn_label)

	if status_message != "" and not game_over:
		var status_label = Label.new()
		status_label.text = status_message
		status_label.position = indicator_position + Vector2(TURN_INDICATOR_PADDING, indicator_size.y + 2.0)
		status_label.add_theme_font_size_override("font_size", _hud_font_size(0.15, 11, 16))
		status_label.add_theme_color_override("font_color", Color(0.25, 0.08, 0.08))
		status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(status_label)
		return indicator_position + Vector2(0.0, indicator_size.y + 24.0 + HUD_PANEL_SPACING)

	return indicator_position + Vector2(0.0, indicator_size.y + HUD_PANEL_SPACING)


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
	_draw_hud_panel(left_position, panel_size, "White Captures", [_format_captured_strength_summary("white"), _format_captured_piece_list("white")])
	_draw_hud_panel(right_position, panel_size, "Black Captures", [_format_captured_strength_summary("black"), _format_captured_piece_list("black")])

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

	_draw_drop_pool_panel(left_position, panel_size, "White Drop Pool", "white")
	_draw_drop_pool_panel(right_position, panel_size, "Black Drop Pool", "black")

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
	var entries = _get_drop_pool_display_entries(owner)

	if entries.is_empty():
		var empty_label = Label.new()
		empty_label.position = Vector2(content_x, current_y)
		empty_label.size = Vector2(content_width, row_height * 2.0)
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

	for entry in entries:
		var piece_id = str(entry.get("piece_id", ""))
		var count = int(entry.get("count", 0))
		var row_rect = Rect2(Vector2(content_x, current_y), Vector2(content_width, row_height))
		var selected = owner == selected_drop_piece_owner and piece_id == selected_drop_piece_id

		if selected:
			var row_background = ColorRect.new()
			row_background.position = row_rect.position
			row_background.size = row_rect.size
			row_background.color = Color(0.32, 0.42, 0.56, 0.72)
			row_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(row_background)

		var row_label = Label.new()
		row_label.position = row_rect.position + Vector2(4.0, 1.0)
		row_label.size = row_rect.size - Vector2(4.0, 0.0)
		row_label.text = "%s x%d" % [_get_piece_symbol(piece_id), count]
		row_label.add_theme_font_size_override("font_size", _hud_font_size(0.15, 11, 14))
		row_label.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0, 1.0))
		row_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(row_label)

		entry_rects.append({
			"piece_id": piece_id,
			"rect": row_rect
		})
		current_y += row_height + 4.0

	if owner == current_turn:
		var helper_label = Label.new()
		helper_label.position = Vector2(content_x, min(current_y + 2.0, panel_position.y + panel_size.y - row_height))
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

func _draw_move_history_panel(panel_position: Vector2) -> void:
	var recent_moves: Array[String] = []
	if move_history.is_empty():
		recent_moves.append("No moves yet")
	else:
		var move_lines = 4 if _is_tiny_board() else 6
		var start_index = max(move_history.size() - move_lines, 0)
		for index in range(start_index, move_history.size()):
			recent_moves.append(move_history[index])

	var panel_height = max(tile_size * 2.2, 110.0)
	if recent_moves.size() > 4:
		panel_height = max(panel_height, 34.0 + recent_moves.size() * 15.0)
	var viewport_size = get_viewport_rect().size
	var panel_width = clampf(max(tile_size * 2.8, 180.0), 180.0, max(210.0, min(viewport_size.x * 0.36, 320.0)))
	panel_height = clampf(panel_height, 95.0, max(120.0, min(viewport_size.y * 0.34, 210.0)))
	if _is_tiny_board():
		panel_width = clampf(panel_width, 168.0, min(viewport_size.x * 0.30, 240.0))
		panel_height = clampf(panel_height, 88.0, min(viewport_size.y * 0.26, 150.0))
	_draw_hud_panel(
		panel_position,
		Vector2(panel_width, panel_height),
		"Move History",
		recent_moves
	)

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
	if board_width > 4 and board_height > 4:
		return viewport_size.y * BOARD_MARGIN_RATIO
	return clampf(max(74.0, viewport_size.y * 0.12), 68.0, 130.0)

func _hud_bottom_reserve_height(viewport_size: Vector2) -> float:
	if board_width > 4 and board_height > 4:
		return viewport_size.y * BOARD_MARGIN_RATIO
	var base_reserve = 170.0 if piece_dropping_enabled else 154.0
	return clampf(max(base_reserve, viewport_size.y * 0.22), 138.0, 220.0)

func _drop_pool_panel_color(owner: String, hovered: bool) -> Color:
	if owner == "white":
		return WHITE_POOL_PANEL_HOVER_BACKGROUND if hovered else WHITE_POOL_PANEL_BACKGROUND
	return BLACK_POOL_PANEL_HOVER_BACKGROUND if hovered else BLACK_POOL_PANEL_BACKGROUND

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
		return "White"
	if color == "black":
		return "Black"
	return color.capitalize()

func _turn_color_swatch(color: String) -> Color:
	if color == "white":
		return Color(1.0, 1.0, 1.0, 1.0)
	if color == "black":
		return Color(0.08, 0.08, 0.08, 1.0)
	return Color(0.7, 0.7, 0.7, 1.0)

func _draw_highlights() -> void:
	for square in legal_drop_squares:
		add_child(_create_square_overlay(square, LEGAL_MOVE_HIGHLIGHT))

	if selected_square != INVALID_SQUARE:
		add_child(_create_square_overlay(selected_square, SELECTED_HIGHLIGHT))

	for square in legal_moves:
		if square != selected_square:
			add_child(_create_square_overlay(square, LEGAL_MOVE_HIGHLIGHT))

func _create_square_overlay(square: Vector2i, color: Color) -> Polygon2D:
	var overlay = Polygon2D.new()
	overlay.position = board_origin + Vector2(square.x * tile_size, square.y * tile_size)
	overlay.color = color
	overlay.polygon = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(tile_size, 0.0),
		Vector2(tile_size, tile_size),
		Vector2(0.0, tile_size)
	])
	return overlay

func _draw_pieces() -> void:
	for square in pieces.keys():
		var piece_data: Dictionary = pieces[square]
		var piece_node = _create_piece_node(piece_data)
		piece_node.position = board_origin + Vector2(square.x * tile_size, square.y * tile_size)
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

	# Label placeholder for now; this wrapper node lets us replace it with an image sprite later.
	var label = Label.new()
	label.size = Vector2(tile_size, tile_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = _get_piece_symbol(piece_data.get("piece_id", ""))
	label.add_theme_font_size_override("font_size", int(tile_size * 0.55))
	label.add_theme_constant_override("outline_size", max(int(tile_size * 0.06), 2))
	label.add_theme_color_override("font_color", _piece_fill_color(piece_data.get("color", "white")))
	label.add_theme_color_override("font_outline_color", _piece_outline_color(piece_data.get("color", "white")))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	piece_root.add_child(label)

	return piece_root

func _piece_fill_color(piece_color: String) -> Color:
	if piece_color == "white":
		return Color(1.0, 1.0, 1.0, 1.0)
	return Color(0.08, 0.08, 0.08, 1.0)

func _piece_outline_color(piece_color: String) -> Color:
	if piece_color == "white":
		return Color(0.08, 0.08, 0.08, 1.0)
	return Color(1.0, 1.0, 1.0, 1.0)

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
	var move_number = move_history.size() + 1
	if bool(move_info.get("is_castling", false)):
		var castling_notation = "O-O"
		if to_square.x < from_square.x:
			castling_notation = "O-O-O"
		move_history.append("%d. %s %s" % [
			move_number,
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

	move_history.append("%d. %s %s %s%s%s%s%s" % [
		move_number,
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

	var square = _screen_to_square(mouse_position)
	if square == INVALID_SQUARE:
		_clear_selection()
		_clear_drop_piece_selection()
		return

	if selected_square == INVALID_SQUARE:
		if _is_current_turn_piece(square):
			_select_square(square)
		return

	if square == selected_square:
		_clear_selection()
		return

	if _is_square_in_legal_moves(square) and _try_move_piece(selected_square, square):
		_clear_drop_piece_selection()
		_finalize_turn_after_move()
		return

	if _is_current_turn_piece(square):
		_select_square(square)
	else:
		_clear_selection()

func _try_begin_drop_pool_drag(mouse_position: Vector2) -> bool:
	if not piece_dropping_enabled:
		return false
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
	var entries: Array = drop_pool_entry_rects.get(owner, [])
	for entry in entries:
		if entry is Dictionary and Rect2(entry.get("rect", Rect2())).has_point(mouse_position):
			return entry
	return {}

func _try_drop_piece_from_pool(target_square: Vector2i) -> bool:
	if not piece_dropping_enabled:
		return false
	if selected_drop_piece_id == "" or selected_drop_piece_owner != current_turn:
		return false
	if not _is_legal_drop_piece_from_pool(selected_drop_piece_id, current_turn, target_square):
		return false

	var pool_contents: Array = drop_pools.get(current_turn, [])
	var remove_index = pool_contents.find(selected_drop_piece_id)
	if remove_index == -1:
		return false
	pool_contents.remove_at(remove_index)
	drop_pools[current_turn] = pool_contents
	_add_piece(target_square, selected_drop_piece_id, current_turn)
	move_history.append("%d. %s drops %s @ %s" % [
		move_history.size() + 1,
		_display_color(current_turn),
		_get_piece_symbol(selected_drop_piece_id),
		_square_to_notation(target_square)
	])
	_clear_drop_piece_selection()
	return true

func _is_legal_drop_piece_from_pool(piece_id: String, owner: String, target_square: Vector2i) -> bool:
	if target_square == INVALID_SQUARE:
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

	return Vector2i(square_x, square_y)

func _finalize_turn_after_move() -> void:
	current_turn = _opponent_color(current_turn)
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	legal_drop_squares.clear()
	_update_game_state(true)
	_build_board()

func _try_move_piece(from_square: Vector2i, to_square: Vector2i) -> bool:
	if promotion_pending:
		return false
	if not pieces.has(from_square):
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
		_:
			return false

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
			status_message = "Black wins - Total War"
			if record_history:
				move_history.append("Total War. Black wins.")
			return

		if black_piece_count == 0:
			game_over = true
			status_message = "White wins - Total War"
			if record_history:
				move_history.append("Total War. White wins.")
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
	var promotion_rank = board_height - 1
	if str(piece_data.get("color", "white")) == "white":
		direction = -1
		start_rank = board_height - 2
		promotion_rank = 0

	var delta_x = to_square.x - from_square.x
	var delta_y = to_square.y - from_square.y
	var destination_occupied = board_state.has(to_square)

	if delta_x == 0:
		if delta_y == direction and not destination_occupied:
			if to_square.y == promotion_rank and promotion_enabled:
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
			if to_square.y == promotion_rank and promotion_enabled:
				move_info["requires_promotion"] = true
			return true

		if en_passant_enabled and to_square == en_passant_target_square:
			var capture_square = Vector2i(to_square.x, from_square.y)
			if board_state.has(capture_square):
				var target_pawn: Dictionary = board_state[capture_square]
				if target_pawn.get("piece_id", "") == "pawn" and target_pawn.get("color", "") != piece_data.get("color", ""):
					move_info["capture_square"] = capture_square
					move_info["is_en_passant"] = true
					if to_square.y == promotion_rank and promotion_enabled:
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
