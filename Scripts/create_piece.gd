extends Control

const GRID_SIZE = 9
const ORIGIN_CELL = Vector2i(4, 4)
const MOVE_KIND_JUMP = "jump"
const MOVE_KIND_SLIDE = "slide"
const CAPTURE_MODE_ANY = "any"
const CAPTURE_MODE_NON_CAPTURE = "non_capture"
const CAPTURE_MODE_CAPTURE_ONLY = "capture_only"
const SLIDE_SCOPE_INFINITE = "infinite"
const SLIDE_SCOPE_HALTING = "halting"
const ICON_PREVIEW_MAX_SIZE = 64

@onready var piece_name_input: LineEdit = %PieceNameInput
@onready var piece_id_input: LineEdit = %PieceIdInput
@onready var piece_strength_spin_box: SpinBox = %PieceStrengthSpinBox
@onready var icon_preview: TextureRect = %IconPreview
@onready var movement_grid: GridContainer = %MovementGrid
@onready var move_kind_option_button: OptionButton = %MoveKindOptionButton
@onready var capture_mode_option_button: OptionButton = %CaptureModeOptionButton
@onready var slide_mode_option_button: OptionButton = %SlideModeOptionButton
@onready var initial_only_check_box: CheckBox = %InitialOnlyCheckBox
@onready var movement_legend_label: Label = %MovementLegendLabel
@onready var message_label: Label = %MessageLabel
@onready var image_picker_dialog: FileDialog = $ImagePickerDialog

var selected_icon_source_path = ""
var movement_buttons: Array[Button] = []
var movement_rules_by_key: Dictionary = {}

var selected_move_kind = MOVE_KIND_JUMP
var selected_capture_mode = CAPTURE_MODE_ANY
var selected_initial_only = false
var selected_slide_scope = SLIDE_SCOPE_INFINITE

func _ready() -> void:
	piece_strength_spin_box.min_value = 1.0
	piece_strength_spin_box.step = 1.0
	piece_strength_spin_box.rounded = true
	piece_strength_spin_box.value = 3.0
	_build_movement_grid()
	_setup_movement_brush_controls()
	_refresh_movement_grid_buttons()

func _build_movement_grid() -> void:
	for child in movement_grid.get_children():
		child.queue_free()

	movement_buttons.clear()
	movement_grid.columns = GRID_SIZE

	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var button = Button.new()
			button.custom_minimum_size = Vector2(56.0, 56.0)
			button.focus_mode = Control.FOCUS_NONE
			var index = row * GRID_SIZE + col
			button.gui_input.connect(_on_movement_cell_gui_input.bind(index))
			movement_grid.add_child(button)
			movement_buttons.append(button)

func _setup_movement_brush_controls() -> void:
	move_kind_option_button.clear()
	move_kind_option_button.add_item("Jump", 0)
	move_kind_option_button.add_item("Slide", 1)
	move_kind_option_button.selected = 0
	if not move_kind_option_button.item_selected.is_connected(_on_move_kind_option_button_item_selected):
		move_kind_option_button.item_selected.connect(_on_move_kind_option_button_item_selected)

	capture_mode_option_button.clear()
	capture_mode_option_button.add_item("Any (capture or non-capture)", 0)
	capture_mode_option_button.add_item("Non-capture only", 1)
	capture_mode_option_button.add_item("Capture only", 2)
	capture_mode_option_button.selected = 0
	if not capture_mode_option_button.item_selected.is_connected(_on_capture_mode_option_button_item_selected):
		capture_mode_option_button.item_selected.connect(_on_capture_mode_option_button_item_selected)

	slide_mode_option_button.clear()
	slide_mode_option_button.add_item("Slide: Infinite", 0)
	slide_mode_option_button.add_item("Slide: Halting", 1)
	slide_mode_option_button.selected = 0
	slide_mode_option_button.disabled = true
	if not slide_mode_option_button.item_selected.is_connected(_on_slide_mode_option_button_item_selected):
		slide_mode_option_button.item_selected.connect(_on_slide_mode_option_button_item_selected)

	initial_only_check_box.button_pressed = false
	if not initial_only_check_box.toggled.is_connected(_on_initial_only_check_box_toggled):
		initial_only_check_box.toggled.connect(_on_initial_only_check_box_toggled)

	_update_movement_legend()

