extends Node2D

var WhiteTile = preload("res://Scenes/WhiteTile.tscn")
var BlackTile = preload("res://Scenes/BlackTile.tscn")
const BOARD_MARGIN_RATIO = 0.05

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_build_board()

func _on_viewport_resized() -> void:
	_build_board()

func _get_dimension(value: Variant, fallback: int) -> int:
	if value is int:
		return max(value, 1)
	if value is float:
		return max(roundi(value), 1)
	if value is String:
		return max(value.to_int(), 1)
	return max(fallback, 1)

func _build_board() -> void:
	for child in get_children():
		child.queue_free()

	var height = _get_dimension($"/root/GameManager".BoardHeight, 8)
	var width = _get_dimension($"/root/GameManager".BoardWidth, 8)
	var viewport_size = get_viewport_rect().size
	var safe_width = viewport_size.x * (1.0 - BOARD_MARGIN_RATIO * 2.0)
	var safe_height = viewport_size.y * (1.0 - BOARD_MARGIN_RATIO * 2.0)
	var tile_size = min(safe_width / max(width, 1), safe_height / max(height, 1))

	var board_width = width * tile_size
	var board_height = height * tile_size
	var offset_x = (viewport_size.x - board_width) / 2.0
	var offset_y = (viewport_size.y - board_height) / 2.0
	var current_x = offset_x
	var current_y = viewport_size.y - offset_y

	var is_white_tile = true

	for i in height:
		current_x = offset_x
		current_y -= tile_size
		if i > 0 and width % 2 == 0:
			is_white_tile = not is_white_tile
		for j in width:
			var tile
			if is_white_tile:
				tile = WhiteTile.instantiate()
			else:
				tile = BlackTile.instantiate()
			add_child(tile)
			tile.position = Vector2(current_x, current_y)
			tile.scale = Vector2(tile_size / 100.0, tile_size / 100.0)
			is_white_tile = not is_white_tile
			current_x += tile_size
