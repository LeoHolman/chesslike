extends Control

const UITheme = preload("res://Scripts/ui_theme.gd")

const BUILTIN_PRESETS = {
	"Standard Chess": "standard_chess",
	"Standard Shogi": "standard_shogi",
	"Gungi": "gungi"
}
const ACTION_BUTTON_FILL = Color(0.14, 0.15, 0.18, 1.0)
const ACTION_BUTTON_BORDER = Color(0.30, 0.34, 0.40, 1.0)
const ACTION_BUTTON_HIGHLIGHT = Color(0.94, 0.82, 0.56, 1.0)

@onready var title_label: Label = $Title
@onready var preset_list: ItemList = $PresetList
@onready var rename_input: LineEdit = $RenameInput
@onready var rename_button: Button = $RenameButton
@onready var edit_button: Button = $EditButton
@onready var delete_button: Button = $DeleteButton
@onready var export_button: Button = $ExportButton
@onready var import_preset_button: Button = $ImportPresetButton
@onready var back_button: Button = $BackButton
@onready var message_label: Label = $MessageLabel
@onready var export_dialog: FileDialog = $ExportDialog
@onready var import_dialog: FileDialog = $ImportDialog
@onready var delete_confirm_dialog: ConfirmationDialog = $DeleteConfirmDialog

var pending_delete_preset_name = ""
var helper_label: Label
var layout_panel: PanelContainer

func _ready() -> void:
	preset_list.item_selected.connect(_on_preset_selected)
	export_dialog.file_selected.connect(_on_export_file_selected)
	import_dialog.file_selected.connect(_on_import_file_selected)
	delete_confirm_dialog.confirmed.connect(_on_delete_confirmed)
	_setup_polished_layout()
	_refresh_preset_list()
	_message("Select a preset to manage.")

func _setup_polished_layout() -> void:
	title_label.text = _icon_text("▤", "Manage Presets")
	UITheme.apply_title_text(title_label, 26)
	UITheme.ensure_atmospheric_background(self)
	_ensure_helper_label()
	_ensure_layout_panel()
	_style_action_buttons()
	_animate_layout_entry()

func _ensure_helper_label() -> void:
	if helper_label != null:
		return
	helper_label = Label.new()
	helper_label.name = "HelperLabel"
	helper_label.layout_mode = 0
	helper_label.offset_left = 80.0
	helper_label.offset_top = 82.0
	helper_label.offset_right = 930.0
	helper_label.offset_bottom = 122.0
	helper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	helper_label.text = "Browse built-in or custom presets, then rename, export, import, or jump into editing."
	UITheme.apply_body_text(helper_label, 14)
	add_child(helper_label)

func _ensure_layout_panel() -> void:
	if layout_panel != null:
		return
	layout_panel = PanelContainer.new()
	layout_panel.name = "LayoutPanel"
	layout_panel.layout_mode = 0
	layout_panel.offset_left = 78.0
	layout_panel.offset_top = 132.0
	layout_panel.offset_right = 940.0
	layout_panel.offset_bottom = 588.0
	var panel_style = UITheme.panel_style(Color(0.08, 0.09, 0.11, 0.96))
	layout_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(layout_panel)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	layout_panel.add_child(margin)

	var root = HBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 18)
	margin.add_child(root)

	root.add_child(_build_presets_column())
	root.add_child(_build_actions_column())

func _build_presets_column() -> VBoxContainer:
	var column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	column.add_child(_panel_heading("▤", "Preset Library"))
	var list_panel = _make_inner_panel()
	column.add_child(list_panel)
	var list_margin = _make_panel_margin()
	list_panel.add_child(list_margin)
	if preset_list.get_parent() != null:
		preset_list.get_parent().remove_child(preset_list)
	preset_list.layout_mode = 2
	preset_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preset_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preset_list.custom_minimum_size = Vector2(0.0, 344.0)
	list_margin.add_child(preset_list)
	return column

func _build_actions_column() -> VBoxContainer:
	var column = VBoxContainer.new()
	column.custom_minimum_size = Vector2(340.0, 0.0)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	column.add_child(_panel_heading("✎", "Actions"))
	var action_panel = _make_inner_panel()
	column.add_child(action_panel)
	var margin = _make_panel_margin()
	action_panel.add_child(margin)
	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	if rename_input.get_parent() != null:
		rename_input.get_parent().remove_child(rename_input)
	rename_input.layout_mode = 2
	rename_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(rename_input)
	content.add_child(_button_row(rename_button, edit_button))
	content.add_child(_button_row(delete_button, export_button))
	content.add_child(_button_row(import_preset_button, back_button))
	if message_label.get_parent() != null:
		message_label.get_parent().remove_child(message_label)
	message_label.layout_mode = 2
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.custom_minimum_size = Vector2(0.0, 108.0)
	content.add_child(_panel_heading("ℹ", "Status"))
	content.add_child(message_label)
	return column

