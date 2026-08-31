extends Control

@onready var width_spin_box: SpinBox = $OptionsScroll/OptionsContent/WidthSpinBox
@onready var height_spin_box: SpinBox = $OptionsScroll/OptionsContent/HeightSpinBox
@onready var board_preview: Control = $PreviewArea/BoardPreview
@onready var piece_bank_list: ItemList = $OptionsScroll/OptionsContent/PieceBankList
@onready var piece_color_option: OptionButton = $OptionsScroll/OptionsContent/PieceColorOption
@onready var preset_list: ItemList = $OptionsScroll/OptionsContent/PresetList
@onready var preset_name_input: LineEdit = $OptionsScroll/OptionsContent/PresetNameInput
@onready var castling_check_box: CheckBox = $OptionsScroll/OptionsContent/CastlingCheckBox
@onready var en_passant_check_box: CheckBox = $OptionsScroll/OptionsContent/EnPassantCheckBox
@onready var promotion_check_box: CheckBox = $OptionsScroll/OptionsContent/PromotionCheckBox
@onready var piece_dropping_check_box: CheckBox = $OptionsScroll/OptionsContent/PieceDroppingCheckBox
@onready var capture_to_drop_pool_check_box: CheckBox = $OptionsScroll/OptionsContent/CaptureToDropPoolCheckBox
@onready var castling_support_hint_background: ColorRect = $OptionsScroll/OptionsContent/CastlingSupportHintBackground
@onready var castling_support_hint: Label = $OptionsScroll/OptionsContent/CastlingSupportHint
@onready var promotion_pieces_title: Label = $OptionsScroll/OptionsContent/PromotionPiecesTitle
@onready var promotion_pieces_list: VBoxContainer = $OptionsScroll/OptionsContent/PromotionPiecesList

const INVALID_SQUARE = Vector2i(-1, -1)
const PREVIEW_SELECTION_HIGHLIGHT = Color(0.2, 0.6, 1.0, 0.28)
const PREVIEW_GHOST_TINT = Color(1.0, 1.0, 1.0, 0.45)
const PREVIEW_DROP_POOL_BACKGROUND = Color(0.12, 0.14, 0.18, 0.8)
const PREVIEW_DROP_POOL_BORDER = Color(0.82, 0.85, 0.92, 0.95)
const PREVIEW_DROP_POOL_HOVER_BACKGROUND = Color(0.24, 0.34, 0.48, 0.9)
const PRESETS = {
	"Standard Chess": "standard_chess",
	"Standard Shogi": "standard_shogi"
}

var selected_piece_id = ""
var selected_piece_color = "white"
var preview_tile_size = 1.0
var preview_board_origin = Vector2.ZERO
var preview_pieces = {}
var last_drag_square = INVALID_SQUARE
var hover_preview_square = INVALID_SQUARE
var selected_preview_square = INVALID_SQUARE
var is_left_dragging = false
var is_right_dragging = false
var drag_changed_any = false
var promotion_piece_checkboxes: Dictionary = {}
var castling_user_preference = true
var is_updating_castling_availability = false
var preview_drop_pools = {
	"white": [],
	"black": []
}
var preview_white_drop_pool_rect = Rect2()
var preview_black_drop_pool_rect = Rect2()
var preview_drop_pool_entry_rects = {
	"white": [],
	"black": []
}
var dragging_preview_piece = false
var drag_piece_origin_square = INVALID_SQUARE
var dragging_piece_bank_piece = false
var piece_bank_drag_piece_id = ""
var piece_bank_drag_piece_color = "white"
var piece_bank_drag_preview_position = Vector2.ZERO
var preview_drop_pool_hover_owner = ""

func _ready() -> void:
	width_spin_box.value_changed.connect(_refresh_preview)
	height_spin_box.value_changed.connect(_refresh_preview)
	board_preview.gui_input.connect(_on_board_preview_gui_input)
	piece_bank_list.gui_input.connect(_on_piece_bank_gui_input)
	board_preview.resized.connect(_refresh_preview)
	board_preview.mouse_exited.connect(_on_board_preview_mouse_exited)
	preset_list.item_selected.connect(_on_preset_item_selected)
	_populate_piece_bank()
	_populate_presets()
	_setup_piece_color_picker()
	_setup_special_rules()
	_reset_preview_to_default(false, false)
	_refresh_preview(0.0)

func _populate_piece_bank() -> void:
	piece_bank_list.clear()
	var game_manager = $"/root/GameManager"
	for piece_id in game_manager.PieceBank:
		var piece_data = game_manager.PieceDefinitions.get(piece_id, {})
		var display_name = piece_data.get("name", str(piece_id))
		var symbol = piece_data.get("symbol", "?")
		piece_bank_list.add_item("%s (%s)" % [display_name, symbol])

	if game_manager.PieceBank.size() > 0:
		selected_piece_id = str(game_manager.PieceBank[0])
		piece_bank_list.select(0)

	piece_bank_list.item_selected.connect(_on_piece_bank_item_selected)

