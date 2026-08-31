extends Control

@onready var width_spin_box: SpinBox = $OptionsScroll/OptionsContent/WidthSpinBox
@onready var height_spin_box: SpinBox = $OptionsScroll/OptionsContent/HeightSpinBox
@onready var board_preview: Control = $PreviewArea/BoardPreview
@onready var piece_bank_list: ItemList = $OptionsScroll/OptionsContent/PieceBankList
@onready var piece_color_option: OptionButton = $OptionsScroll/OptionsContent/PieceColorOption
@onready var preset_list: ItemList = $OptionsScroll/OptionsContent/PresetList

const INVALID_SQUARE = Vector2i(-1, -1)
const PREVIEW_SELECTION_HIGHLIGHT = Color(0.2, 0.6, 1.0, 0.28)
const PREVIEW_GHOST_TINT = Color(1.0, 1.0, 1.0, 0.45)
const PRESETS = {
	"Standard": "standard"
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

func _ready() -> void:
	width_spin_box.value_changed.connect(_refresh_preview)
	height_spin_box.value_changed.connect(_refresh_preview)
	board_preview.gui_input.connect(_on_board_preview_gui_input)
	board_preview.resized.connect(_refresh_preview)
	board_preview.mouse_exited.connect(_on_board_preview_mouse_exited)
	preset_list.item_selected.connect(_on_preset_item_selected)
	_populate_piece_bank()
	_populate_presets()
	_setup_piece_color_picker()
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

func _setup_piece_color_picker() -> void:
	piece_color_option.clear()
	piece_color_option.add_item("White")
	piece_color_option.add_item("Black")
	piece_color_option.select(0)
	piece_color_option.item_selected.connect(_on_piece_color_selected)

func _reset_preview_to_default(should_refresh: bool = true, use_standard_layout: bool = true) -> void:
	width_spin_box.value = 8
	height_spin_box.value = 8
	preview_pieces.clear()
	if use_standard_layout:
		_apply_standard_chess_layout()
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
		"standard":
			_reset_preview_to_default(false, false)
			_apply_standard_chess_layout()
			_refresh_preview()
		_:
			return

func _apply_standard_chess_layout() -> void:
	var back_rank = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
	for x in range(8):
		preview_pieces[Vector2i(x, 0)] = {"piece_id": back_rank[x], "color": "black"}
		preview_pieces[Vector2i(x, 1)] = {"piece_id": "pawn", "color": "black"}
		preview_pieces[Vector2i(x, 6)] = {"piece_id": "pawn", "color": "white"}
		preview_pieces[Vector2i(x, 7)] = {"piece_id": back_rank[x], "color": "white"}

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

	preview_tile_size = min(
		floor(board_preview.size.x / max(width, 1)),
		floor(board_preview.size.y / max(height, 1))
	)
	if preview_tile_size < 1:
		preview_tile_size = 1

	var board_pixel_size = Vector2(width * preview_tile_size, height * preview_tile_size)
	preview_board_origin = (board_preview.size - board_pixel_size) / 2.0

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
	if preview_pieces.has(hover_preview_square):
		return

	var ghost_piece = _create_preview_piece_node(
		hover_preview_square,
		{"piece_id": selected_piece_id, "color": selected_piece_color},
		PREVIEW_GHOST_TINT
	)
	board_preview.add_child(ghost_piece)

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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_left_dragging = true
				is_right_dragging = false
				drag_changed_any = false
				last_drag_square = INVALID_SQUARE
				_update_hover_square(event.position)
				_apply_drag_action(event.position, true)
			else:
				if not drag_changed_any:
					_select_piece_from_preview(event.position)
				is_left_dragging = false
				last_drag_square = INVALID_SQUARE
			return

		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
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
			_apply_drag_action(event.position, true)
		elif event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			_apply_drag_action(event.position, false)
		else:
			_refresh_preview()

func _on_board_preview_mouse_exited() -> void:
	hover_preview_square = INVALID_SQUARE
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

func _on_clear_board_button_pressed() -> void:
	preview_pieces.clear()
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
	
	#var LocalGame = load("res://Scenes/LocalGame.tscn")
	#get_tree().current_scene.add_child(LocalGame)
	get_tree().change_scene_to_file("res://Scenes/LocalGame.tscn")
