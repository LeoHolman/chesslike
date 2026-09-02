extends Control

const UITheme = preload("res://Scripts/ui_theme.gd")

const GRID_SIZE = 9
const ORIGIN_CELL = Vector2i(4, 4)
const MOVE_KIND_JUMP = "jump"
const MOVE_KIND_SLIDE = "slide"
const CAPTURE_MODE_ANY = "any"
const CAPTURE_MODE_NON_CAPTURE = "non_capture"
const CAPTURE_MODE_CAPTURE_ONLY = "capture_only"
const SLIDE_SCOPE_INFINITE = "infinite"
const SLIDE_SCOPE_HALTING = "halting"
const CUSTOM_PATH_STROKE_WIDTH_RATIO = 0.012
const SVG_EXPORT_VIEWBOX_SIZE = 1000.0
const SVG_CURVE_SEGMENTS = 16

@onready var piece_name_input: LineEdit = %PieceNameInput
@onready var piece_id_input: LineEdit = %PieceIdInput
@onready var piece_strength_spin_box: SpinBox = %PieceStrengthSpinBox
@onready var piece_path_canvas = %PiecePathCanvas
@onready var path_tool_option_button: OptionButton = %ToolOptionButton
@onready var symmetry_check_box: CheckBox = %SymmetryCheckBox
@onready var symmetry_count_spin_box: SpinBox = %SymmetryCountSpinBox
@onready var snap_check_box: CheckBox = %SnapCheckBox
@onready var snap_angle_option_button: OptionButton = %SnapAngleOptionButton
@onready var template_option_button: OptionButton = %TemplateOptionButton
@onready var apply_template_button: Button = %ApplyTemplateButton
@onready var title_label: Label = $Scroll/RootMargin/RootVBox/TitleLabel
@onready var save_piece_button: Button = $Scroll/RootMargin/RootVBox/ActionsRow/SavePieceButton
@onready var cancel_button: Button = $Scroll/RootMargin/RootVBox/ActionsRow/CancelButton
@onready var root_margin: MarginContainer = $Scroll/RootMargin
@onready var root_vbox: VBoxContainer = $Scroll/RootMargin/RootVBox
@onready var main_columns: HBoxContainer = $Scroll/RootMargin/RootVBox/MainColumns
@onready var left_panel: VBoxContainer = $Scroll/RootMargin/RootVBox/MainColumns/LeftPanel
@onready var right_panel: VBoxContainer = $Scroll/RootMargin/RootVBox/MainColumns/RightPanel
@onready var actions_row: HBoxContainer = $Scroll/RootMargin/RootVBox/ActionsRow
@onready var path_buttons: HBoxContainer = $Scroll/RootMargin/RootVBox/MainColumns/LeftPanel/PathButtons
@onready var svg_buttons: HBoxContainer = $Scroll/RootMargin/RootVBox/MainColumns/LeftPanel/SvgButtons
@onready var undo_path_button: Button = $Scroll/RootMargin/RootVBox/MainColumns/LeftPanel/PathButtons/UndoPathButton
@onready var clear_path_button: Button = $Scroll/RootMargin/RootVBox/MainColumns/LeftPanel/PathButtons/ClearPathButton
@onready var export_svg_button: Button = $Scroll/RootMargin/RootVBox/MainColumns/LeftPanel/SvgButtons/ExportSvgButton
@onready var import_svg_button: Button = $Scroll/RootMargin/RootVBox/MainColumns/LeftPanel/SvgButtons/ImportSvgButton
@onready var clear_grid_button: Button = $Scroll/RootMargin/RootVBox/MainColumns/RightPanel/ClearGridButton
@onready var movement_grid: GridContainer = %MovementGrid
@onready var move_kind_option_button: OptionButton = %MoveKindOptionButton
@onready var capture_mode_option_button: OptionButton = %CaptureModeOptionButton
@onready var slide_mode_option_button: OptionButton = %SlideModeOptionButton
@onready var initial_only_check_box: CheckBox = %InitialOnlyCheckBox
@onready var movement_legend_label: Label = %MovementLegendLabel
@onready var message_label: Label = %MessageLabel
@onready var export_svg_file_dialog: FileDialog = $ExportSvgFileDialog
@onready var import_svg_file_dialog: FileDialog = $ImportSvgFileDialog

var movement_buttons: Array[Button] = []
var movement_rules_by_key: Dictionary = {}

var selected_move_kind = MOVE_KIND_JUMP
var selected_capture_mode = CAPTURE_MODE_ANY
var selected_initial_only = false
var selected_slide_scope = SLIDE_SCOPE_INFINITE
var is_editing_piece_mode = false
var editing_piece_id = ""
var helper_label: Label

func _ready() -> void:
	_apply_visual_style()
	piece_strength_spin_box.min_value = 1.0
	piece_strength_spin_box.step = 1.0
	piece_strength_spin_box.rounded = true
	piece_strength_spin_box.value = 3.0
	_build_movement_grid()
	_setup_movement_brush_controls()
	_setup_path_tool_controls()
	_setup_path_template_controls()
	piece_path_canvas.stroke_width_px = 1.8
	piece_path_canvas.fill_color = Color(0.98, 0.98, 0.98, 1.0)
	piece_path_canvas.outline_color = Color(0.08, 0.08, 0.08, 1.0)
	if not piece_path_canvas.strokes_changed.is_connected(_on_piece_path_canvas_strokes_changed):
		piece_path_canvas.strokes_changed.connect(_on_piece_path_canvas_strokes_changed)
	_apply_pending_piece_edit_if_any()
	_refresh_movement_grid_buttons()

func _apply_visual_style() -> void:
	title_label.text = "✦ Create Piece"
	UITheme.apply_title_text(title_label, 27)
	UITheme.apply_body_text(message_label, 14)
	movement_legend_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.95, 1.0))
	UITheme.ensure_atmospheric_background(
		self,
		Vector4(0.12, 0.06, 0.88, 0.20),
		Vector4(0.18, 0.75, 0.82, 0.90),
		Color(0.05, 0.06, 0.08, 1.0),
		Color(0.18, 0.25, 0.36, 0.23),
		Color(0.28, 0.19, 0.14, 0.20)
	)
	_ensure_helper_label()
	_wrap_panelized_column(left_panel, Color(0.10, 0.12, 0.15, 0.96))
	_wrap_panelized_column(right_panel, Color(0.11, 0.13, 0.17, 0.96))
	_style_inputs()
	_style_button_groups()
	_style_canvas_frame()