func _populate_presets() -> void:
	preset_list.clear()
	for preset_name in PRESETS.keys():
		preset_list.add_item(preset_name)

	var saved_presets: Dictionary = $"/root/GameManager".SavedPresets
	var custom_names = saved_presets.keys()
	custom_names.sort()
	for preset_name in custom_names:
		preset_list.add_item(str(preset_name))

func _setup_piece_color_picker() -> void:
	piece_color_option.clear()
	piece_color_option.add_item("White")
	piece_color_option.add_item("Black")
	piece_color_option.select(0)
	piece_color_option.item_selected.connect(_on_piece_color_selected)

func _setup_special_rules() -> void:
	castling_check_box.toggled.connect(_on_castling_rule_toggled)
	promotion_check_box.toggled.connect(_on_promotion_rule_toggled)
	piece_dropping_check_box.toggled.connect(_on_piece_dropping_toggled)
	_build_promotion_piece_checkboxes()
	_apply_special_rules($"/root/GameManager".SpecialRules)
	_apply_promotion_piece_pool($"/root/GameManager".PromotionPiecePool)
	_update_promotion_piece_visibility()
	_update_piece_dropping_visibility()
	_update_castling_rule_availability()

func _build_special_rules() -> Dictionary:
	return {
		"castling": castling_check_box.button_pressed,
		"en_passant": en_passant_check_box.button_pressed,
		"promotion": promotion_check_box.button_pressed,
		"piece_dropping": piece_dropping_check_box.button_pressed,
		"capture_to_drop_pool": capture_to_drop_pool_check_box.button_pressed
	}

func _build_promotion_piece_pool() -> Array:
	var selected_piece_ids: Array = []
	for piece_id in promotion_piece_checkboxes.keys():
		var check_box: CheckBox = promotion_piece_checkboxes[piece_id]
		if check_box.button_pressed:
			selected_piece_ids.append(str(piece_id))
	selected_piece_ids.sort()
	return selected_piece_ids

func _build_promotion_piece_checkboxes() -> void:
	for child in promotion_pieces_list.get_children():
		child.queue_free()
	promotion_piece_checkboxes.clear()

	var game_manager = $"/root/GameManager"
	for piece_id in game_manager.PieceBank:
		var piece_key = str(piece_id)
		var piece_data = game_manager.PieceDefinitions.get(piece_key, {})
		var piece_name = str(piece_data.get("name", piece_key.capitalize()))
		var piece_symbol = str(piece_data.get("symbol", "?"))
		var check_box = CheckBox.new()
		check_box.text = "%s (%s)" % [piece_name, piece_symbol]
		check_box.toggled.connect(_on_promotion_piece_toggled.bind(piece_key))
		promotion_pieces_list.add_child(check_box)
		promotion_piece_checkboxes[piece_key] = check_box

func _apply_promotion_piece_pool(piece_pool: Array) -> void:
	for piece_id in promotion_piece_checkboxes.keys():
		var check_box: CheckBox = promotion_piece_checkboxes[piece_id]
		check_box.button_pressed = false

	for piece_id in piece_pool:
		if promotion_piece_checkboxes.has(piece_id):
			var check_box: CheckBox = promotion_piece_checkboxes[piece_id]
			check_box.button_pressed = true

	if _build_promotion_piece_pool().is_empty() and promotion_piece_checkboxes.has("queen"):
		var queen_check_box: CheckBox = promotion_piece_checkboxes["queen"]
		queen_check_box.button_pressed = true

func _update_promotion_piece_visibility() -> void:
	var show_promotion_piece_pool = promotion_check_box.button_pressed
	promotion_pieces_title.visible = show_promotion_piece_pool
	promotion_pieces_list.visible = show_promotion_piece_pool

func _update_piece_dropping_visibility() -> void:
	var show_capture_rule = piece_dropping_check_box.button_pressed
	capture_to_drop_pool_check_box.visible = show_capture_rule
	if not show_capture_rule:
		capture_to_drop_pool_check_box.button_pressed = false

func _update_castling_rule_availability() -> void:
	var supports_castling = _preview_supports_castling()
	is_updating_castling_availability = true
	castling_check_box.disabled = not supports_castling
	if supports_castling:
		castling_support_hint.visible = false
		castling_support_hint_background.visible = false
		castling_check_box.button_pressed = castling_user_preference
	else:
		castling_support_hint.visible = true
		castling_support_hint_background.visible = true
		castling_check_box.button_pressed = false
	is_updating_castling_availability = false

func _preview_supports_castling() -> bool:
	return _preview_has_piece("white", "king") and _preview_has_piece("black", "king") and _preview_has_piece("white", "rook") and _preview_has_piece("black", "rook")

func _preview_has_piece(piece_color: String, piece_id: String) -> bool:
	for square in preview_pieces.keys():
		var piece_data: Dictionary = preview_pieces[square]
		if piece_data.get("color", "") == piece_color and piece_data.get("piece_id", "") == piece_id:
			return true
	return false