func _on_movement_cell_gui_input(event: InputEvent, index: int) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event: InputEventMouseButton = event
	if not mouse_event.pressed:
		return
	if mouse_event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_selected_rule_for_cell(index)
	elif mouse_event.button_index == MOUSE_BUTTON_RIGHT:
		_clear_rules_for_cell(index)

func _toggle_selected_rule_for_cell(index: int) -> void:
	if index < 0 or index >= movement_buttons.size():
		return
	var row = int(index / GRID_SIZE)
	var col = index % GRID_SIZE
	if row == ORIGIN_CELL.y and col == ORIGIN_CELL.x:
		return

	var cell_delta = Vector2i(col - ORIGIN_CELL.x, row - ORIGIN_CELL.y)
	var stored_delta = _movement_rule_delta_for_storage(cell_delta, selected_move_kind, selected_slide_scope)
	if stored_delta == Vector2i.ZERO:
		return

	var rule_key = _build_movement_rule_key(selected_move_kind, stored_delta, selected_capture_mode, selected_initial_only, selected_slide_scope)
	if movement_rules_by_key.has(rule_key):
		movement_rules_by_key.erase(rule_key)
	else:
		movement_rules_by_key[rule_key] = {
			"x": stored_delta.x,
			"y": stored_delta.y,
			"kind": selected_move_kind,
			"capture_mode": selected_capture_mode,
			"initial_only": selected_initial_only,
			"slide_scope": selected_slide_scope
		}

	_refresh_movement_grid_buttons()

func _clear_rules_for_cell(index: int) -> void:
	if index < 0 or index >= movement_buttons.size():
		return
	var row = int(index / GRID_SIZE)
	var col = index % GRID_SIZE
	if row == ORIGIN_CELL.y and col == ORIGIN_CELL.x:
		return

	var cell_delta = Vector2i(col - ORIGIN_CELL.x, row - ORIGIN_CELL.y)
	var keys_to_remove: Array[String] = []
	for key in movement_rules_by_key.keys():
		var rule = _movement_rule_from_variant(movement_rules_by_key[key])
		if _movement_rule_applies_to_cell(rule, cell_delta):
			keys_to_remove.append(str(key))

	for key in keys_to_remove:
		movement_rules_by_key.erase(key)

	_refresh_movement_grid_buttons()