func _ensure_helper_label() -> void:
	if helper_label != null:
		return
	helper_label = Label.new()
	helper_label.name = "HelperLabel"
	helper_label.layout_mode = 2
	helper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	helper_label.text = "Define your custom piece profile, paint movement rules, and save it for preset use."
	UITheme.apply_body_text(helper_label, 14)
	root_vbox.add_child(helper_label)
	root_vbox.move_child(helper_label, 1)

func _wrap_panelized_column(column: VBoxContainer, fill: Color) -> void:
	if column == null:
		return
	if column.get_parent() is MarginContainer:
		return
	var parent = column.get_parent()
	if parent == null:
		return
	var index = column.get_index()
	parent.remove_child(column)

	var panel = PanelContainer.new()
	panel.layout_mode = 2
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.size_flags_stretch_ratio = column.size_flags_stretch_ratio
	panel.add_theme_stylebox_override("panel", UITheme.panel_style(fill))
	parent.add_child(panel)
	parent.move_child(panel, index)

	var margin = MarginContainer.new()
	margin.layout_mode = 2
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)
	margin.add_child(column)

func _style_inputs() -> void:
	UITheme.apply_field_theme(piece_name_input)
	UITheme.apply_field_theme(piece_id_input)
	UITheme.apply_field_theme(piece_strength_spin_box)
	UITheme.apply_field_theme(move_kind_option_button)
	UITheme.apply_field_theme(capture_mode_option_button)
	UITheme.apply_field_theme(slide_mode_option_button)
	UITheme.apply_field_theme(path_tool_option_button)
	UITheme.apply_field_theme(symmetry_count_spin_box)
	UITheme.apply_field_theme(snap_angle_option_button)
	UITheme.apply_field_theme(template_option_button)

func _style_button_groups() -> void:
	_style_action_button(undo_path_button, Color(0.16, 0.22, 0.34, 1.0))
	_style_action_button(clear_path_button, Color(0.30, 0.20, 0.22, 1.0))
	_style_action_button(export_svg_button, Color(0.17, 0.31, 0.27, 1.0))
	_style_action_button(import_svg_button, Color(0.19, 0.26, 0.37, 1.0))
	_style_action_button(apply_template_button, Color(0.17, 0.25, 0.42, 1.0))
	_style_action_button(clear_grid_button, Color(0.22, 0.20, 0.34, 1.0))
	_style_action_button(save_piece_button, Color(0.16, 0.35, 0.28, 1.0))
	_style_action_button(cancel_button, Color(0.14, 0.15, 0.19, 1.0))

func _style_canvas_frame() -> void:
	piece_path_canvas.add_theme_stylebox_override("panel", UITheme.panel_style(Color(0.12, 0.13, 0.16, 0.98)))

func _style_action_button(button: Button, fill: Color) -> void:
	UITheme.apply_button_theme(button, fill, 40.0, 14)

func _apply_pending_piece_edit_if_any() -> void:
	var game_manager = $"/root/GameManager"
	var pending_piece_id = game_manager.consume_pending_custom_piece_for_edit().strip_edges()
	if pending_piece_id == "":
		title_label.text = "Create Piece"
		save_piece_button.text = "Save Piece"
		piece_id_input.editable = true
		return

	var piece_data = game_manager.get_custom_piece_by_id(pending_piece_id)
	if piece_data.is_empty():
		message_label.text = "The selected custom piece no longer exists."
		return

	is_editing_piece_mode = true
	editing_piece_id = pending_piece_id
	title_label.text = "Edit Piece %s" % str(piece_data.get("name", pending_piece_id))
	save_piece_button.text = "Save Changes"
	piece_name_input.text = str(piece_data.get("name", pending_piece_id))
	piece_id_input.text = str(piece_data.get("id", pending_piece_id))
	piece_id_input.editable = false
	piece_strength_spin_box.value = float(piece_data.get("strength", 1))

	movement_rules_by_key.clear()
	for rule_data in piece_data.get("movement_rules", []):
		var rule = _movement_rule_from_variant(rule_data)
		if rule.is_empty():
			continue
		var offset: Vector2i = rule.get("offset", Vector2i.ZERO)
		var kind = str(rule.get("kind", MOVE_KIND_JUMP))
		var capture_mode = str(rule.get("capture_mode", CAPTURE_MODE_ANY))
		var initial_only = bool(rule.get("initial_only", false))
		var slide_scope = str(rule.get("slide_scope", SLIDE_SCOPE_INFINITE))
		var key = _build_movement_rule_key(kind, offset, capture_mode, initial_only, slide_scope)
		movement_rules_by_key[key] = {
			"x": offset.x,
			"y": offset.y,
			"kind": kind,
			"capture_mode": capture_mode,
			"initial_only": initial_only,
			"slide_scope": slide_scope
		}

	var path_strokes = piece_data.get("path_strokes", [])
	call_deferred("_load_path_strokes_deferred", path_strokes)
	message_label.text = ""

func _load_path_strokes_deferred(path_strokes: Array) -> void:
	piece_path_canvas.set_normalized_strokes(path_strokes)
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
			button.add_theme_stylebox_override("normal", UITheme.button_style(Color(0.11, 0.13, 0.16, 1.0), Color(0.28, 0.32, 0.39, 1.0)))
			button.add_theme_stylebox_override("hover", UITheme.button_style(Color(0.16, 0.19, 0.24, 1.0), UITheme.BUTTON_HIGHLIGHT))
			button.add_theme_stylebox_override("pressed", UITheme.button_style(Color(0.09, 0.11, 0.14, 1.0), UITheme.BUTTON_HIGHLIGHT))
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