func _on_castling_rule_toggled(is_enabled: bool) -> void:
	if is_updating_castling_availability:
		return
	if castling_check_box.disabled:
		return
	castling_user_preference = is_enabled

func _on_promotion_rule_toggled(_is_enabled: bool) -> void:
	_update_promotion_piece_visibility()

func _on_piece_dropping_toggled(_is_enabled: bool) -> void:
	_update_piece_dropping_visibility()
	_refresh_preview()

func _on_promotion_piece_toggled(is_checked: bool, piece_id: String) -> void:
	if is_checked:
		return
	if not promotion_check_box.button_pressed:
		return
	if not _build_promotion_piece_pool().is_empty():
		return
	if promotion_piece_checkboxes.has(piece_id):
		var check_box: CheckBox = promotion_piece_checkboxes[piece_id]
		check_box.button_pressed = true

func _apply_special_rules(special_rules: Dictionary) -> void:
	castling_user_preference = bool(special_rules.get("castling", true))
	castling_check_box.button_pressed = bool(special_rules.get("castling", true))
	en_passant_check_box.button_pressed = bool(special_rules.get("en_passant", true))
	promotion_check_box.button_pressed = bool(special_rules.get("promotion", true))
	piece_dropping_check_box.button_pressed = bool(special_rules.get("piece_dropping", false))
	capture_to_drop_pool_check_box.button_pressed = bool(special_rules.get("capture_to_drop_pool", false))
	_update_castling_rule_availability()
	_update_piece_dropping_visibility()

func _reset_preview_to_default(should_refresh: bool = true, use_standard_layout: bool = true) -> void:
	width_spin_box.value = 8
	height_spin_box.value = 8
	preview_pieces.clear()
	preview_drop_pools = {
		"white": [],
		"black": []
	}
	if use_standard_layout:
		_apply_standard_chess_layout()
	_apply_special_rules({
		"castling": true,
		"en_passant": true,
		"promotion": true,
		"piece_dropping": false,
		"capture_to_drop_pool": false
	})
	_apply_promotion_piece_pool(["queen", "rook", "bishop", "knight"])
	_update_promotion_piece_visibility()
	_update_piece_dropping_visibility()
	selected_piece_color = "white"
	piece_color_option.select(0)
	if piece_bank_list.item_count > 0:
		piece_bank_list.select(0)
		selected_piece_id = str($"/root/GameManager".PieceBank[0])
	else:
		selected_piece_id = ""
	last_drag_square = INVALID_SQUARE
	hover_preview_square = INVALID_SQUARE
	selected_preview_square = INVALID_SQUARE
	is_left_dragging = false
	is_right_dragging = false
	drag_changed_any = false
	if should_refresh:
		_refresh_preview()

func _apply_preset(preset_id: String) -> void:
	match preset_id:
		"standard_chess":
			_reset_preview_to_default(false, false)
			width_spin_box.value = 8
			height_spin_box.value = 8
			_apply_standard_chess_layout()
			_apply_special_rules({
				"castling": true,
				"en_passant": true,
				"promotion": true,
				"piece_dropping": false,
				"capture_to_drop_pool": false
			})
			_apply_promotion_piece_pool(["queen", "rook", "bishop", "knight"])
			preview_drop_pools = {
				"white": [],
				"black": []
			}
			_refresh_preview()
		"standard_shogi":
			_reset_preview_to_default(false, false)
			width_spin_box.value = 9
			height_spin_box.value = 9
			_apply_standard_shogi_layout()
			_apply_special_rules({
				"castling": false,
				"en_passant": false,
				"promotion": false,
				"piece_dropping": true,
				"capture_to_drop_pool": true
			})
			_apply_promotion_piece_pool(["rook", "bishop", "silver_general", "gold_general", "lance", "shogi_knight", "shogi_pawn"])
			preview_drop_pools = {
				"white": [],
				"black": []
			}
			_refresh_preview()
		_:
			var saved_presets: Dictionary = $"/root/GameManager".SavedPresets
			if saved_presets.has(preset_id):
				_apply_saved_preset_config(saved_presets[preset_id])
			return

func _apply_saved_preset_config(preset_config: Dictionary) -> void:
	width_spin_box.value = _get_dimension(preset_config.get("width", 8), 8)
	height_spin_box.value = _get_dimension(preset_config.get("height", 8), 8)
	preview_pieces = _deserialize_preview_pieces(preset_config.get("pieces", []))
	preview_drop_pools = _deserialize_drop_pools(preset_config.get("drop_pools", {}))
	_apply_special_rules(preset_config.get("special_rules", {}))
	_apply_promotion_piece_pool(preset_config.get("promotion_pieces", ["queen", "rook", "bishop", "knight"]))
	_update_promotion_piece_visibility()
	_update_piece_dropping_visibility()
	last_drag_square = INVALID_SQUARE
	hover_preview_square = INVALID_SQUARE
	selected_preview_square = INVALID_SQUARE
	is_left_dragging = false
	is_right_dragging = false
	drag_changed_any = false
	_refresh_preview()