func _panel_heading(icon: String, text: String) -> Label:
	var label = Label.new()
	label.text = _icon_text(icon, text)
	UITheme.apply_section_text(label, 18)
	return label

func _make_inner_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var style = UITheme.panel_style(Color(0.12, 0.13, 0.16, 1.0), Color(0.25, 0.28, 0.34, 1.0), 10, 1)
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _make_panel_margin() -> MarginContainer:
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	return margin

func _button_row(left_button: Button, right_button: Button) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	for button in [left_button, right_button]:
		if button.get_parent() != null:
			button.get_parent().remove_child(button)
		button.layout_mode = 2
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(button)
	return row

func _style_action_buttons() -> void:
	rename_button.text = _icon_text("↺", "Rename")
	edit_button.text = _icon_text("✎", "Edit")
	delete_button.text = _icon_text("×", "Delete")
	export_button.text = _icon_text("⇪", "Export")
	import_preset_button.text = _icon_text("⇩", "Import Preset")
	back_button.text = _icon_text("←", "Back to Main Menu")
	UITheme.apply_field_theme(rename_input)
	for button in [rename_button, edit_button, delete_button, export_button, import_preset_button, back_button]:
		UITheme.apply_button_theme(button, ACTION_BUTTON_FILL, 38.0, 14, ACTION_BUTTON_BORDER, ACTION_BUTTON_HIGHLIGHT, Color(0.95, 0.97, 1.0, 1.0))

func _animate_layout_entry() -> void:
	if helper_label != null:
		helper_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var helper_tween = create_tween()
		helper_tween.tween_property(helper_label, "modulate:a", 1.0, 0.16)
	if layout_panel != null:
		layout_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
		layout_panel.scale = Vector2(0.99, 0.99)
		var panel_tween = create_tween()
		panel_tween.set_parallel(true)
		panel_tween.tween_property(layout_panel, "modulate:a", 1.0, 0.16)
		panel_tween.tween_property(layout_panel, "scale", Vector2.ONE, 0.16)

func _icon_text(icon: String, text: String) -> String:
	if icon == "":
		return text
	return "%s  %s" % [icon, text]

func _refresh_preset_list() -> void:
	preset_list.clear()
	for preset_name in BUILTIN_PRESETS.keys():
		preset_list.add_item(str(preset_name))
	var custom_names = $"/root/GameManager".SavedPresets.keys()
	custom_names.sort()
	for preset_name in custom_names:
		preset_list.add_item(str(preset_name))

func _selected_preset_name() -> String:
	var selected = preset_list.get_selected_items()
	if selected.is_empty():
		return ""
	return preset_list.get_item_text(int(selected[0]))

func _is_builtin_preset_name(preset_name: String) -> bool:
	return BUILTIN_PRESETS.has(preset_name)

func _on_preset_selected(_index: int) -> void:
	var preset_name = _selected_preset_name()
	if preset_name == "":
		return
	if _is_builtin_preset_name(preset_name):
		rename_input.placeholder_text = "Built-in presets cannot be renamed"
	else:
		rename_input.placeholder_text = "Rename preset"
	rename_input.text = ""
	_message("Selected: %s" % preset_name)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_edit_button_pressed() -> void:
	var preset_name = _selected_preset_name()
	if preset_name == "":
		_message("Select a preset first.")
		return
	$"/root/GameManager".queue_preset_for_edit(preset_name)
	get_tree().change_scene_to_file("res://Scenes/LocalGameMenu.tscn")

func _on_delete_button_pressed() -> void:
	var preset_name = _selected_preset_name()
	if preset_name == "":
		_message("Select a preset first.")
		return
	if _is_builtin_preset_name(preset_name):
		_message("Built-in presets cannot be deleted.")
		return
	pending_delete_preset_name = preset_name
	delete_confirm_dialog.dialog_text = "Delete preset '%s'? This cannot be undone." % preset_name
	delete_confirm_dialog.popup_centered()

func _on_delete_confirmed() -> void:
	if pending_delete_preset_name == "":
		return
	var preset_name = pending_delete_preset_name
	pending_delete_preset_name = ""
	if $"/root/GameManager".delete_preset(preset_name):
		_refresh_preset_list()
		_message("Deleted preset: %s" % preset_name)
		return
	_message("Could not delete preset.")