func _refresh_movement_grid_buttons() -> void:
	for index in range(movement_buttons.size()):
		var row = int(index / GRID_SIZE)
		var col = index % GRID_SIZE
		var button = movement_buttons[index]
		if row == ORIGIN_CELL.y and col == ORIGIN_CELL.x:
			button.text = "X"
			button.icon = null
			if icon_preview.texture != null:
				button.text = ""
				button.icon = icon_preview.texture
				button.expand_icon = true
				button.disabled = false
				button.modulate = Color(1.0, 1.0, 1.0, 1.0)
			else:
				button.disabled = true
				button.modulate = Color(0.8, 0.7, 0.3, 1.0)
			continue

		button.disabled = false
		var cell_delta = Vector2i(col - ORIGIN_CELL.x, row - ORIGIN_CELL.y)
		var cell_codes: Array[String] = []
		var has_capture_only = false
		var has_non_capture_only = false
		var has_slide = false
		var has_jump = false

		for key in movement_rules_by_key.keys():
			var rule = _movement_rule_from_variant(movement_rules_by_key[key])
			if not _movement_rule_applies_to_cell(rule, cell_delta):
				continue
			cell_codes.append(_movement_rule_display_code(rule))
			if str(rule.get("capture_mode", CAPTURE_MODE_ANY)) == CAPTURE_MODE_CAPTURE_ONLY:
				has_capture_only = true
			elif str(rule.get("capture_mode", CAPTURE_MODE_ANY)) == CAPTURE_MODE_NON_CAPTURE:
				has_non_capture_only = true
			if str(rule.get("kind", MOVE_KIND_JUMP)) == MOVE_KIND_SLIDE:
				has_slide = true
			else:
				has_jump = true

		if cell_codes.is_empty():
			button.text = "."
			button.modulate = Color(1.0, 1.0, 1.0, 1.0)
			continue

		cell_codes.sort()
		if cell_codes.size() <= 2:
			button.text = "\n".join(cell_codes)
		else:
			button.text = "%s\n+%d" % [cell_codes[0], cell_codes.size() - 1]

		if has_capture_only and not has_non_capture_only:
			button.modulate = Color(1.0, 0.76, 0.76, 1.0)
		elif has_non_capture_only and not has_capture_only:
			button.modulate = Color(0.76, 0.9, 1.0, 1.0)
		elif has_slide and not has_jump:
			button.modulate = Color(0.78, 1.0, 0.8, 1.0)
		elif has_jump and not has_slide:
			button.modulate = Color(0.84, 0.9, 1.0, 1.0)
		else:
			button.modulate = Color(1.0, 0.9, 0.78, 1.0)

func _on_move_kind_option_button_item_selected(index: int) -> void:
	selected_move_kind = MOVE_KIND_JUMP if index == 0 else MOVE_KIND_SLIDE
	slide_mode_option_button.disabled = selected_move_kind != MOVE_KIND_SLIDE
	_update_movement_legend()

func _on_capture_mode_option_button_item_selected(index: int) -> void:
	match index:
		1:
			selected_capture_mode = CAPTURE_MODE_NON_CAPTURE
		2:
			selected_capture_mode = CAPTURE_MODE_CAPTURE_ONLY
		_:
			selected_capture_mode = CAPTURE_MODE_ANY
	_update_movement_legend()

func _on_initial_only_check_box_toggled(toggled_on: bool) -> void:
	selected_initial_only = toggled_on
	_update_movement_legend()

func _on_slide_mode_option_button_item_selected(index: int) -> void:
	selected_slide_scope = SLIDE_SCOPE_INFINITE if index == 0 else SLIDE_SCOPE_HALTING
	_update_movement_legend()

func _update_movement_legend() -> void:
	var kind_text = "Jump" if selected_move_kind == MOVE_KIND_JUMP else "Slide"
	var slide_text = ""
	if selected_move_kind == MOVE_KIND_SLIDE:
		slide_text = ", %s" % ("Infinite" if selected_slide_scope == SLIDE_SCOPE_INFINITE else "Halting")
	var capture_text = "Any"
	if selected_capture_mode == CAPTURE_MODE_NON_CAPTURE:
		capture_text = "Non-capture"
	elif selected_capture_mode == CAPTURE_MODE_CAPTURE_ONLY:
		capture_text = "Capture-only"
	var initial_text = "Initial-only" if selected_initial_only else "Normal"

	movement_legend_label.text = "Brush: %s%s, %s, %s\nLegend: J/S (halting slide), arrows for infinite slide, A/N/C capture mode, prefix I for initial-only.\nRight-click a cell to clear rules affecting that cell." % [kind_text, slide_text, capture_text, initial_text]

func _on_pick_icon_button_pressed() -> void:
	image_picker_dialog.popup_centered_ratio(0.8)

func _on_image_picker_dialog_file_selected(path: String) -> void:
	selected_icon_source_path = path
	var image = Image.new()
	if image.load(path) != OK:
		message_label.text = "Could not load image file."
		return
	icon_preview.texture = _build_preview_texture(image)
	_refresh_movement_grid_buttons()
	message_label.text = ""

