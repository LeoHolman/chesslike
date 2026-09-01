extends Control

const BUILTIN_PRESETS = {
	"Standard Chess": "standard_chess",
	"Standard Shogi": "standard_shogi"
}

@onready var preset_list: ItemList = $PresetList
@onready var rename_input: LineEdit = $RenameInput
@onready var message_label: Label = $MessageLabel
@onready var export_dialog: FileDialog = $ExportDialog
@onready var import_dialog: FileDialog = $ImportDialog
@onready var delete_confirm_dialog: ConfirmationDialog = $DeleteConfirmDialog

var pending_delete_preset_name = ""

func _ready() -> void:
	preset_list.item_selected.connect(_on_preset_selected)
	export_dialog.file_selected.connect(_on_export_file_selected)
	import_dialog.file_selected.connect(_on_import_file_selected)
	delete_confirm_dialog.confirmed.connect(_on_delete_confirmed)
	_refresh_preset_list()
	_message("Select a preset to manage.")

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