func _on_rename_button_pressed() -> void:
	var source_name = _selected_preset_name()
	if source_name == "":
		_message("Select a preset first.")
		return
	if _is_builtin_preset_name(source_name):
		_message("Built-in presets cannot be renamed.")
		return
	var target_name = rename_input.text.strip_edges()
	if target_name == "":
		_message("Enter a new preset name.")
		return
	var rename_result: Dictionary = $"/root/GameManager".rename_saved_preset(source_name, target_name)
	if not bool(rename_result.get("ok", false)):
		_message(str(rename_result.get("error", "Could not rename preset.")))
		return
	rename_input.text = ""
	_refresh_preset_list()
	_select_preset(target_name)
	_message("Renamed preset to: %s" % target_name)

func _on_export_button_pressed() -> void:
	var preset_name = _selected_preset_name()
	if preset_name == "":
		_message("Select a preset first.")
		return
	var safe_file_name = preset_name.to_lower().replace(" ", "_")
	export_dialog.current_file = "%s.json" % safe_file_name
	export_dialog.popup_centered_ratio(0.65)

func _on_import_preset_button_pressed() -> void:
	import_dialog.popup_centered_ratio(0.65)

func _on_export_file_selected(path: String) -> void:
	var preset_name = _selected_preset_name()
	if preset_name == "":
		_message("Select a preset first.")
		return
	var config = _preset_config_by_name(preset_name)
	if config.is_empty():
		_message("Could not build preset config for export.")
		return
	var payload = {
		"name": preset_name,
		"preset_config": config
	}
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_message("Could not write export file.")
		return
	file.store_string(JSON.stringify(payload, "\t"))
	_message("Exported preset to: %s" % path)

func _on_import_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		_message("Could not open import file.")
		return
	var parsed_json = JSON.parse_string(file.get_as_text())
	if not (parsed_json is Dictionary):
		_message("Import file must be a JSON object.")
		return

	var imported_name = str(parsed_json.get("name", parsed_json.get("preset_name", ""))).strip_edges()
	var imported_config = parsed_json.get("preset_config", parsed_json.get("config", {}))
	if imported_name == "":
		imported_name = path.get_file().get_basename().strip_edges()
	if not (imported_config is Dictionary):
		imported_config = parsed_json
	if not (imported_config is Dictionary):
		_message("Import file does not contain a preset config object.")
		return
	if BUILTIN_PRESETS.has(imported_name):
		_message("Imported preset name conflicts with built-in preset.")
		return
	if $"/root/GameManager".SavedPresets.has(imported_name):
		_message("A preset with that name already exists.")
		return
	$"/root/GameManager".save_preset(imported_name, imported_config)
	_refresh_preset_list()
	_select_preset(imported_name)
	_message("Imported preset: %s" % imported_name)

func _preset_config_by_name(preset_name: String) -> Dictionary:
	if BUILTIN_PRESETS.has(preset_name):
		return _builtin_preset_config(str(BUILTIN_PRESETS[preset_name]))
	var saved: Dictionary = $"/root/GameManager".SavedPresets
	if saved.has(preset_name):
		return (saved[preset_name] as Dictionary).duplicate(true)
	return {}