func _apply_standard_chess_layout() -> void:
	var back_rank = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
	for x in range(8):
		preview_pieces[Vector2i(x, 0)] = {"piece_id": back_rank[x], "color": "black"}
		preview_pieces[Vector2i(x, 1)] = {"piece_id": "pawn", "color": "black"}
		preview_pieces[Vector2i(x, 6)] = {"piece_id": "pawn", "color": "white"}
		preview_pieces[Vector2i(x, 7)] = {"piece_id": back_rank[x], "color": "white"}

func _apply_standard_shogi_layout() -> void:
	var back_rank = ["lance", "shogi_knight", "silver_general", "gold_general", "king", "gold_general", "silver_general", "shogi_knight", "lance"]
	for x in range(9):
		preview_pieces[Vector2i(x, 0)] = {"piece_id": back_rank[x], "color": "black"}
		preview_pieces[Vector2i(x, 2)] = {"piece_id": "shogi_pawn", "color": "black"}
		preview_pieces[Vector2i(x, 6)] = {"piece_id": "shogi_pawn", "color": "white"}
		preview_pieces[Vector2i(x, 8)] = {"piece_id": back_rank[x], "color": "white"}
	preview_pieces[Vector2i(1, 1)] = {"piece_id": "rook", "color": "black"}
	preview_pieces[Vector2i(7, 1)] = {"piece_id": "bishop", "color": "black"}
	preview_pieces[Vector2i(1, 7)] = {"piece_id": "bishop", "color": "white"}
	preview_pieces[Vector2i(7, 7)] = {"piece_id": "rook", "color": "white"}

func _on_piece_bank_item_selected(index: int) -> void:
	var game_manager = $"/root/GameManager"
	if index >= 0 and index < game_manager.PieceBank.size():
		selected_piece_id = str(game_manager.PieceBank[index])

func _on_preset_item_selected(index: int) -> void:
	if index < 0 or index >= preset_list.item_count:
		return
	var preset_name = preset_list.get_item_text(index)
	if PRESETS.has(preset_name):
		_apply_preset(str(PRESETS[preset_name]))
		return
	_apply_preset(preset_name)

func _on_piece_color_selected(index: int) -> void:
	if index == 1:
		selected_piece_color = "black"
	else:
		selected_piece_color = "white"

func _refresh_preview(_value: float = 0.0) -> void:
	for child in board_preview.get_children():
		child.queue_free()

	var width = _get_dimension(width_spin_box.value, 8)
	var height = _get_dimension(height_spin_box.value, 8)
	_prune_preview_pieces(width, height)
	var pool_width_estimate = 0.0
	if piece_dropping_check_box.button_pressed:
		pool_width_estimate = clampf(board_preview.size.x * 0.18, 92.0, 150.0) + 16.0
	var usable_width = max(board_preview.size.x - pool_width_estimate * 2.0, 80.0)

	preview_tile_size = min(
		floor(usable_width / max(width, 1)),
		floor(board_preview.size.y / max(height, 1))
	)
	if preview_tile_size < 1:
		preview_tile_size = 1

	var board_pixel_size = Vector2(width * preview_tile_size, height * preview_tile_size)
	preview_board_origin = Vector2(
		(board_preview.size.x - board_pixel_size.x) / 2.0,
		(board_preview.size.y - board_pixel_size.y) / 2.0
	)

	var is_white = true
	for y in range(height):
		for x in range(width):
			var tile = ColorRect.new()
			tile.size = Vector2(preview_tile_size, preview_tile_size)
			tile.position = preview_board_origin + Vector2(x * preview_tile_size, y * preview_tile_size)
			tile.color = Color.WHITE if is_white else Color.DIM_GRAY
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			board_preview.add_child(tile)
			is_white = !is_white

		if width % 2 == 0:
			is_white = !is_white

	_draw_preview_selection()
	_draw_preview_pieces()
	_draw_preview_ghost()
	_draw_piece_bank_drag_preview()
	_draw_preview_drop_pools(board_pixel_size)
	_update_castling_rule_availability()

func _draw_preview_selection() -> void:
	if selected_preview_square == INVALID_SQUARE:
		return

	var overlay = ColorRect.new()
	overlay.position = preview_board_origin + Vector2(selected_preview_square.x * preview_tile_size, selected_preview_square.y * preview_tile_size)
	overlay.size = Vector2(preview_tile_size, preview_tile_size)
	overlay.color = PREVIEW_SELECTION_HIGHLIGHT
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(overlay)

func _draw_preview_pieces() -> void:
	for square in preview_pieces.keys():
		var piece_data: Dictionary = preview_pieces[square]
		board_preview.add_child(_create_preview_piece_node(square, piece_data))

func _draw_preview_ghost() -> void:
	if hover_preview_square == INVALID_SQUARE or selected_piece_id == "":
		return
	if dragging_piece_bank_piece:
		return
	if preview_pieces.has(hover_preview_square):
		return

	var ghost_piece = _create_preview_piece_node(
		hover_preview_square,
		{"piece_id": selected_piece_id, "color": selected_piece_color},
		PREVIEW_GHOST_TINT
	)
	board_preview.add_child(ghost_piece)