func _setup_path_tool_controls() -> void:
	path_tool_option_button.clear()
	path_tool_option_button.add_item("Freehand", int(PiecePathCanvas.ToolMode.FREEHAND))
	path_tool_option_button.add_item("Eraser", int(PiecePathCanvas.ToolMode.ERASER))
	path_tool_option_button.add_item("Line", int(PiecePathCanvas.ToolMode.LINE))
	path_tool_option_button.add_item("Rectangle", int(PiecePathCanvas.ToolMode.RECTANGLE))
	path_tool_option_button.add_item("Ellipse", int(PiecePathCanvas.ToolMode.ELLIPSE))
	path_tool_option_button.selected = int(PiecePathCanvas.ToolMode.FREEHAND)
	if not path_tool_option_button.item_selected.is_connected(_on_path_tool_option_button_item_selected):
		path_tool_option_button.item_selected.connect(_on_path_tool_option_button_item_selected)

	symmetry_check_box.button_pressed = false
	if not symmetry_check_box.toggled.is_connected(_on_symmetry_check_box_toggled):
		symmetry_check_box.toggled.connect(_on_symmetry_check_box_toggled)

	symmetry_count_spin_box.min_value = 1.0
	symmetry_count_spin_box.max_value = 12.0
	symmetry_count_spin_box.step = 1.0
	symmetry_count_spin_box.value = 2.0
	if not symmetry_count_spin_box.value_changed.is_connected(_on_symmetry_count_spin_box_value_changed):
		symmetry_count_spin_box.value_changed.connect(_on_symmetry_count_spin_box_value_changed)

	snap_check_box.button_pressed = true
	if not snap_check_box.toggled.is_connected(_on_snap_check_box_toggled):
		snap_check_box.toggled.connect(_on_snap_check_box_toggled)

	snap_angle_option_button.clear()
	snap_angle_option_button.add_item("45°", 45)
	snap_angle_option_button.add_item("30°", 30)
	snap_angle_option_button.add_item("60°", 60)
	snap_angle_option_button.add_item("90°", 90)
	snap_angle_option_button.selected = 0
	if not snap_angle_option_button.item_selected.is_connected(_on_snap_angle_option_button_item_selected):
		snap_angle_option_button.item_selected.connect(_on_snap_angle_option_button_item_selected)

	_sync_path_tool_settings()

func _sync_path_tool_settings() -> void:
	piece_path_canvas.set_tool(path_tool_option_button.get_selected_id())
	piece_path_canvas.set_symmetry(symmetry_check_box.button_pressed)
	piece_path_canvas.set_symmetry_count(int(symmetry_count_spin_box.value))
	piece_path_canvas.set_snap_enabled(snap_check_box.button_pressed)
	var snap_angle = float(snap_angle_option_button.get_item_id(snap_angle_option_button.selected))
	piece_path_canvas.set_snap_angle_degrees(snap_angle)

func _on_path_tool_option_button_item_selected(index: int) -> void:
	_sync_path_tool_settings()

func _on_symmetry_check_box_toggled(toggled_on: bool) -> void:
	_sync_path_tool_settings()

func _on_symmetry_count_spin_box_value_changed(value: float) -> void:
	_sync_path_tool_settings()

func _on_snap_check_box_toggled(toggled_on: bool) -> void:
	_sync_path_tool_settings()

func _on_snap_angle_option_button_item_selected(index: int) -> void:
	_sync_path_tool_settings()

func _setup_path_template_controls() -> void:
	template_option_button.clear()
	template_option_button.add_item("None", 0)
	template_option_button.add_item("Pawn", 1)
	template_option_button.add_item("Rook", 2)
	template_option_button.add_item("Bishop", 3)
	template_option_button.add_item("Knight", 4)
	template_option_button.add_item("King", 5)
	template_option_button.add_item("Queen", 6)
	template_option_button.selected = 0
	if not apply_template_button.pressed.is_connected(_on_apply_template_button_pressed):
		apply_template_button.pressed.connect(_on_apply_template_button_pressed)

func _on_apply_template_button_pressed() -> void:
	var selected_id = template_option_button.get_selected_id()
	var template_data = _get_template_data_for_id(selected_id)
	if template_data.is_empty():
		message_label.text = "Select a shape template to apply."
		return
	piece_path_canvas.set_template_data(template_data)
	message_label.text = "Applied %s template." % template_option_button.get_item_text(template_option_button.selected)

func _get_template_data_for_id(template_id: int) -> Dictionary:
	match template_id:
		1:
			return _build_pawn_template()
		2:
			return _build_rook_template()
		3:
			return _build_bishop_template()
		4:
			return _build_knight_template()
		5:
			return _build_king_template()
		6:
			return _build_queen_template()
		_:
			return {}

func _build_template_data(strokes: Array, handles: Array) -> Dictionary:
	return {
		"strokes": strokes,
		"handles": handles
	}

func _build_pawn_template() -> Dictionary:
	var strokes: Array = []
	strokes.append(_make_line_stroke([Vector2(0.5, 0.18), Vector2(0.5, 0.78)]))
	strokes.append(_make_curve_stroke([
		Vector2(0.36, 0.26),
		Vector2(0.28, 0.20),
		Vector2(0.34, 0.10),
		Vector2(0.50, 0.10),
		Vector2(0.66, 0.10),
		Vector2(0.72, 0.20),
		Vector2(0.64, 0.26),
		Vector2(0.50, 0.26)
	]))
	strokes.append(_make_line_stroke([Vector2(0.26, 0.78), Vector2(0.74, 0.78)]))
	var handles: Array = [
		{"stroke_index": 0, "point_index": 0, "position": Vector2(0.50, 0.18)},
		{"stroke_index": 0, "point_index": 1, "position": Vector2(0.50, 0.78)},
		{"stroke_index": 1, "point_index": 1, "position": Vector2(0.28, 0.20)},
		{"stroke_index": 1, "point_index": 3, "position": Vector2(0.34, 0.10)},
		{"stroke_index": 1, "point_index": 5, "position": Vector2(0.66, 0.10)},
		{"stroke_index": 2, "point_index": 0, "position": Vector2(0.26, 0.78)},
		{"stroke_index": 2, "point_index": 1, "position": Vector2(0.74, 0.78)}
	]
	return _build_template_data(strokes, handles)