func _builtin_preset_config(preset_id: String) -> Dictionary:
	if preset_id == "gungi":
		return {
			"width": 9,
			"height": 9,
			"pieces": [],
			"drop_pools": {
				"white": ["lance", "shogi_knight", "silver_general", "gold_general", "king", "gold_general", "silver_general", "shogi_knight", "lance", "rook", "bishop", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn"],
				"black": ["lance", "shogi_knight", "silver_general", "gold_general", "king", "gold_general", "silver_general", "shogi_knight", "lance", "rook", "bishop", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn"]
			},
			"victory_condition": "checkmate",
			"special_rules": {
				"castling": false,
				"en_passant": false,
				"promotion": false,
				"allow_undo": false,
				"enable_spell_cards": false,
				"piece_dropping": true,
				"piece_stacking": true,
				"enable_territory": true,
				"enable_muster": true,
				"capture_to_drop_pool": true,
				"limit_army_strength": false,
				"unbalanced_armies": false
			},
			"spell_cards": {
				"hand_size": 0,
				"unbalanced_hand_sizes": false,
				"hand_size_white": 0,
				"hand_size_black": 0,
				"random_cards": true,
				"allow_duplicates": true,
				"draw_replacement_after_cast": false,
				"available_cards": ["haste", "assassinate", "fortify", "teleport", "barrier"],
				"starting_hands": {"white": [], "black": []}
			},
			"army_strength_cap": 32,
			"army_strength_caps": {"white": 32, "black": 32},
			"promotion_pieces": ["rook", "bishop", "silver_general", "gold_general", "lance", "shogi_knight", "shogi_pawn"],
			"promotion_zones": {"white_rows": 3, "black_rows": 3},
			"territory_rows": 3,
			"player_colors": {},
			"tile_colors": {}
		}
	if preset_id == "standard_shogi":
		return {
			"width": 9,
			"height": 9,
			"pieces": _standard_shogi_pieces(),
			"drop_pools": {"white": [], "black": []},
			"victory_condition": "checkmate",
			"special_rules": {
				"castling": false,
				"en_passant": false,
				"promotion": false,
				"allow_undo": false,
				"enable_spell_cards": false,
				"piece_dropping": true,
				"piece_stacking": false,
				"enable_territory": false,
				"enable_muster": false,
				"capture_to_drop_pool": true,
				"limit_army_strength": false,
				"unbalanced_armies": false
			},
			"spell_cards": {
				"hand_size": 3,
				"unbalanced_hand_sizes": false,
				"hand_size_white": 3,
				"hand_size_black": 3,
				"random_cards": true,
				"allow_duplicates": true,
				"draw_replacement_after_cast": false,
				"available_cards": ["haste", "assassinate", "fortify", "teleport", "barrier"],
				"starting_hands": {"white": [], "black": []}
			},
			"army_strength_cap": 32,
			"army_strength_caps": {"white": 32, "black": 32},
			"promotion_pieces": ["rook", "bishop", "silver_general", "gold_general", "lance", "shogi_knight", "shogi_pawn"],
			"promotion_zones": {"white_rows": 3, "black_rows": 3},
			"territory_rows": 3,
			"player_colors": {},
			"tile_colors": {}
		}
	return {
		"width": 8,
		"height": 8,
		"pieces": _standard_chess_pieces(),
		"drop_pools": {"white": [], "black": []},
		"victory_condition": "checkmate",
		"special_rules": {
			"castling": true,
			"en_passant": true,
			"promotion": true,
			"allow_undo": false,
			"enable_spell_cards": false,
			"piece_dropping": false,
			"piece_stacking": false,
			"enable_territory": false,
			"enable_muster": false,
			"capture_to_drop_pool": false,
			"limit_army_strength": false,
			"unbalanced_armies": false
		},
		"spell_cards": {
			"hand_size": 3,
			"unbalanced_hand_sizes": false,
			"hand_size_white": 3,
			"hand_size_black": 3,
			"random_cards": true,
			"allow_duplicates": true,
			"draw_replacement_after_cast": false,
			"available_cards": ["haste", "assassinate", "fortify", "teleport", "barrier"],
			"starting_hands": {"white": [], "black": []}
		},
		"army_strength_cap": 32,
		"army_strength_caps": {"white": 32, "black": 32},
		"promotion_pieces": ["queen", "rook", "bishop", "knight"],
		"promotion_zones": {"white_rows": 1, "black_rows": 1},
		"territory_rows": 2,
		"player_colors": {},
		"tile_colors": {}
	}

func _standard_chess_pieces() -> Array:
	var pieces: Array = []
	var back_rank = ["rook", "knight", "bishop", "queen", "king", "bishop", "knight", "rook"]
	for x in range(8):
		pieces.append({"x": x, "y": 0, "piece_id": back_rank[x], "color": "black", "has_moved": false})
		pieces.append({"x": x, "y": 1, "piece_id": "pawn", "color": "black", "has_moved": false})
		pieces.append({"x": x, "y": 6, "piece_id": "pawn", "color": "white", "has_moved": false})
		pieces.append({"x": x, "y": 7, "piece_id": back_rank[x], "color": "white", "has_moved": false})
	return pieces

func _standard_shogi_pieces() -> Array:
	var pieces: Array = []
	var back_rank = ["lance", "shogi_knight", "silver_general", "gold_general", "king", "gold_general", "silver_general", "shogi_knight", "lance"]
	for x in range(9):
		pieces.append({"x": x, "y": 0, "piece_id": back_rank[x], "color": "black", "has_moved": false})
		pieces.append({"x": x, "y": 2, "piece_id": "shogi_pawn", "color": "black", "has_moved": false})
		pieces.append({"x": x, "y": 6, "piece_id": "shogi_pawn", "color": "white", "has_moved": false})
		pieces.append({"x": x, "y": 8, "piece_id": back_rank[x], "color": "white", "has_moved": false})
	pieces.append({"x": 1, "y": 1, "piece_id": "rook", "color": "black", "has_moved": false})
	pieces.append({"x": 7, "y": 1, "piece_id": "bishop", "color": "black", "has_moved": false})
	pieces.append({"x": 1, "y": 7, "piece_id": "bishop", "color": "white", "has_moved": false})
	pieces.append({"x": 7, "y": 7, "piece_id": "rook", "color": "white", "has_moved": false})
	return pieces

func _select_preset(target_name: String) -> void:
	for i in range(preset_list.item_count):
		if preset_list.get_item_text(i) == target_name:
			preset_list.select(i)
			preset_list.ensure_current_is_visible()
			return

func _message(value: String) -> void:
	message_label.text = value
	message_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.12)