func _draw_piece_bank_drag_preview() -> void:
	if not dragging_piece_bank_piece:
		return
	if not Rect2(Vector2.ZERO, board_preview.size).has_point(piece_bank_drag_preview_position):
		return

	var drag_piece = _create_preview_piece_node(
		Vector2i.ZERO,
		{"piece_id": piece_bank_drag_piece_id, "color": piece_bank_drag_piece_color},
		PREVIEW_GHOST_TINT
	)
	drag_piece.position = piece_bank_drag_preview_position - Vector2(preview_tile_size * 0.5, preview_tile_size * 0.5)
	board_preview.add_child(drag_piece)

func _draw_preview_drop_pools(board_pixel_size: Vector2) -> void:
	preview_white_drop_pool_rect = Rect2()
	preview_black_drop_pool_rect = Rect2()
	preview_drop_pool_entry_rects["white"] = []
	preview_drop_pool_entry_rects["black"] = []
	if not piece_dropping_check_box.button_pressed:
		return

	var pool_width = clampf(board_preview.size.x * 0.18, 92.0, 150.0)
	var pool_height = clampf(board_pixel_size.y * 0.68, 120.0, board_preview.size.y - 24.0)
	var pool_y = clampf(preview_board_origin.y + (board_pixel_size.y - pool_height) * 0.5, 8.0, board_preview.size.y - pool_height - 8.0)

	preview_white_drop_pool_rect = Rect2(8.0, pool_y, pool_width, pool_height)
	preview_black_drop_pool_rect = Rect2(board_preview.size.x - pool_width - 8.0, pool_y, pool_width, pool_height)

	_draw_single_preview_drop_pool(preview_white_drop_pool_rect, "White Drop Pool", "white")
	_draw_single_preview_drop_pool(preview_black_drop_pool_rect, "Black Drop Pool", "black")

func _draw_single_preview_drop_pool(pool_rect: Rect2, title: String, pool_owner: String) -> void:
	var background = ColorRect.new()
	background.position = pool_rect.position
	background.size = pool_rect.size
	background.color = PREVIEW_DROP_POOL_HOVER_BACKGROUND if preview_drop_pool_hover_owner == pool_owner else PREVIEW_DROP_POOL_BACKGROUND
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(background)

	var border = Line2D.new()
	border.position = pool_rect.position
	border.width = 2.0
	border.default_color = PREVIEW_DROP_POOL_BORDER
	border.closed = true
	border.points = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(pool_rect.size.x, 0.0),
		Vector2(pool_rect.size.x, pool_rect.size.y),
		Vector2(0.0, pool_rect.size.y)
	])
	board_preview.add_child(border)

	var title_label = Label.new()
	title_label.position = pool_rect.position + Vector2(8.0, 6.0)
	title_label.size = Vector2(pool_rect.size.x - 12.0, 22.0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 13)
	title_label.add_theme_color_override("font_color", Color(0.93, 0.94, 0.97, 1.0))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(title_label)

	var entries: Array = _get_preview_drop_pool_display_entries(pool_owner)
	var entry_rects: Array = []
	var content_x = pool_rect.position.x + 8.0
	var current_y = pool_rect.position.y + 30.0
	var row_height = max(preview_tile_size * 0.5, 20.0)
	var content_width = pool_rect.size.x - 12.0
	if entries.is_empty():
		var empty_label = Label.new()
		empty_label.position = Vector2(content_x, current_y)
		empty_label.size = Vector2(content_width, row_height)
		empty_label.text = "(empty)"
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", Color(0.96, 0.97, 1.0, 1.0))
		empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_preview.add_child(empty_label)
		preview_drop_pool_entry_rects[pool_owner] = entry_rects
		return

	for entry in entries:
		var piece_id = str(entry.get("piece_id", ""))
		var count = int(entry.get("count", 0))
		var row_rect = Rect2(Vector2(content_x, current_y), Vector2(content_width, row_height))
		var row_label = Label.new()
		row_label.position = row_rect.position
		row_label.size = row_rect.size
		row_label.text = "%s x%d" % [_get_piece_symbol(piece_id), count]
		row_label.add_theme_font_size_override("font_size", 14)
		row_label.add_theme_color_override("font_color", Color(0.96, 0.97, 1.0, 1.0))
		row_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_preview.add_child(row_label)
		entry_rects.append({"piece_id": piece_id, "rect": row_rect})
		current_y += row_height + 2.0

	preview_drop_pool_entry_rects[pool_owner] = entry_rects

func _get_preview_drop_pool_display_entries(pool_owner: String) -> Array[Dictionary]:
	var pool_contents: Array = preview_drop_pools.get(pool_owner, [])
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