func _build_rook_template() -> Dictionary:
	var strokes: Array = []
	strokes.append(_make_line_stroke([Vector2(0.28, 0.18), Vector2(0.28, 0.76), Vector2(0.72, 0.76), Vector2(0.72, 0.18)]))
	strokes.append(_make_line_stroke([Vector2(0.36, 0.18), Vector2(0.36, 0.08), Vector2(0.64, 0.08), Vector2(0.64, 0.18)]))
	strokes.append(_make_line_stroke([Vector2(0.20, 0.28), Vector2(0.80, 0.28)]))
	strokes.append(_make_line_stroke([Vector2(0.30, 0.76), Vector2(0.30, 0.84), Vector2(0.70, 0.84), Vector2(0.70, 0.76)]))
	var handles: Array = [
		{"stroke_index": 0, "point_index": 0, "position": Vector2(0.28, 0.18)},
		{"stroke_index": 0, "point_index": 2, "position": Vector2(0.72, 0.76)},
		{"stroke_index": 1, "point_index": 1, "position": Vector2(0.36, 0.08)},
		{"stroke_index": 1, "point_index": 2, "position": Vector2(0.64, 0.08)},
		{"stroke_index": 2, "point_index": 0, "position": Vector2(0.20, 0.28)},
		{"stroke_index": 2, "point_index": 1, "position": Vector2(0.80, 0.28)},
		{"stroke_index": 3, "point_index": 0, "position": Vector2(0.30, 0.76)}
	]
	return _build_template_data(strokes, handles)

func _build_bishop_template() -> Dictionary:
	var strokes: Array = []
	strokes.append(_make_line_stroke([Vector2(0.50, 0.12), Vector2(0.50, 0.80)]))
	strokes.append(_make_curve_stroke([
		Vector2(0.40, 0.20),
		Vector2(0.28, 0.32),
		Vector2(0.32, 0.46),
		Vector2(0.50, 0.46),
		Vector2(0.68, 0.46),
		Vector2(0.72, 0.32),
		Vector2(0.60, 0.20),
		Vector2(0.50, 0.20)
	]))
	strokes.append(_make_line_stroke([Vector2(0.25, 0.76), Vector2(0.75, 0.76)]))
	strokes.append(_make_line_stroke([Vector2(0.42, 0.52), Vector2(0.58, 0.52)]))
	var handles: Array = [
		{"stroke_index": 0, "point_index": 0, "position": Vector2(0.50, 0.12)},
		{"stroke_index": 0, "point_index": 1, "position": Vector2(0.50, 0.80)},
		{"stroke_index": 1, "point_index": 1, "position": Vector2(0.28, 0.32)},
		{"stroke_index": 1, "point_index": 4, "position": Vector2(0.68, 0.46)},
		{"stroke_index": 2, "point_index": 0, "position": Vector2(0.25, 0.76)},
		{"stroke_index": 3, "point_index": 0, "position": Vector2(0.42, 0.52)}
	]
	return _build_template_data(strokes, handles)

func _build_knight_template() -> Dictionary:
	var strokes: Array = []
	strokes.append(_make_line_stroke([
		Vector2(0.26, 0.18),
		Vector2(0.34, 0.18),
		Vector2(0.44, 0.26),
		Vector2(0.54, 0.34),
		Vector2(0.62, 0.44),
		Vector2(0.72, 0.58),
		Vector2(0.72, 0.76),
		Vector2(0.46, 0.76),
		Vector2(0.32, 0.58),
		Vector2(0.26, 0.18)
	]))
	strokes.append(_make_line_stroke([Vector2(0.50, 0.18), Vector2(0.50, 0.84)]))
	strokes.append(_make_line_stroke([Vector2(0.38, 0.38), Vector2(0.62, 0.38)]))
	var handles: Array = [
		{"stroke_index": 0, "point_index": 0, "position": Vector2(0.26, 0.18)},
		{"stroke_index": 0, "point_index": 5, "position": Vector2(0.72, 0.58)},
		{"stroke_index": 0, "point_index": 7, "position": Vector2(0.46, 0.76)},
		{"stroke_index": 1, "point_index": 1, "position": Vector2(0.50, 0.84)},
		{"stroke_index": 2, "point_index": 0, "position": Vector2(0.38, 0.38)}
	]
	return _build_template_data(strokes, handles)

func _build_king_template() -> Dictionary:
	var strokes: Array = []
	strokes.append(_make_line_stroke([Vector2(0.50, 0.18), Vector2(0.50, 0.82)]))
	strokes.append(_make_line_stroke([Vector2(0.30, 0.24), Vector2(0.70, 0.24)]))
	strokes.append(_make_line_stroke([Vector2(0.42, 0.18), Vector2(0.42, 0.36), Vector2(0.58, 0.36), Vector2(0.58, 0.18)]))
	strokes.append(_make_line_stroke([Vector2(0.30, 0.36), Vector2(0.70, 0.36)]))
	strokes.append(_make_line_stroke([Vector2(0.30, 0.82), Vector2(0.70, 0.82)]))
	var handles: Array = [
		{"stroke_index": 0, "point_index": 0, "position": Vector2(0.50, 0.18)},
		{"stroke_index": 0, "point_index": 1, "position": Vector2(0.50, 0.82)},
		{"stroke_index": 1, "point_index": 0, "position": Vector2(0.30, 0.24)},
		{"stroke_index": 2, "point_index": 1, "position": Vector2(0.42, 0.36)},
		{"stroke_index": 4, "point_index": 0, "position": Vector2(0.30, 0.82)}
	]
	return _build_template_data(strokes, handles)

func _build_queen_template() -> Dictionary:
	var strokes: Array = []
	strokes.append(_make_line_stroke([Vector2(0.50, 0.16), Vector2(0.50, 0.82)]))
	strokes.append(_make_curve_stroke([
		Vector2(0.34, 0.18),
		Vector2(0.24, 0.30),
		Vector2(0.30, 0.44),
		Vector2(0.40, 0.42),
		Vector2(0.50, 0.42),
		Vector2(0.60, 0.42),
		Vector2(0.70, 0.44),
		Vector2(0.76, 0.30),
		Vector2(0.66, 0.18),
		Vector2(0.50, 0.18)
	]))
	strokes.append(_make_line_stroke([Vector2(0.30, 0.30), Vector2(0.70, 0.30)]))
	strokes.append(_make_line_stroke([Vector2(0.30, 0.82), Vector2(0.70, 0.82)]))
	var handles: Array = [
		{"stroke_index": 0, "point_index": 0, "position": Vector2(0.50, 0.16)},
		{"stroke_index": 0, "point_index": 1, "position": Vector2(0.50, 0.82)},
		{"stroke_index": 1, "point_index": 0, "position": Vector2(0.34, 0.18)},
		{"stroke_index": 1, "point_index": 7, "position": Vector2(0.76, 0.30)},
		{"stroke_index": 3, "point_index": 1, "position": Vector2(0.70, 0.82)}
	]
	return _build_template_data(strokes, handles)

