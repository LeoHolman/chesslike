extends Node2D

var WhiteTile = preload("res://Scenes/WhiteTile.tscn")
var BlackTile = preload("res://Scenes/BlackTile.tscn")
const BOARD_MARGIN_RATIO = 0.05
const BASE_TILE_SIZE = 100.0
const INVALID_SQUARE = Vector2i(-1, -1)
const SELECTED_HIGHLIGHT = Color(1.0, 0.84, 0.0, 0.38)
const LEGAL_MOVE_HIGHLIGHT = Color(0.18, 0.75, 0.3, 0.35)
const TURN_INDICATOR_GAP = 56.0
const TURN_INDICATOR_PADDING = 12.0
const TURN_INDICATOR_BACKGROUND = Color(0.95, 0.93, 0.86, 0.94)
const TURN_INDICATOR_BORDER = Color(0.2, 0.2, 0.2, 1.0)

var board_height = 8
var board_width = 8
var board_origin = Vector2.ZERO
var tile_size = 64.0
var pieces = {}
var selected_square = INVALID_SQUARE
var legal_moves: Array[Vector2i] = []
var current_turn = "white"

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_initialize_board_state()
	_build_board()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_board_click(event.position)

func _on_viewport_resized() -> void:
	_build_board()

func _initialize_board_state() -> void:
	board_height = _get_dimension($"/root/GameManager".BoardHeight, 8)
	board_width = _get_dimension($"/root/GameManager".BoardWidth, 8)
	selected_square = INVALID_SQUARE
	legal_moves.clear()
	current_turn = "white"
	pieces.clear()
	if board_width < 1 or board_height < 1:
		return
	_load_starting_pieces()

func _add_piece(square: Vector2i, piece_id: String, piece_color: String) -> void:
	pieces[square] = {
		"piece_id": piece_id,
		"color": piece_color
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
		child.queue_free()

	board_height = _get_dimension($"/root/GameManager".BoardHeight, board_height)
	board_width = _get_dimension($"/root/GameManager".BoardWidth, board_width)
	var viewport_size = get_viewport_rect().size
	var safe_width = viewport_size.x * (1.0 - BOARD_MARGIN_RATIO * 2.0)
	var safe_height = viewport_size.y * (1.0 - BOARD_MARGIN_RATIO * 2.0)
	tile_size = min(safe_width / max(board_width, 1), safe_height / max(board_height, 1))

	var board_pixel_width = board_width * tile_size
	var board_pixel_height = board_height * tile_size
	board_origin = Vector2(
		(viewport_size.x - board_pixel_width) / 2.0,
		(viewport_size.y - board_pixel_height) / 2.0
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
	_draw_turn_indicator()

func _draw_turn_indicator() -> void:
	var font_size = int(max(tile_size * 0.26, 18.0))
	var swatch_size = max(tile_size * 0.28, 18.0)
	var indicator_position = Vector2(
		TURN_INDICATOR_PADDING,
		TURN_INDICATOR_PADDING
	)
	var indicator_size = Vector2(
		max(tile_size * 2.5, 170.0),
		max(swatch_size + TURN_INDICATOR_PADDING * 2.0, 42.0)
	)

	var background = ColorRect.new()
	background.position = indicator_position
	background.size = indicator_size
	background.color = TURN_INDICATOR_BACKGROUND
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
	add_child(turn_label)

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

func _get_piece_symbol(piece_id: String) -> String:
	var piece_definitions = $"/root/GameManager".PieceDefinitions
	if piece_definitions.has(piece_id):
		return str(piece_definitions[piece_id].get("symbol", "?"))
	return "?"

func _handle_board_click(mouse_position: Vector2) -> void:
	var square = _screen_to_square(mouse_position)
	if square == INVALID_SQUARE:
		_clear_selection()
		return

	if selected_square == INVALID_SQUARE:
		if _is_current_turn_piece(square):
			_select_square(square)
		return

	if square == selected_square:
		_clear_selection()
		return

	if _is_square_in_legal_moves(square) and _try_move_piece(selected_square, square):
		current_turn = _opponent_color(current_turn)
		selected_square = INVALID_SQUARE
		legal_moves.clear()
		_build_board()
		return

	if _is_current_turn_piece(square):
		_select_square(square)
	else:
		_clear_selection()

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
			if _is_legal_piece_move(moving_piece, from_square, to_square):
				if not pieces.has(to_square):
					available_moves.append(to_square)
				else:
					var target_piece: Dictionary = pieces[to_square]
					if target_piece.get("color", "") != moving_piece.get("color", ""):
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

func _try_move_piece(from_square: Vector2i, to_square: Vector2i) -> bool:
	if not pieces.has(from_square):
		return false

	var moving_piece: Dictionary = pieces[from_square]
	if not _is_legal_piece_move(moving_piece, from_square, to_square):
		return false

	if pieces.has(to_square):
		var target_piece: Dictionary = pieces[to_square]
		if target_piece.get("color", "") == moving_piece.get("color", ""):
			return false

	pieces.erase(from_square)
	pieces[to_square] = moving_piece
	return true

func _is_legal_piece_move(piece_data: Dictionary, from_square: Vector2i, to_square: Vector2i) -> bool:
	if from_square == to_square:
		return false

	match piece_data.get("piece_id", ""):
		"rook":
			return _is_rook_move_legal(from_square, to_square)
		_:
			return false

func _is_rook_move_legal(from_square: Vector2i, to_square: Vector2i) -> bool:
	if from_square.x != to_square.x and from_square.y != to_square.y:
		return false

	var step_x = signi(to_square.x - from_square.x)
	var step_y = signi(to_square.y - from_square.y)
	var cursor = from_square + Vector2i(step_x, step_y)

	while cursor != to_square:
		if pieces.has(cursor):
			return false
		cursor += Vector2i(step_x, step_y)

	return true