func _create_preview_piece_node(square: Vector2i, piece_data: Dictionary, tint: Color = Color(1.0, 1.0, 1.0, 1.0)) -> Control:
	var piece_root = Control.new()
	piece_root.position = preview_board_origin + Vector2(square.x * preview_tile_size, square.y * preview_tile_size)
	piece_root.size = Vector2(preview_tile_size, preview_tile_size)
	piece_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var label = Label.new()
	label.size = piece_root.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = _get_piece_symbol(piece_data.get("piece_id", ""))
	label.add_theme_font_size_override("font_size", int(max(preview_tile_size * 0.55, 12.0)))
	label.add_theme_constant_override("outline_size", max(int(preview_tile_size * 0.06), 2))
	label.add_theme_color_override("font_color", _piece_fill_color(piece_data.get("color", "white")))
	label.add_theme_color_override("font_outline_color", _piece_outline_color(piece_data.get("color", "white")))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.modulate = tint
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

func _on_board_preview_gui_input(event: InputEvent) -> void:
	if dragging_piece_bank_piece:
		if event is InputEventMouseMotion:
			piece_bank_drag_preview_position = event.position
			preview_drop_pool_hover_owner = _preview_drop_pool_side_at_position(event.position)
			_refresh_preview()
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_left_dragging = true
				is_right_dragging = false
				drag_changed_any = false
				last_drag_square = INVALID_SQUARE
				dragging_preview_piece = false
				drag_piece_origin_square = INVALID_SQUARE
				if piece_dropping_check_box.button_pressed:
					var drag_square = _preview_position_to_square(event.position)
					if drag_square != INVALID_SQUARE and preview_pieces.has(drag_square):
						dragging_preview_piece = true
						drag_piece_origin_square = drag_square
				_update_hover_square(event.position)
				if not dragging_preview_piece:
					_apply_drag_action(event.position, true)
			else:
				if dragging_preview_piece and _try_drop_dragged_piece_to_pool(event.position):
					drag_changed_any = true
				if not drag_changed_any:
					_select_piece_from_preview(event.position)
				is_left_dragging = false
				last_drag_square = INVALID_SQUARE
				dragging_preview_piece = false
				drag_piece_origin_square = INVALID_SQUARE
			return

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				if _try_remove_preview_drop_pool_piece(event.position):
					return
				is_right_dragging = true
				is_left_dragging = false
				drag_changed_any = false
				last_drag_square = INVALID_SQUARE
				_update_hover_square(event.position)
				_apply_drag_action(event.position, false)
			else:
				is_right_dragging = false
				last_drag_square = INVALID_SQUARE
			return

	if event is InputEventMouseMotion:
		_update_hover_square(event.position)
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			if dragging_preview_piece:
				preview_drop_pool_hover_owner = _preview_drop_pool_side_at_position(event.position)
				_refresh_preview()
				return
			if not dragging_preview_piece:
				_apply_drag_action(event.position, true)
		elif event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			_apply_drag_action(event.position, false)
		else:
			preview_drop_pool_hover_owner = ""
			_refresh_preview()

func _try_remove_preview_drop_pool_piece(position: Vector2) -> bool:
	var pool_owner = _preview_drop_pool_side_at_position(position)
	if pool_owner == "":
		return false
	var entry = _get_preview_drop_pool_entry_at_position(pool_owner, position)
	if entry.is_empty():
		return true
	var piece_id = str(entry.get("piece_id", ""))
	var pool_contents: Array = preview_drop_pools.get(pool_owner, [])
	var remove_index = pool_contents.find(piece_id)
	if remove_index == -1:
		return true
	pool_contents.remove_at(remove_index)
	preview_drop_pools[pool_owner] = pool_contents
	_refresh_preview()
	return true

func _get_preview_drop_pool_entry_at_position(pool_owner: String, position: Vector2) -> Dictionary:
	var entries: Array = preview_drop_pool_entry_rects.get(pool_owner, [])
	for entry in entries:
		if entry is Dictionary and Rect2(entry.get("rect", Rect2())).has_point(position):
			return entry
	return {}

func _on_piece_bank_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var game_manager = $"/root/GameManager"
			var selected_index = piece_bank_list.get_item_at_position(event.position, true)
			if selected_index < 0 or selected_index >= game_manager.PieceBank.size():
				return
			piece_bank_list.select(selected_index)
			selected_piece_id = str(game_manager.PieceBank[selected_index])
			dragging_piece_bank_piece = true
			piece_bank_drag_piece_id = str(game_manager.PieceBank[selected_index])
			piece_bank_drag_piece_color = selected_piece_color
			piece_bank_drag_preview_position = board_preview.get_local_mouse_position()
			preview_drop_pool_hover_owner = _preview_drop_pool_side_at_position(piece_bank_drag_preview_position)
			_refresh_preview()
		else:
			_try_commit_piece_bank_drop()

func _input(event: InputEvent) -> void:
	if not dragging_piece_bank_piece:
		return
	if event is InputEventMouseMotion:
		piece_bank_drag_preview_position = board_preview.get_local_mouse_position()
		preview_drop_pool_hover_owner = _preview_drop_pool_side_at_position(piece_bank_drag_preview_position)
		_refresh_preview()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_try_commit_piece_bank_drop()