func _make_line_stroke(points: Array) -> Array:
	var stroke: Array = []
	for point in points:
		stroke.append({"x": clampf(float(point.x), 0.0, 1.0), "y": clampf(float(point.y), 0.0, 1.0)})
	return stroke

func _make_curve_stroke(points: Array) -> Array:
	var stroke: Array = []
	for point in points:
		stroke.append({"x": clampf(float(point.x), 0.0, 1.0), "y": clampf(float(point.y), 0.0, 1.0)})
	return stroke

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
			button.disabled = true
			button.modulate = Color(0.92, 0.96, 0.82, 1.0) if piece_path_canvas.has_content() else Color(0.8, 0.7, 0.3, 1.0)
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

func _on_piece_path_canvas_strokes_changed() -> void:
	_refresh_movement_grid_buttons()
	if piece_path_canvas.has_content():
		message_label.text = ""

func _on_undo_path_button_pressed() -> void:
	piece_path_canvas.undo_last_stroke()

func _on_clear_path_button_pressed() -> void:
	piece_path_canvas.clear_strokes()

func _on_export_svg_button_pressed() -> void:
	if not piece_path_canvas.has_content():
		message_label.text = "Draw a piece path before exporting SVG."
		return
	var suggested_name = _sanitize_piece_id(piece_id_input.text if piece_id_input.text.strip_edges() != "" else piece_name_input.text)
	if suggested_name == "":
		suggested_name = "custom_piece"
	export_svg_file_dialog.current_file = "%s.svg" % suggested_name
	export_svg_file_dialog.popup_centered_ratio(0.8)

func _on_import_svg_button_pressed() -> void:
	import_svg_file_dialog.popup_centered_ratio(0.8)

func _on_export_svg_file_dialog_file_selected(path: String) -> void:
	var target_path = path
	if not target_path.to_lower().ends_with(".svg"):
		target_path += ".svg"

	var file = FileAccess.open(target_path, FileAccess.WRITE)
	if file == null:
		message_label.text = "Could not open selected SVG export path."
		return
	file.store_string(_build_svg_document(piece_path_canvas.get_normalized_strokes(), CUSTOM_PATH_STROKE_WIDTH_RATIO))
	message_label.text = "Exported SVG to %s" % target_path

func _on_import_svg_file_dialog_file_selected(path: String) -> void:
	if not FileAccess.file_exists(path):
		message_label.text = "Selected SVG file was not found."
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		message_label.text = "Could not read selected SVG file."
		return

	var parse_result = _parse_svg_text_to_normalized_strokes(file.get_as_text())
	if not bool(parse_result.get("ok", false)):
		message_label.text = str(parse_result.get("error", "Could not parse SVG path."))
		return

	var imported_strokes: Array = parse_result.get("strokes", [])
	if imported_strokes.is_empty():
		message_label.text = "No supported path strokes found in SVG."
		return

	piece_path_canvas.set_normalized_strokes(imported_strokes)
	var imported_point_count = _count_stroke_points(imported_strokes)
	message_label.text = "Imported %d stroke(s), %d point(s)." % [imported_strokes.size(), imported_point_count]
	if imported_point_count >= 2500:
		message_label.text += " Shape is detailed; consider simplifying if editing feels slow."

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
	if is_editing_piece_mode:
		piece_id = editing_piece_id

	if not piece_path_canvas.has_content():
		message_label.text = "Draw the piece path first."
		return

	var movement_data = _build_movement_data()
	if movement_data["movement_rules"].is_empty():
		message_label.text = "Define at least one movement rule."
		return

	var game_manager = $"/root/GameManager"

	var save_result: Dictionary = game_manager.save_custom_piece({
		"id": piece_id,
		"name": piece_name,
		"symbol": piece_name.substr(0, 1).to_upper(),
		"strength": int(piece_strength_spin_box.value),
		"path_strokes": piece_path_canvas.get_normalized_strokes(),
		"path_stroke_width": CUSTOM_PATH_STROKE_WIDTH_RATIO,
		"movement_rules": movement_data["movement_rules"],
		"jump_offsets": movement_data["jump_offsets"],
		"slide_directions": movement_data["slide_directions"]
	})

	if not bool(save_result.get("ok", false)):
		message_label.text = str(save_result.get("error", "Could not save piece."))
		return

	$"/root/GameManager".queue_custom_piece_for_edit("")
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

func _build_svg_document(normalized_strokes: Array, stroke_width_ratio: float) -> String:
	var path_data = _normalized_strokes_to_svg_path_data(normalized_strokes)
	var stroke_width = max(2, int(round(clampf(stroke_width_ratio, 0.01, 0.18) * SVG_EXPORT_VIEWBOX_SIZE)))
	var fill_mode = "none"
	if path_data.strip_edges().ends_with("Z"):
		fill_mode = "#FFFFFF"
	return "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1000 1000\">\n\t<path d=\"%s\" fill=\"%s\" stroke=\"#000000\" stroke-width=\"%d\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>\n</svg>\n" % [path_data, fill_mode, stroke_width]