func _build_preview_texture(source_image: Image) -> Texture2D:
	if source_image == null or source_image.is_empty():
		return null

	var thumbnail = source_image.duplicate()
	var width = max(thumbnail.get_width(), 1)
	var height = max(thumbnail.get_height(), 1)
	var largest_edge = max(width, height)
	if largest_edge > ICON_PREVIEW_MAX_SIZE:
		var scale = float(ICON_PREVIEW_MAX_SIZE) / float(largest_edge)
		var resized_width = max(1, int(round(width * scale)))
		var resized_height = max(1, int(round(height * scale)))
		thumbnail.resize(resized_width, resized_height, Image.INTERPOLATE_LANCZOS)

	return ImageTexture.create_from_image(thumbnail)

func _on_clear_grid_button_pressed() -> void:
	movement_rules_by_key.clear()
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
	if movement_data["movement_rules"].is_empty():
		message_label.text = "Define at least one movement rule."
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
		"movement_rules": movement_data["movement_rules"],
		"jump_offsets": movement_data["jump_offsets"],
		"slide_directions": movement_data["slide_directions"]
	})

	if not bool(save_result.get("ok", false)):
		message_label.text = str(save_result.get("error", "Could not save piece."))
		return

	get_tree().change_scene_to_file("res://Scenes/ManagePieces.tscn")

func _build_movement_data() -> Dictionary:
	var movement_rules: Array = []
	var jump_offsets: Array = []
	var slide_directions: Array = []
	var jump_offset_seen = {}
	var slide_direction_seen = {}

	var rule_keys = movement_rules_by_key.keys()
	rule_keys.sort()
	for rule_key in rule_keys:
		var rule = _movement_rule_from_variant(movement_rules_by_key[rule_key])
		if rule.is_empty():
			continue

		var rule_delta: Vector2i = rule.get("offset", Vector2i.ZERO)
		var rule_kind = str(rule.get("kind", MOVE_KIND_JUMP))
		var capture_mode = str(rule.get("capture_mode", CAPTURE_MODE_ANY))
		var initial_only = bool(rule.get("initial_only", false))

		movement_rules.append({
			"x": rule_delta.x,
			"y": rule_delta.y,
			"kind": rule_kind,
			"capture_mode": capture_mode,
			"initial_only": initial_only,
			"slide_scope": str(rule.get("slide_scope", SLIDE_SCOPE_INFINITE))
		})

		if rule_kind == MOVE_KIND_JUMP:
			var jump_key = "%d:%d" % [rule_delta.x, rule_delta.y]
			if not jump_offset_seen.has(jump_key):
				jump_offset_seen[jump_key] = true
				jump_offsets.append({"x": rule_delta.x, "y": rule_delta.y})
		else:
			if str(rule.get("slide_scope", SLIDE_SCOPE_INFINITE)) == SLIDE_SCOPE_INFINITE:
				var slide_key = "%d:%d" % [rule_delta.x, rule_delta.y]
				if not slide_direction_seen.has(slide_key):
					slide_direction_seen[slide_key] = true
					slide_directions.append({"x": rule_delta.x, "y": rule_delta.y})

	return {
		"movement_rules": movement_rules,
		"jump_offsets": jump_offsets,
		"slide_directions": slide_directions
	}

func _movement_rule_delta_for_storage(cell_delta: Vector2i, move_kind: String, slide_scope: String) -> Vector2i:
	if cell_delta == Vector2i.ZERO:
		return Vector2i.ZERO
	if move_kind == MOVE_KIND_SLIDE and slide_scope == SLIDE_SCOPE_INFINITE:
		return _normalize_direction(cell_delta)
	return cell_delta

