extends Control

const GRID_SIZE = 6
const CELL_NONE = 0
const CELL_JUMP = 1
const CELL_SLIDE = 2
const CELL_BOTH = 3
const ORIGIN_CELL = Vector2i(3, 3)

@onready var piece_name_input: LineEdit = %PieceNameInput
@onready var piece_id_input: LineEdit = %PieceIdInput
@onready var piece_strength_spin_box: SpinBox = %PieceStrengthSpinBox
@onready var icon_preview: TextureRect = %IconPreview
@onready var movement_grid: GridContainer = %MovementGrid
@onready var message_label: Label = %MessageLabel
@onready var image_picker_dialog: FileDialog = $ImagePickerDialog

var selected_icon_source_path = ""
var cell_modes: Array[int] = []
var movement_buttons: Array[Button] = []

func _ready() -> void:
	piece_strength_spin_box.min_value = 1.0
	piece_strength_spin_box.step = 1.0
	piece_strength_spin_box.rounded = true
	piece_strength_spin_box.value = 3.0
	_build_movement_grid()

func _build_movement_grid() -> void:
	for child in movement_grid.get_children():
		child.queue_free()

	cell_modes.clear()
	movement_buttons.clear()
	movement_grid.columns = GRID_SIZE

	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var button = Button.new()
			button.custom_minimum_size = Vector2(56.0, 56.0)
			button.focus_mode = Control.FOCUS_NONE
			var index = row * GRID_SIZE + col
			cell_modes.append(CELL_NONE)
			button.pressed.connect(_on_movement_cell_pressed.bind(index))
			movement_grid.add_child(button)
			movement_buttons.append(button)

	_refresh_movement_grid_buttons()

func _on_movement_cell_pressed(index: int) -> void:
	if index < 0 or index >= cell_modes.size():
		return
	var row = int(index / GRID_SIZE)
	var col = index % GRID_SIZE
	if row == ORIGIN_CELL.y and col == ORIGIN_CELL.x:
		return
	cell_modes[index] = (cell_modes[index] + 1) % 4
	_refresh_movement_grid_buttons()

func _refresh_movement_grid_buttons() -> void:
	for index in range(movement_buttons.size()):
		var row = int(index / GRID_SIZE)
		var col = index % GRID_SIZE
		var button = movement_buttons[index]
		if row == ORIGIN_CELL.y and col == ORIGIN_CELL.x:
			button.text = "X"
			button.disabled = true
			button.modulate = Color(0.8, 0.7, 0.3, 1.0)
			continue
		button.disabled = false
		match cell_modes[index]:
			CELL_JUMP:
				button.text = "J"
				button.modulate = Color(0.68, 0.86, 1.0, 1.0)
			CELL_SLIDE:
				button.text = "S"
				button.modulate = Color(0.72, 1.0, 0.74, 1.0)
			CELL_BOTH:
				button.text = "B"
				button.modulate = Color(1.0, 0.88, 0.6, 1.0)
			_:
				button.text = "."
				button.modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_pick_icon_button_pressed() -> void:
	image_picker_dialog.popup_centered_ratio(0.8)

func _on_image_picker_dialog_file_selected(path: String) -> void:
	selected_icon_source_path = path
	var image = Image.new()
	if image.load(path) != OK:
		message_label.text = "Could not load image file."
		return
	icon_preview.texture = ImageTexture.create_from_image(image)
	message_label.text = ""

func _on_clear_grid_button_pressed() -> void:
	for index in range(cell_modes.size()):
		cell_modes[index] = CELL_NONE
	_refresh_movement_grid_buttons()

func _on_cancel_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ManagePieces.tscn")

func _on_save_piece_button_pressed() -> void:
	var piece_name = piece_name_input.text.strip_edges()
	if piece_name == "":
		message_label.text = "Piece name is required."
		return

	var piece_id = _sanitize_piece_id(piece_id_input.text if piece_id_input.text.strip_edges() != "" else piece_name)
	if piece_id == "":
		message_label.text = "Piece ID is invalid."
		return

	if selected_icon_source_path == "":
		message_label.text = "Select an icon image first."
		return

	var movement_data = _build_movement_data()
	if movement_data["jump_offsets"].is_empty() and movement_data["slide_directions"].is_empty():
		message_label.text = "Define at least one jump or slide cell."
		return

	var game_manager = $"/root/GameManager"
	var icon_path = game_manager.save_custom_piece_icon(piece_id, selected_icon_source_path)
	if icon_path == "":
		message_label.text = "Could not save icon into user storage."
		return

	var save_result: Dictionary = game_manager.save_custom_piece({
		"id": piece_id,
		"name": piece_name,
		"symbol": piece_name.substr(0, 1).to_upper(),
		"strength": int(piece_strength_spin_box.value),
		"icon_path": icon_path,
		"jump_offsets": movement_data["jump_offsets"],
		"slide_directions": movement_data["slide_directions"]
	})

	if not bool(save_result.get("ok", false)):
		message_label.text = str(save_result.get("error", "Could not save piece."))
		return

	get_tree().change_scene_to_file("res://Scenes/ManagePieces.tscn")

func _build_movement_data() -> Dictionary:
	var jump_offsets: Array = []
	var slide_directions: Array = []

	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var index = row * GRID_SIZE + col
			if row == ORIGIN_CELL.y and col == ORIGIN_CELL.x:
				continue
			var mode = cell_modes[index]
			if mode == CELL_NONE:
				continue
			var delta = Vector2i(col - ORIGIN_CELL.x, row - ORIGIN_CELL.y)
			if mode == CELL_JUMP or mode == CELL_BOTH:
				jump_offsets.append({"x": delta.x, "y": delta.y})
			if mode == CELL_SLIDE or mode == CELL_BOTH:
				var normalized = _normalize_direction(delta)
				var serialized = {"x": normalized.x, "y": normalized.y}
				if not slide_directions.has(serialized):
					slide_directions.append(serialized)

	return {
		"jump_offsets": jump_offsets,
		"slide_directions": slide_directions
	}

func _normalize_direction(delta: Vector2i) -> Vector2i:
	var gcd_value = _gcd(abs(delta.x), abs(delta.y))
	if gcd_value <= 0:
		return delta
	return Vector2i(int(delta.x / gcd_value), int(delta.y / gcd_value))

func _gcd(a: int, b: int) -> int:
	var x = abs(a)
	var y = abs(b)
	while y != 0:
		var remainder = x % y
		x = y
		y = remainder
	return max(x, 1)

func _sanitize_piece_id(source: String) -> String:
	var lower = source.to_lower().strip_edges()
	var result = ""
	var prev_underscore = false
	for index in range(lower.length()):
		var ch = lower.unicode_at(index)
		var is_letter = ch >= 97 and ch <= 122
		var is_digit = ch >= 48 and ch <= 57
		var is_valid = is_letter or is_digit
		if is_valid:
			result += lower.substr(index, 1)
			prev_underscore = false
		else:
			if not prev_underscore:
				result += "_"
				prev_underscore = true
	result = result.trim_prefix("_").trim_suffix("_")
	return result