func _normalized_strokes_to_svg_path_data(normalized_strokes: Array) -> String:
	var commands: Array[String] = []
	for stroke_data in normalized_strokes:
		if not (stroke_data is Array):
			continue
		if stroke_data.size() < 2:
			continue
		var subpath: Array[String] = []
		for point_index in range(stroke_data.size()):
			var point_data = stroke_data[point_index]
			if not (point_data is Dictionary):
				continue
			var x = clampf(float(point_data.get("x", 0.0)), 0.0, 1.0) * SVG_EXPORT_VIEWBOX_SIZE
			var y = clampf(float(point_data.get("y", 0.0)), 0.0, 1.0) * SVG_EXPORT_VIEWBOX_SIZE
			var cmd = "M" if point_index == 0 else "L"
			subpath.append("%s %s %s" % [cmd, _svg_number(x), _svg_number(y)])
		if stroke_data.size() >= 3:
			var first = stroke_data[0]
			var last = stroke_data[stroke_data.size() - 1]
			var first_x = clampf(float(first.get("x", 0.0)), 0.0, 1.0)
			var first_y = clampf(float(first.get("y", 0.0)), 0.0, 1.0)
			var last_x = clampf(float(last.get("x", 0.0)), 0.0, 1.0)
			var last_y = clampf(float(last.get("y", 0.0)), 0.0, 1.0)
			if Vector2(first_x, first_y).distance_to(Vector2(last_x, last_y)) <= 0.04:
				subpath.append("Z")
		commands.append(" ".join(subpath))
	return " ".join(commands)

func _svg_number(value: float) -> String:
	var rounded = round(value * 1000.0) / 1000.0
	var text = str(rounded)
	if text.find(".") != -1:
		while text.ends_with("0"):
			text = text.left(text.length() - 1)
		if text.ends_with("."):
			text = text.left(text.length() - 1)
	return text

func _parse_svg_text_to_normalized_strokes(svg_or_path_text: String) -> Dictionary:
	var source_text = svg_or_path_text.strip_edges()
	if source_text == "":
		return {"ok": false, "error": "SVG text is empty."}

	var d_values = _extract_svg_path_d_values(source_text)
	if d_values.is_empty():
		d_values.append(source_text)

	var all_strokes: Array = []
	for d_value in d_values:
		var parse_result = _parse_svg_path_commands(str(d_value))
		if not bool(parse_result.get("ok", false)):
			return parse_result
		for stroke in parse_result.get("strokes", []):
			all_strokes.append(stroke)

	if all_strokes.is_empty():
		return {"ok": false, "error": "No supported path points were parsed."}

	return {"ok": true, "strokes": _normalize_imported_strokes_to_unit_square(all_strokes)}

func _extract_svg_path_d_values(source_text: String) -> Array[String]:
	var regex = RegEx.new()
	var compile_error = regex.compile("d\\s*=\\s*\"([^\"]+)\"|d\\s*=\\s*'([^']+)'")
	if compile_error != OK:
		return []

	var matches = regex.search_all(source_text)
	var values: Array[String] = []
	for match in matches:
		var quoted_double = match.get_string(1)
		var quoted_single = match.get_string(2)
		var d_value = quoted_double if quoted_double != "" else quoted_single
		if d_value.strip_edges() != "":
			values.append(d_value.strip_edges())
	return values