func _build_movement_rule_key(move_kind: String, delta: Vector2i, capture_mode: String, initial_only: bool, slide_scope: String) -> String:
	return "%s|%d|%d|%s|%d|%s" % [move_kind, delta.x, delta.y, capture_mode, int(initial_only), slide_scope]

func _movement_rule_from_variant(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return {}
	var move_kind = str(value.get("kind", MOVE_KIND_JUMP))
	if move_kind != MOVE_KIND_SLIDE:
		move_kind = MOVE_KIND_JUMP
	var delta = Vector2i(int(value.get("x", 0)), int(value.get("y", 0)))
	if delta == Vector2i.ZERO:
		return {}

	var slide_scope = str(value.get("slide_scope", SLIDE_SCOPE_INFINITE))
	if slide_scope != SLIDE_SCOPE_HALTING:
		slide_scope = SLIDE_SCOPE_INFINITE

	if move_kind == MOVE_KIND_SLIDE and slide_scope == SLIDE_SCOPE_INFINITE:
		delta = _normalize_direction(delta)
		if delta == Vector2i.ZERO:
			return {}

	var capture_mode = str(value.get("capture_mode", CAPTURE_MODE_ANY))
	if capture_mode != CAPTURE_MODE_NON_CAPTURE and capture_mode != CAPTURE_MODE_CAPTURE_ONLY:
		capture_mode = CAPTURE_MODE_ANY

	return {
		"kind": move_kind,
		"offset": delta,
		"capture_mode": capture_mode,
		"initial_only": bool(value.get("initial_only", false)),
		"slide_scope": slide_scope
	}

func _movement_rule_applies_to_cell(rule: Dictionary, cell_delta: Vector2i) -> bool:
	if rule.is_empty() or cell_delta == Vector2i.ZERO:
		return false
	var rule_kind = str(rule.get("kind", MOVE_KIND_JUMP))
	var rule_delta: Vector2i = rule.get("offset", Vector2i.ZERO)
	if rule_kind == MOVE_KIND_SLIDE:
		if str(rule.get("slide_scope", SLIDE_SCOPE_INFINITE)) == SLIDE_SCOPE_HALTING:
			return cell_delta == rule_delta
		return _count_slide_steps(cell_delta, rule_delta) > 0
	return cell_delta == rule_delta

func _movement_rule_display_code(rule: Dictionary) -> String:
	var rule_kind = str(rule.get("kind", MOVE_KIND_JUMP))
	var capture_mode = str(rule.get("capture_mode", CAPTURE_MODE_ANY))
	var initial_only = bool(rule.get("initial_only", false))

	var kind_code = "J"
	if rule_kind == MOVE_KIND_SLIDE:
		if str(rule.get("slide_scope", SLIDE_SCOPE_INFINITE)) == SLIDE_SCOPE_HALTING:
			kind_code = "S"
		else:
			kind_code = _slide_rule_arrow_code(rule)
	var capture_code = "A"
	if capture_mode == CAPTURE_MODE_NON_CAPTURE:
		capture_code = "N"
	elif capture_mode == CAPTURE_MODE_CAPTURE_ONLY:
		capture_code = "C"
	return ("I" if initial_only else "") + kind_code + capture_code

func _slide_rule_arrow_code(rule: Dictionary) -> String:
	var delta: Vector2i = rule.get("offset", Vector2i.ZERO)
	if delta == Vector2i.ZERO:
		return "S"
	if delta.x == 0 and delta.y < 0:
		return "↑"
	if delta.x == 0 and delta.y > 0:
		return "↓"
	if delta.y == 0 and delta.x < 0:
		return "←"
	if delta.y == 0 and delta.x > 0:
		return "→"
	if delta.x > 0 and delta.y < 0:
		return "↗"
	if delta.x < 0 and delta.y < 0:
		return "↖"
	if delta.x > 0 and delta.y > 0:
		return "↘"
	if delta.x < 0 and delta.y > 0:
		return "↙"
	return "S"

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