func _try_commit_piece_bank_drop() -> void:
	if not dragging_piece_bank_piece:
		return
	var mouse_position = board_preview.get_local_mouse_position()
	var target_pool = _preview_drop_pool_side_at_position(mouse_position)
	if target_pool != "":
		_add_piece_to_preview_drop_pool(target_pool, piece_bank_drag_piece_id)
	_clear_piece_bank_drag_state()
	_refresh_preview()

func _clear_piece_bank_drag_state() -> void:
	dragging_piece_bank_piece = false
	piece_bank_drag_piece_id = ""
	piece_bank_drag_piece_color = selected_piece_color
	piece_bank_drag_preview_position = Vector2.ZERO
	preview_drop_pool_hover_owner = ""

func _try_drop_dragged_piece_to_pool(position: Vector2) -> bool:
	if drag_piece_origin_square == INVALID_SQUARE:
		return false
	if not preview_pieces.has(drag_piece_origin_square):
		return false
	if not piece_dropping_check_box.button_pressed:
		return false

	var target_pool = _preview_drop_pool_side_at_position(position)
	if target_pool == "":
		return false

	var piece_data: Dictionary = preview_pieces[drag_piece_origin_square]
	preview_pieces.erase(drag_piece_origin_square)
	selected_preview_square = INVALID_SQUARE
	_add_piece_to_preview_drop_pool(target_pool, str(piece_data.get("piece_id", "")))
	preview_drop_pool_hover_owner = ""
	_refresh_preview()
	return true

func _preview_drop_pool_side_at_position(position: Vector2) -> String:
	if preview_white_drop_pool_rect.has_point(position):
		return "white"
	if preview_black_drop_pool_rect.has_point(position):
		return "black"
	return ""

func _add_piece_to_preview_drop_pool(pool_owner: String, piece_id: String) -> void:
	if piece_id == "":
		return
	var pool_contents: Array = preview_drop_pools.get(pool_owner, [])
	pool_contents.append(piece_id)
	preview_drop_pools[pool_owner] = pool_contents

func _on_board_preview_mouse_exited() -> void:
	hover_preview_square = INVALID_SQUARE
	if dragging_piece_bank_piece:
		piece_bank_drag_preview_position = Vector2(-1.0, -1.0)
	preview_drop_pool_hover_owner = ""
	if not is_left_dragging and not is_right_dragging:
		_refresh_preview()

func _apply_drag_action(position: Vector2, should_place_piece: bool) -> void:
	var square = _preview_position_to_square(position)
	if square == INVALID_SQUARE or square == last_drag_square:
		return

	last_drag_square = square
	if should_place_piece:
		if selected_piece_id == "":
			return
		preview_pieces[square] = {
			"piece_id": selected_piece_id,
			"color": selected_piece_color
		}
		selected_preview_square = square
	else:
		preview_pieces.erase(square)
		if selected_preview_square == square:
			selected_preview_square = INVALID_SQUARE

	drag_changed_any = true
	_refresh_preview()

func _select_piece_from_preview(position: Vector2) -> void:
	var square = _preview_position_to_square(position)
	if square == INVALID_SQUARE or not preview_pieces.has(square):
		selected_preview_square = INVALID_SQUARE
		_refresh_preview()
		return

	selected_preview_square = square
	var piece_data: Dictionary = preview_pieces[square]
	selected_piece_id = str(piece_data.get("piece_id", ""))
	selected_piece_color = str(piece_data.get("color", "white"))
	_sync_piece_bank_selection()
	piece_color_option.select(0 if selected_piece_color == "white" else 1)
	_refresh_preview()

func _sync_piece_bank_selection() -> void:
	var piece_bank = $"/root/GameManager".PieceBank
	for index in range(piece_bank.size()):
		if str(piece_bank[index]) == selected_piece_id:
			piece_bank_list.select(index)
			return

func _update_hover_square(position: Vector2) -> void:
	var square = _preview_position_to_square(position)
	if hover_preview_square == square:
		return
	hover_preview_square = square

func _preview_position_to_square(position: Vector2) -> Vector2i:
	if position.x < preview_board_origin.x or position.y < preview_board_origin.y:
		return INVALID_SQUARE

	var local_position = position - preview_board_origin
	var square_x = int(floor(local_position.x / preview_tile_size))
	var square_y = int(floor(local_position.y / preview_tile_size))
	var width = _get_dimension(width_spin_box.value, 8)
	var height = _get_dimension(height_spin_box.value, 8)

	if square_x < 0 or square_y < 0 or square_x >= width or square_y >= height:
		return INVALID_SQUARE

	return Vector2i(square_x, square_y)

func _prune_preview_pieces(width: int, height: int) -> void:
	var pruned_pieces = {}
	for square in preview_pieces.keys():
		if square.x >= 0 and square.y >= 0 and square.x < width and square.y < height:
			pruned_pieces[square] = preview_pieces[square]
	preview_pieces = pruned_pieces
	if selected_preview_square != INVALID_SQUARE and not preview_pieces.has(selected_preview_square):
		selected_preview_square = INVALID_SQUARE
	if hover_preview_square != INVALID_SQUARE:
		if hover_preview_square.x < 0 or hover_preview_square.y < 0 or hover_preview_square.x >= width or hover_preview_square.y >= height:
			hover_preview_square = INVALID_SQUARE