func _parse_svg_path_commands(path_data: String) -> Dictionary:
	var tokens = _tokenize_svg_path_data(path_data)
	if tokens.is_empty():
		return {"ok": false, "error": "Path data is empty."}

	var strokes: Array = []
	var current_stroke: Array = []
	var current_point = Vector2.ZERO
	var stroke_start = Vector2.ZERO
	var last_cubic_control = Vector2.ZERO
	var has_last_cubic_control = false
	var last_quad_control = Vector2.ZERO
	var has_last_quad_control = false
	var index = 0
	var active_command = ""

	while index < tokens.size():
		var token = str(tokens[index])
		if _is_svg_command_token(token):
			active_command = token
			index += 1
		else:
			if active_command == "":
				return {"ok": false, "error": "Path data missing command before coordinates."}

		match active_command:
			"M", "m":
				if index + 1 >= tokens.size():
					return {"ok": false, "error": "Move command is missing coordinate values."}
				var move_point = _read_svg_point(tokens, index)
				if move_point == null:
					return {"ok": false, "error": "Invalid move command coordinates."}
				index += 2
				if active_command == "m":
					current_point += move_point
				else:
					current_point = move_point
				if current_stroke.size() >= 2:
					strokes.append(current_stroke)
				current_stroke = []
				current_stroke.append(current_point)
				stroke_start = current_point
				has_last_cubic_control = false
				has_last_quad_control = false

				while index + 1 < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var implied_line_point = _read_svg_point(tokens, index)
					if implied_line_point == null:
						break
					index += 2
					if active_command == "m":
						current_point += implied_line_point
					else:
						current_point = implied_line_point
					current_stroke.append(current_point)
					has_last_cubic_control = false
					has_last_quad_control = false
			"L", "l":
				if current_stroke.is_empty():
					return {"ok": false, "error": "Line command appears before move command."}
				if index + 1 >= tokens.size():
					return {"ok": false, "error": "Line command is missing coordinate values."}
				while index + 1 < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var line_point = _read_svg_point(tokens, index)
					if line_point == null:
						return {"ok": false, "error": "Invalid line command coordinates."}
					index += 2
					if active_command == "l":
						current_point += line_point
					else:
						current_point = line_point
					current_stroke.append(current_point)
					has_last_cubic_control = false
					has_last_quad_control = false
			"H", "h":
				if current_stroke.is_empty():
					return {"ok": false, "error": "Horizontal line command appears before move command."}
				while index < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var x_value = _read_svg_number(tokens[index])
					if x_value == null:
						return {"ok": false, "error": "Invalid horizontal line coordinate."}
					index += 1
					current_point.x = current_point.x + float(x_value) if active_command == "h" else float(x_value)
					current_stroke.append(current_point)
					has_last_cubic_control = false
					has_last_quad_control = false
			"V", "v":
				if current_stroke.is_empty():
					return {"ok": false, "error": "Vertical line command appears before move command."}
				while index < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var y_value = _read_svg_number(tokens[index])
					if y_value == null:
						return {"ok": false, "error": "Invalid vertical line coordinate."}
					index += 1
					current_point.y = current_point.y + float(y_value) if active_command == "v" else float(y_value)
					current_stroke.append(current_point)
					has_last_cubic_control = false
					has_last_quad_control = false
			"C", "c":
				if current_stroke.is_empty():
					return {"ok": false, "error": "Cubic curve command appears before move command."}
				while index + 5 < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var c1 = _read_svg_point(tokens, index)
					var c2 = _read_svg_point(tokens, index + 2)
					var end_point = _read_svg_point(tokens, index + 4)
					if c1 == null or c2 == null or end_point == null:
						return {"ok": false, "error": "Invalid cubic curve coordinates."}
					index += 6
					var control1: Vector2 = current_point + c1 if active_command == "c" else c1
					var control2: Vector2 = current_point + c2 if active_command == "c" else c2
					var curve_end: Vector2 = current_point + end_point if active_command == "c" else end_point
					_append_cubic_curve_points(current_stroke, current_point, control1, control2, curve_end)
					current_point = curve_end
					last_cubic_control = control2
					has_last_cubic_control = true
					has_last_quad_control = false
			"S", "s":
				if current_stroke.is_empty():
					return {"ok": false, "error": "Smooth cubic curve command appears before move command."}
				while index + 3 < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var c2 = _read_svg_point(tokens, index)
					var end_point = _read_svg_point(tokens, index + 2)
					if c2 == null or end_point == null:
						return {"ok": false, "error": "Invalid smooth cubic curve coordinates."}
					index += 4
					var reflected_control = current_point * 2.0 - last_cubic_control if has_last_cubic_control else current_point
					var control2: Vector2 = current_point + c2 if active_command == "s" else c2
					var curve_end: Vector2 = current_point + end_point if active_command == "s" else end_point
					_append_cubic_curve_points(current_stroke, current_point, reflected_control, control2, curve_end)
					current_point = curve_end
					last_cubic_control = control2
					has_last_cubic_control = true
					has_last_quad_control = false
			"Q", "q":
				if current_stroke.is_empty():
					return {"ok": false, "error": "Quadratic curve command appears before move command."}
				while index + 3 < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var control = _read_svg_point(tokens, index)
					var end_point = _read_svg_point(tokens, index + 2)
					if control == null or end_point == null:
						return {"ok": false, "error": "Invalid quadratic curve coordinates."}
					index += 4
					var quad_control: Vector2 = current_point + control if active_command == "q" else control
					var curve_end: Vector2 = current_point + end_point if active_command == "q" else end_point
					_append_quadratic_curve_points(current_stroke, current_point, quad_control, curve_end)
					current_point = curve_end
					last_quad_control = quad_control
					has_last_quad_control = true
					has_last_cubic_control = false
			"T", "t":
				if current_stroke.is_empty():
					return {"ok": false, "error": "Smooth quadratic curve command appears before move command."}
				while index + 1 < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var end_point = _read_svg_point(tokens, index)
					if end_point == null:
						return {"ok": false, "error": "Invalid smooth quadratic curve coordinates."}
					index += 2
					var reflected_control = current_point * 2.0 - last_quad_control if has_last_quad_control else current_point
					var curve_end: Vector2 = current_point + end_point if active_command == "t" else end_point
					_append_quadratic_curve_points(current_stroke, current_point, reflected_control, curve_end)
					current_point = curve_end
					last_quad_control = reflected_control
					has_last_quad_control = true
					has_last_cubic_control = false
			"A", "a":
				if current_stroke.is_empty():
					return {"ok": false, "error": "Arc command appears before move command."}
				while index + 6 < tokens.size() and not _is_svg_command_token(str(tokens[index])):
					var rx_raw = _read_svg_number(tokens[index])
					var ry_raw = _read_svg_number(tokens[index + 1])
					var rotation_raw = _read_svg_number(tokens[index + 2])
					var large_arc_raw = _read_svg_number(tokens[index + 3])
					var sweep_raw = _read_svg_number(tokens[index + 4])
					var end_point = _read_svg_point(tokens, index + 5)
					if rx_raw == null or ry_raw == null or rotation_raw == null or large_arc_raw == null or sweep_raw == null or end_point == null:
						return {"ok": false, "error": "Invalid arc command parameters."}
					index += 7
					var arc_end: Vector2 = current_point + end_point if active_command == "a" else end_point
					_append_arc_curve_points(current_stroke, current_point, arc_end, float(rx_raw), float(ry_raw), float(rotation_raw), abs(float(large_arc_raw)) >= 0.5, abs(float(sweep_raw)) >= 0.5)
					current_point = arc_end
					has_last_cubic_control = false
					has_last_quad_control = false
			"Z", "z":
				if not current_stroke.is_empty() and current_stroke[current_stroke.size() - 1] != stroke_start:
					current_stroke.append(stroke_start)
				if current_stroke.size() >= 2:
					strokes.append(current_stroke)
				current_stroke = []
				active_command = ""
				has_last_cubic_control = false
				has_last_quad_control = false
			_:
				return {"ok": false, "error": "Unsupported SVG command: %s." % active_command}

	if current_stroke.size() >= 2:
		strokes.append(current_stroke)

	if strokes.is_empty():
		return {"ok": false, "error": "No drawable strokes found in path data."}
	return {"ok": true, "strokes": _vector_strokes_to_dictionary_strokes(strokes)}

func _tokenize_svg_path_data(path_data: String) -> Array:
	var tokens: Array = []
	var regex = RegEx.new()
	if regex.compile("([MmLlHhVvZzCcSsQqTtAa])|([-+]?(?:\\d*\\.\\d+|\\d+\\.?)(?:[eE][-+]?\\d+)?)") != OK:
		return tokens
	for found in regex.search_all(path_data):
		var command = found.get_string(1)
		var number = found.get_string(2)
		if command != "":
			tokens.append(command)
		elif number != "":
			tokens.append(number)
	return tokens

func _is_svg_command_token(token: String) -> bool:
	return token == "M" or token == "m" or token == "L" or token == "l" or token == "H" or token == "h" or token == "V" or token == "v" or token == "Z" or token == "z" or token == "C" or token == "c" or token == "S" or token == "s" or token == "Q" or token == "q" or token == "T" or token == "t" or token == "A" or token == "a"

func _read_svg_number(token: Variant) -> Variant:
	var text = str(token)
	if text == "":
		return null
	if not text.is_valid_float() and not text.is_valid_int():
		return null
	return float(text)

func _read_svg_point(tokens: Array, index: int) -> Variant:
	if index + 1 >= tokens.size():
		return null
	var x = _read_svg_number(tokens[index])
	var y = _read_svg_number(tokens[index + 1])
	if x == null or y == null:
		return null
	return Vector2(float(x), float(y))

func _append_cubic_curve_points(stroke: Array, start: Vector2, c1: Vector2, c2: Vector2, finish: Vector2) -> void:
	for step in range(1, SVG_CURVE_SEGMENTS + 1):
		var t = float(step) / float(SVG_CURVE_SEGMENTS)
		var omt = 1.0 - t
		var point = omt * omt * omt * start + 3.0 * omt * omt * t * c1 + 3.0 * omt * t * t * c2 + t * t * t * finish
		stroke.append(point)

func _append_quadratic_curve_points(stroke: Array, start: Vector2, control: Vector2, finish: Vector2) -> void:
	for step in range(1, SVG_CURVE_SEGMENTS + 1):
		var t = float(step) / float(SVG_CURVE_SEGMENTS)
		var omt = 1.0 - t
		var point = omt * omt * start + 2.0 * omt * t * control + t * t * finish
		stroke.append(point)

func _append_arc_curve_points(stroke: Array, start: Vector2, finish: Vector2, rx_in: float, ry_in: float, x_axis_rotation_deg: float, large_arc: bool, sweep: bool) -> void:
	if start == finish:
		return

	var rx = absf(rx_in)
	var ry = absf(ry_in)
	if rx <= 0.0001 or ry <= 0.0001:
		stroke.append(finish)
		return

	var phi = deg_to_rad(fposmod(x_axis_rotation_deg, 360.0))
	var cos_phi = cos(phi)
	var sin_phi = sin(phi)

	var half_delta = (start - finish) * 0.5
	var x1p = cos_phi * half_delta.x + sin_phi * half_delta.y
	var y1p = -sin_phi * half_delta.x + cos_phi * half_delta.y

	var rx_sq = rx * rx
	var ry_sq = ry * ry
	var x1p_sq = x1p * x1p
	var y1p_sq = y1p * y1p

	var lambda = x1p_sq / rx_sq + y1p_sq / ry_sq
	if lambda > 1.0:
		var scale = sqrt(lambda)
		rx *= scale
		ry *= scale
		rx_sq = rx * rx
		ry_sq = ry * ry

	var numerator = rx_sq * ry_sq - rx_sq * y1p_sq - ry_sq * x1p_sq
	var denominator = rx_sq * y1p_sq + ry_sq * x1p_sq
	if denominator <= 0.0:
		stroke.append(finish)
		return

	var sign = -1.0 if large_arc == sweep else 1.0
	var coef = sign * sqrt(max(numerator / denominator, 0.0))
	var cxp = coef * (rx * y1p / ry)
	var cyp = coef * (-ry * x1p / rx)

	var midpoint = (start + finish) * 0.5
	var cx = cos_phi * cxp - sin_phi * cyp + midpoint.x
	var cy = sin_phi * cxp + cos_phi * cyp + midpoint.y

	var ux = (x1p - cxp) / rx
	var uy = (y1p - cyp) / ry
	var vx = (-x1p - cxp) / rx
	var vy = (-y1p - cyp) / ry

	var start_angle = atan2(uy, ux)
	var sweep_angle = atan2(ux * vy - uy * vx, ux * vx + uy * vy)
	if not sweep and sweep_angle > 0.0:
		sweep_angle -= TAU
	elif sweep and sweep_angle < 0.0:
		sweep_angle += TAU

	var segment_count = max(4, int(ceil(absf(sweep_angle) / (PI / 8.0))))
	for step in range(1, segment_count + 1):
		var t = float(step) / float(segment_count)
		var angle = start_angle + sweep_angle * t
		var cos_t = cos(angle)
		var sin_t = sin(angle)
		var x = cx + cos_phi * rx * cos_t - sin_phi * ry * sin_t
		var y = cy + sin_phi * rx * cos_t + cos_phi * ry * sin_t
		stroke.append(Vector2(x, y))

func _vector_strokes_to_dictionary_strokes(vector_strokes: Array) -> Array:
	var result: Array = []
	for vector_stroke in vector_strokes:
		if not (vector_stroke is Array):
			continue
		var serialized: Array = []
		for point in vector_stroke:
			if point is Vector2:
				var vector_point: Vector2 = point
				serialized.append({"x": vector_point.x, "y": vector_point.y})
		if serialized.size() >= 2:
			result.append(serialized)
	return result

func _normalize_imported_strokes_to_unit_square(raw_strokes: Array) -> Array:
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	for stroke_data in raw_strokes:
		if not (stroke_data is Array):
			continue
		for point_data in stroke_data:
			if not (point_data is Dictionary):
				continue
			var x = float(point_data.get("x", 0.0))
			var y = float(point_data.get("y", 0.0))
			min_x = min(min_x, x)
			min_y = min(min_y, y)
			max_x = max(max_x, x)
			max_y = max(max_y, y)

	if min_x == INF or min_y == INF or max_x == -INF or max_y == -INF:
		return []

	var width = max(max_x - min_x, 1.0)
	var height = max(max_y - min_y, 1.0)
	var scale = 1.0 / max(width, height)
	var offset_x = (1.0 - width * scale) * 0.5
	var offset_y = (1.0 - height * scale) * 0.5

	var normalized: Array = []
	for stroke_data in raw_strokes:
		if not (stroke_data is Array):
			continue
		var normalized_stroke: Array = []
		for point_data in stroke_data:
			if not (point_data is Dictionary):
				continue
			var px = (float(point_data.get("x", 0.0)) - min_x) * scale + offset_x
			var py = (float(point_data.get("y", 0.0)) - min_y) * scale + offset_y
			normalized_stroke.append({
				"x": clampf(px, 0.0, 1.0),
				"y": clampf(py, 0.0, 1.0)
			})
		if normalized_stroke.size() >= 2:
			normalized.append(normalized_stroke)

	return normalized

func _count_stroke_points(strokes: Array) -> int:
	var total = 0
	for stroke_data in strokes:
		if stroke_data is Array:
			total += (stroke_data as Array).size()
	return total