func _get_piece_symbol(piece_id: String) -> String:
	var piece_definitions = $"/root/GameManager".PieceDefinitions
	if piece_definitions.has(piece_id):
		return str(piece_definitions[piece_id].get("symbol", "?"))
	return "?"

func _get_dimension(value: Variant, fallback: int) -> int:
	if value is int:
		return max(value, 1)
	if value is float:
		return max(roundi(value), 1)
	if value is String:
		return max(value.to_int(), 1)
	return max(fallback, 1)

func _serialize_preview_pieces() -> Array:
	var serialized_pieces = []
	for square in preview_pieces.keys():
		var piece_data: Dictionary = preview_pieces[square]
		serialized_pieces.append({
			"x": square.x,
			"y": square.y,
			"piece_id": piece_data.get("piece_id", ""),
			"color": piece_data.get("color", "white")
		})
	return serialized_pieces

func _serialize_drop_pools() -> Dictionary:
	return {
		"white": (preview_drop_pools.get("white", []) as Array).duplicate(true),
		"black": (preview_drop_pools.get("black", []) as Array).duplicate(true)
	}

func _deserialize_drop_pools(source: Variant) -> Dictionary:
	if not (source is Dictionary):
		return {
			"white": [],
			"black": []
		}
	var parsed = {
		"white": [],
		"black": []
	}
	for pool_owner in ["white", "black"]:
		var values = source.get(pool_owner, [])
		if values is Array:
			var normalized: Array = []
			for piece_id in values:
				normalized.append(str(piece_id))
			parsed[pool_owner] = normalized
	return parsed

func _deserialize_preview_pieces(serialized_pieces: Array) -> Dictionary:
	var deserialized_pieces = {}
	for piece_entry in serialized_pieces:
		if not (piece_entry is Dictionary):
			continue
		var square = Vector2i(
			int(piece_entry.get("x", 0)),
			int(piece_entry.get("y", 0))
		)
		deserialized_pieces[square] = {
			"piece_id": str(piece_entry.get("piece_id", "")),
			"color": str(piece_entry.get("color", "white"))
		}
	return deserialized_pieces

func _build_preset_config() -> Dictionary:
	return {
		"width": _get_dimension(width_spin_box.value, 8),
		"height": _get_dimension(height_spin_box.value, 8),
		"pieces": _serialize_preview_pieces(),
		"drop_pools": _serialize_drop_pools(),
		"special_rules": _build_special_rules(),
		"promotion_pieces": _build_promotion_piece_pool()
	}

func _on_save_preset_button_pressed() -> void:
	var preset_name = preset_name_input.text.strip_edges()
	if preset_name == "":
		preset_name_input.placeholder_text = "Enter preset name"
		return
	if PRESETS.has(preset_name):
		preset_name_input.text = ""
		preset_name_input.placeholder_text = "Name reserved"
		return

	$"/root/GameManager".save_preset(preset_name, _build_preset_config())
	preset_name_input.text = ""
	preset_name_input.placeholder_text = "Preset saved"
	_populate_presets()

func _on_delete_preset_button_pressed() -> void:
	var selected_items = preset_list.get_selected_items()
	if selected_items.is_empty():
		preset_name_input.text = ""
		preset_name_input.placeholder_text = "Select a preset"
		return

	var preset_name = preset_list.get_item_text(selected_items[0])
	if PRESETS.has(preset_name):
		preset_name_input.text = ""
		preset_name_input.placeholder_text = "Built-in preset"
		return

	if $"/root/GameManager".delete_preset(preset_name):
		preset_name_input.text = ""
		preset_name_input.placeholder_text = "Preset deleted"
		_populate_presets()

func _on_clear_board_button_pressed() -> void:
	preview_pieces.clear()
	preview_drop_pools = {
		"white": [],
		"black": []
	}
	last_drag_square = INVALID_SQUARE
	selected_preview_square = INVALID_SQUARE
	_refresh_preview()

func _on_reset_setup_button_pressed() -> void:
	_reset_preview_to_default(true, false)

func _on_start_game_button_pressed() -> void:
	var height = height_spin_box.value
	var width = width_spin_box.value
	
	$"/root/GameManager".BoardHeight = height
	$"/root/GameManager".BoardWidth = width
	$"/root/GameManager".StartingPieces = _serialize_preview_pieces()
	$"/root/GameManager".StartingDropPools = _serialize_drop_pools()
	$"/root/GameManager".SpecialRules = _build_special_rules()
	$"/root/GameManager".PromotionPiecePool = _build_promotion_piece_pool()
	
	#var LocalGame = load("res://Scenes/LocalGame.tscn")
	#get_tree().current_scene.add_child(LocalGame)
	get_tree().change_scene_to_file("res://Scenes/LocalGame.tscn")
