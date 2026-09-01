extends Control

@onready var width_spin_box: SpinBox = $OptionsScroll/OptionsContent/WidthSpinBox
@onready var height_spin_box: SpinBox = $OptionsScroll/OptionsContent/HeightSpinBox
@onready var local_game_title: Label = $OptionsScroll/OptionsContent/LocalGameTitle
@onready var back_to_main_menu_button: Button = $BackToMainMenuButton
@onready var start_game_button: Button = $StartGameButton
@onready var board_preview: Control = $PreviewArea/BoardPreview
@onready var options_content: Control = $OptionsScroll/OptionsContent
@onready var preview_warning_label: Label = $PreviewWarningLabel
@onready var piece_bank_list: ItemList = $OptionsScroll/OptionsContent/PieceBankList
@onready var piece_color_option: OptionButton = $OptionsScroll/OptionsContent/PieceColorOption
@onready var preset_list: ItemList = $OptionsScroll/OptionsContent/PresetList
@onready var preset_name_input: LineEdit = $OptionsScroll/OptionsContent/PresetNameInput
@onready var castling_check_box: CheckBox = $OptionsScroll/OptionsContent/CastlingCheckBox
@onready var en_passant_check_box: CheckBox = $OptionsScroll/OptionsContent/EnPassantCheckBox
@onready var promotion_check_box: CheckBox = $OptionsScroll/OptionsContent/PromotionCheckBox
@onready var allow_undo_check_box: CheckBox = $OptionsScroll/OptionsContent/AllowUndoCheckBox
@onready var promotion_zones_title_background: ColorRect = $OptionsScroll/OptionsContent/PromotionZonesTitleBackground
@onready var promotion_zones_title: Label = $OptionsScroll/OptionsContent/PromotionZonesTitle
@onready var player1_promotion_zone_label: Label = $OptionsScroll/OptionsContent/Player1PromotionZoneLabel
@onready var player1_promotion_zone_spin_box: SpinBox = $OptionsScroll/OptionsContent/Player1PromotionZoneSpinBox
@onready var player2_promotion_zone_label: Label = $OptionsScroll/OptionsContent/Player2PromotionZoneLabel
@onready var player2_promotion_zone_spin_box: SpinBox = $OptionsScroll/OptionsContent/Player2PromotionZoneSpinBox
@onready var piece_dropping_check_box: CheckBox = $OptionsScroll/OptionsContent/PieceDroppingCheckBox
@onready var capture_to_drop_pool_check_box: CheckBox = $OptionsScroll/OptionsContent/CaptureToDropPoolCheckBox
@onready var limit_army_strength_check_box: CheckBox = $OptionsScroll/OptionsContent/LimitArmyStrengthCheckBox
@onready var unbalanced_armies_check_box: CheckBox = $OptionsScroll/OptionsContent/UnbalancedArmiesCheckBox
@onready var army_strength_cap_label: Label = $OptionsScroll/OptionsContent/ArmyStrengthCapLabel
@onready var army_strength_cap_spin_box: SpinBox = $OptionsScroll/OptionsContent/ArmyStrengthCapSpinBox
@onready var white_army_strength_cap_label: Label = $OptionsScroll/OptionsContent/WhiteArmyStrengthCapLabel
@onready var white_army_strength_cap_spin_box: SpinBox = $OptionsScroll/OptionsContent/WhiteArmyStrengthCapSpinBox
@onready var black_army_strength_cap_label: Label = $OptionsScroll/OptionsContent/BlackArmyStrengthCapLabel
@onready var black_army_strength_cap_spin_box: SpinBox = $OptionsScroll/OptionsContent/BlackArmyStrengthCapSpinBox
@onready var army_strength_warning_label: Label = $OptionsScroll/OptionsContent/ArmyStrengthWarningLabel
@onready var castling_support_hint_background: ColorRect = $OptionsScroll/OptionsContent/CastlingSupportHintBackground
@onready var castling_support_hint: Label = $OptionsScroll/OptionsContent/CastlingSupportHint
@onready var player1_color_button: ColorPickerButton = $OptionsScroll/OptionsContent/Player1ColorButton
@onready var player2_color_button: ColorPickerButton = $OptionsScroll/OptionsContent/Player2ColorButton
@onready var light_tile_color_button: ColorPickerButton = $OptionsScroll/OptionsContent/LightTileColorButton
@onready var dark_tile_color_button: ColorPickerButton = $OptionsScroll/OptionsContent/DarkTileColorButton
@onready var victory_condition_option: OptionButton = $OptionsScroll/OptionsContent/VictoryConditionOption
@onready var victory_condition_description: Label = $OptionsScroll/OptionsContent/VictoryConditionDescription
@onready var promotion_pieces_title_background: ColorRect = $OptionsScroll/OptionsContent/PromotionPiecesTitleBackground
@onready var promotion_pieces_title: Label = $OptionsScroll/OptionsContent/PromotionPiecesTitle
@onready var promotion_pieces_list: VBoxContainer = $OptionsScroll/OptionsContent/PromotionPiecesScroll/PromotionPiecesList
@onready var enable_spell_cards_check_box: CheckBox = $OptionsScroll/OptionsContent/EnableSpellCardsCheckBox
@onready var spell_hand_size_label: Label = $OptionsScroll/OptionsContent/SpellHandSizeLabel
@onready var spell_hand_size_spin_box: SpinBox = $OptionsScroll/OptionsContent/SpellHandSizeSpinBox
@onready var spell_unbalanced_hand_sizes_check_box: CheckBox = $OptionsScroll/OptionsContent/SpellUnbalancedHandSizesCheckBox
@onready var spell_hand_size_white_label: Label = $OptionsScroll/OptionsContent/SpellHandSizeWhiteLabel
@onready var spell_hand_size_white_spin_box: SpinBox = $OptionsScroll/OptionsContent/SpellHandSizeWhiteSpinBox
@onready var spell_hand_size_black_label: Label = $OptionsScroll/OptionsContent/SpellHandSizeBlackLabel
@onready var spell_hand_size_black_spin_box: SpinBox = $OptionsScroll/OptionsContent/SpellHandSizeBlackSpinBox
@onready var random_spell_cards_check_box: CheckBox = $OptionsScroll/OptionsContent/RandomSpellCardsCheckBox
@onready var spell_allow_duplicates_check_box: CheckBox = $OptionsScroll/OptionsContent/SpellAllowDuplicatesCheckBox
@onready var spell_draw_replacement_after_cast_check_box: CheckBox = $OptionsScroll/OptionsContent/SpellDrawReplacementAfterCastCheckBox
@onready var spell_assign_card_label: Label = $OptionsScroll/OptionsContent/SpellAssignCardLabel
@onready var spell_assign_card_option: OptionButton = $OptionsScroll/OptionsContent/SpellAssignCardOption
@onready var spell_cards_hint_label: Label = $OptionsScroll/OptionsContent/SpellCardsHintLabel
@onready var available_spell_cards_title_background: ColorRect = $OptionsScroll/OptionsContent/AvailableSpellCardsTitleBackground
@onready var available_spell_cards_title: Label = $OptionsScroll/OptionsContent/AvailableSpellCardsTitle
@onready var available_spell_cards_scroll: ScrollContainer = $OptionsScroll/OptionsContent/AvailableSpellCardsScroll
@onready var available_spell_cards_list: VBoxContainer = $OptionsScroll/OptionsContent/AvailableSpellCardsScroll/AvailableSpellCardsList

const INVALID_SQUARE = Vector2i(-1, -1)
const PREVIEW_SELECTION_HIGHLIGHT = Color(0.2, 0.6, 1.0, 0.28)
const PREVIEW_GHOST_TINT = Color(1.0, 1.0, 1.0, 0.45)
const PREVIEW_WHITE_DROP_POOL_BACKGROUND = Color(0.18, 0.24, 0.38, 0.86)
const PREVIEW_BLACK_DROP_POOL_BACKGROUND = Color(0.34, 0.18, 0.18, 0.86)
const PREVIEW_DROP_POOL_BORDER = Color(0.82, 0.85, 0.92, 0.95)
const PREVIEW_WHITE_DROP_POOL_HOVER_BACKGROUND = Color(0.26, 0.36, 0.56, 0.92)
const PREVIEW_BLACK_DROP_POOL_HOVER_BACKGROUND = Color(0.46, 0.24, 0.24, 0.92)
const PREVIEW_SPELL_HAND_BORDER = Color(0.92, 0.95, 1.0, 0.95)
const PRESETS = {
	"Standard Chess": "standard_chess",
	"Standard Shogi": "standard_shogi",
	"Gungi": "gungi"
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
var preview_spell_hands = {
	"white": [],
	"black": []
}
var preview_white_spell_hand_rect = Rect2()
var preview_black_spell_hand_rect = Rect2()
var preview_spell_hand_entry_rects = {
	"white": [],
	"black": []
}
var preview_spell_hand_scroll_offsets = {
	"white": 0,
	"black": 0
}
var preview_spell_hand_viewport_rects = {
	"white": Rect2(),
	"black": Rect2()
}
var dragging_preview_piece = false
var drag_piece_origin_square = INVALID_SQUARE
var dragging_piece_bank_piece = false
var piece_bank_drag_piece_id = ""
var piece_bank_drag_piece_color = "white"
var piece_bank_drag_preview_position = Vector2.ZERO
var preview_drop_pool_hover_owner = ""
var preview_drop_pool_scroll_offsets = {
	"white": 0,
	"black": 0
}
var preview_drop_pool_viewport_rects = {
	"white": Rect2(),
	"black": Rect2()
}
var is_updating_army_strength_cap = false
var is_updating_unbalanced_army_strength_caps = false
var is_updating_spell_hand_sizes = false
var preview_warning_message_serial = 0
var is_editing_preset_mode = false
var editing_preset_name = ""
var spell_card_checkboxes: Dictionary = {}
var spell_assign_card_ids: Array[String] = []
var selected_spell_card_id = ""
var piece_stacking_check_box: CheckBox
var enable_territory_check_box: CheckBox
var enable_muster_check_box: CheckBox
var territory_rows_label: Label
var territory_rows_spin_box: SpinBox
var player_side_colors = {
	"white": Color(1.0, 1.0, 1.0, 1.0),
	"black": Color(0.08, 0.08, 0.08, 1.0)
}
var board_tile_colors = {
	"light": Color(1.0, 1.0, 1.0, 1.0),
	"dark": Color(0.41, 0.41, 0.41, 1.0)
}

func _ready() -> void:
	width_spin_box.value_changed.connect(_on_board_dimension_changed)
	height_spin_box.value_changed.connect(_on_board_dimension_changed)
	board_preview.gui_input.connect(_on_board_preview_gui_input)
	piece_bank_list.gui_input.connect(_on_piece_bank_gui_input)
	board_preview.resized.connect(_refresh_preview)
	board_preview.mouse_exited.connect(_on_board_preview_mouse_exited)
	preset_list.item_selected.connect(_on_preset_item_selected)
	_populate_piece_bank()
	_populate_presets()
	_setup_piece_color_picker()
	_setup_player_color_pickers()
	_setup_tile_color_pickers()
	_setup_victory_condition_picker()
	_setup_special_rules()
	_reset_preview_to_default(false, false)
	_apply_pending_preset_selection()
	_update_menu_title_for_mode()
	_update_primary_action_for_mode()
	_refresh_preview(0.0)

func _update_menu_title_for_mode() -> void:
	if is_editing_preset_mode:
		local_game_title.text = "Edit preset %s" % editing_preset_name
		return
	var title_text = "Create Local game"
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager != null and network_manager.is_hosting and not network_manager.is_online_active():
		title_text = "Create Online Game"
	local_game_title.text = title_text

func _update_primary_action_for_mode() -> void:
	if is_editing_preset_mode:
		start_game_button.text = "Save Preset"
		back_to_main_menu_button.visible = false
		return
	start_game_button.text = "Start Game"
	back_to_main_menu_button.visible = true

func _on_board_dimension_changed(_value: float) -> void:
	_update_promotion_zone_limits()
	_refresh_preview()

func _populate_piece_bank() -> void:
	piece_bank_list.clear()
	var game_manager = $"/root/GameManager"
	for piece_id in game_manager.PieceBank:
		var piece_data = game_manager.PieceDefinitions.get(piece_id, {})
		var display_name = piece_data.get("name", str(piece_id))
		var symbol = piece_data.get("symbol", "?")
		var icon_texture = game_manager.get_piece_icon_texture(str(piece_id))
		if icon_texture != null:
			piece_bank_list.add_item("%s (%s)" % [display_name, symbol], _scaled_item_icon(icon_texture, 24))
		else:
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
	piece_color_option.add_item("Player 1")
	piece_color_option.add_item("Player 2")
	piece_color_option.select(0)
	piece_color_option.item_selected.connect(_on_piece_color_selected)

func _setup_player_color_pickers() -> void:
	player1_color_button.color_changed.connect(_on_player_color_changed.bind("white"))
	player2_color_button.color_changed.connect(_on_player_color_changed.bind("black"))
	_apply_player_colors_from_serialized($"/root/GameManager".PlayerColors)

func _on_player_color_changed(new_color: Color, owner: String) -> void:
	player_side_colors[owner] = Color(new_color.r, new_color.g, new_color.b, 1.0)
	_refresh_preview()

func _setup_tile_color_pickers() -> void:
	light_tile_color_button.color_changed.connect(_on_tile_color_changed.bind("light"))
	dark_tile_color_button.color_changed.connect(_on_tile_color_changed.bind("dark"))
	_apply_tile_colors_from_serialized($"/root/GameManager".TileColors)

func _on_tile_color_changed(new_color: Color, tile_kind: String) -> void:
	board_tile_colors[tile_kind] = Color(new_color.r, new_color.g, new_color.b, 1.0)
	_refresh_preview()

func _setup_victory_condition_picker() -> void:
	victory_condition_option.clear()
	victory_condition_option.add_item("Checkmate")
	victory_condition_option.add_item("Total War")
	victory_condition_option.item_selected.connect(_on_victory_condition_selected)
	_apply_victory_condition($"/root/GameManager".VictoryCondition)

func _build_victory_condition() -> String:
	if victory_condition_option.selected == 1:
		return "total_war"
	return "checkmate"

func _apply_victory_condition(victory_condition: String) -> void:
	if victory_condition == "total_war":
		victory_condition_option.select(1)
	else:
		victory_condition_option.select(0)
	_update_victory_condition_description()

func _on_victory_condition_selected(_index: int) -> void:
	_update_victory_condition_description()

func _update_victory_condition_description() -> void:
	if victory_condition_option.selected == 1:
		victory_condition_description.text = "TOTAL WAR\nWin when the opponent has no pieces left on the board.\nIf neither side has any legal capture remaining, the game is a stalemate."
	else:
		victory_condition_description.text = "CHECKMATE\nWin by checkmating the king."

func _setup_special_rules() -> void:
	_ensure_piece_stacking_check_box()
	_ensure_gungi_rule_controls()
	castling_check_box.toggled.connect(_on_castling_rule_toggled)
	promotion_check_box.toggled.connect(_on_promotion_rule_toggled)
	enable_spell_cards_check_box.toggled.connect(_on_enable_spell_cards_toggled)
	piece_dropping_check_box.toggled.connect(_on_piece_dropping_toggled)
	if piece_stacking_check_box != null:
		piece_stacking_check_box.toggled.connect(_on_piece_stacking_toggled)
	if enable_territory_check_box != null:
		enable_territory_check_box.toggled.connect(_on_territory_controls_toggled)
	if enable_muster_check_box != null:
		enable_muster_check_box.toggled.connect(_on_territory_controls_toggled)
	if territory_rows_spin_box != null:
		territory_rows_spin_box.value_changed.connect(_on_territory_rows_value_changed)
	limit_army_strength_check_box.toggled.connect(_on_limit_army_strength_toggled)
	unbalanced_armies_check_box.toggled.connect(_on_unbalanced_armies_toggled)
	spell_unbalanced_hand_sizes_check_box.toggled.connect(_on_spell_unbalanced_hand_sizes_toggled)
	random_spell_cards_check_box.toggled.connect(_on_random_spell_cards_toggled)
	spell_allow_duplicates_check_box.toggled.connect(_on_spell_allow_duplicates_toggled)
	spell_hand_size_spin_box.value_changed.connect(_on_spell_hand_size_value_changed)
	spell_hand_size_white_spin_box.value_changed.connect(_on_spell_hand_size_value_changed)
	spell_hand_size_black_spin_box.value_changed.connect(_on_spell_hand_size_value_changed)
	spell_assign_card_option.item_selected.connect(_on_spell_assign_card_selected)
	army_strength_cap_spin_box.value_changed.connect(_on_army_strength_cap_value_changed)
	white_army_strength_cap_spin_box.value_changed.connect(_on_unbalanced_army_strength_cap_value_changed)
	black_army_strength_cap_spin_box.value_changed.connect(_on_unbalanced_army_strength_cap_value_changed)
	player1_promotion_zone_spin_box.value_changed.connect(_on_promotion_zone_value_changed)
	player2_promotion_zone_spin_box.value_changed.connect(_on_promotion_zone_value_changed)
	army_strength_cap_spin_box.min_value = 2.0
	army_strength_cap_spin_box.step = 1.0
	army_strength_cap_spin_box.rounded = true
	white_army_strength_cap_spin_box.min_value = 2.0
	white_army_strength_cap_spin_box.step = 1.0
	white_army_strength_cap_spin_box.rounded = true
	black_army_strength_cap_spin_box.min_value = 2.0
	black_army_strength_cap_spin_box.step = 1.0
	black_army_strength_cap_spin_box.rounded = true
	player1_promotion_zone_spin_box.min_value = 1.0
	player1_promotion_zone_spin_box.step = 1.0
	player1_promotion_zone_spin_box.rounded = true
	player2_promotion_zone_spin_box.min_value = 1.0
	player2_promotion_zone_spin_box.step = 1.0
	player2_promotion_zone_spin_box.rounded = true
	spell_hand_size_spin_box.min_value = 0.0
	spell_hand_size_spin_box.step = 1.0
	spell_hand_size_spin_box.rounded = true
	spell_hand_size_white_spin_box.min_value = 0.0
	spell_hand_size_white_spin_box.step = 1.0
	spell_hand_size_white_spin_box.rounded = true
	spell_hand_size_black_spin_box.min_value = 0.0
	spell_hand_size_black_spin_box.step = 1.0
	spell_hand_size_black_spin_box.rounded = true
	if territory_rows_spin_box != null:
		territory_rows_spin_box.min_value = 1.0
		territory_rows_spin_box.step = 1.0
		territory_rows_spin_box.rounded = true
	_build_promotion_piece_checkboxes()
	_build_spell_card_checkboxes()
	_apply_special_rules($"/root/GameManager".SpecialRules)
	_apply_territory_rows(int($"/root/GameManager".TerritoryRows))
	_apply_spell_card_config($"/root/GameManager")
	_apply_promotion_zones($"/root/GameManager".PromotionZones)
	_update_promotion_zone_limits()
	army_strength_cap_spin_box.value = float(max(int($"/root/GameManager".ArmyStrengthCap), 2))
	white_army_strength_cap_spin_box.value = float(max(int($"/root/GameManager".ArmyStrengthCapWhite), 2))
	black_army_strength_cap_spin_box.value = float(max(int($"/root/GameManager".ArmyStrengthCapBlack), 2))
	_apply_promotion_piece_pool($"/root/GameManager".PromotionPiecePool)
	_update_promotion_piece_visibility()
	_update_spell_card_visibility()
	_update_piece_dropping_visibility()
	_update_territory_controls_visibility()
	_update_army_strength_limit_visibility()
	_ensure_army_strength_cap_meets_current_position()
	_update_castling_rule_availability()

func _build_special_rules() -> Dictionary:
	return {
		"castling": castling_check_box.button_pressed,
		"en_passant": en_passant_check_box.button_pressed,
		"promotion": promotion_check_box.button_pressed,
		"allow_undo": allow_undo_check_box.button_pressed,
		"enable_spell_cards": enable_spell_cards_check_box.button_pressed,
		"piece_dropping": piece_dropping_check_box.button_pressed,
		"piece_stacking": piece_stacking_check_box != null and piece_stacking_check_box.button_pressed,
		"enable_territory": enable_territory_check_box != null and enable_territory_check_box.button_pressed,
		"enable_muster": enable_muster_check_box != null and enable_muster_check_box.button_pressed,
		"capture_to_drop_pool": capture_to_drop_pool_check_box.button_pressed,
		"limit_army_strength": limit_army_strength_check_box.button_pressed,
		"unbalanced_armies": unbalanced_armies_check_box.button_pressed
	}

func _ensure_piece_stacking_check_box() -> void:
	if piece_stacking_check_box != null:
		return
	var existing = options_content.get_node_or_null("PieceStackingCheckBox")
	if existing is CheckBox:
		piece_stacking_check_box = existing
		return
	var check_box = CheckBox.new()
	check_box.name = "PieceStackingCheckBox"
	check_box.layout_mode = 0
	check_box.offset_left = 80.0
	check_box.offset_top = 1576.0
	check_box.offset_right = 332.0
	check_box.offset_bottom = 1600.0
	check_box.text = "Enable Piece Stacking (Gungi)"
	options_content.add_child(check_box)
	piece_stacking_check_box = check_box

func _ensure_gungi_rule_controls() -> void:
	if enable_territory_check_box == null:
		var existing_territory = options_content.get_node_or_null("EnableTerritoryCheckBox")
		if existing_territory is CheckBox:
			enable_territory_check_box = existing_territory
		else:
			var territory_check = CheckBox.new()
			territory_check.name = "EnableTerritoryCheckBox"
			territory_check.layout_mode = 0
			territory_check.offset_left = 80.0
			territory_check.offset_top = 1604.0
			territory_check.offset_right = 332.0
			territory_check.offset_bottom = 1628.0
			territory_check.text = "Enable Territory Rules"
			options_content.add_child(territory_check)
			enable_territory_check_box = territory_check

	if enable_muster_check_box == null:
		var existing_muster = options_content.get_node_or_null("EnableMusterCheckBox")
		if existing_muster is CheckBox:
			enable_muster_check_box = existing_muster
		else:
			var muster_check = CheckBox.new()
			muster_check.name = "EnableMusterCheckBox"
			muster_check.layout_mode = 0
			muster_check.offset_left = 80.0
			muster_check.offset_top = 1632.0
			muster_check.offset_right = 332.0
			muster_check.offset_bottom = 1656.0
			muster_check.text = "Enable Muster Opening"
			options_content.add_child(muster_check)
			enable_muster_check_box = muster_check

	if territory_rows_label == null:
		var existing_label = options_content.get_node_or_null("TerritoryRowsLabel")
		if existing_label is Label:
			territory_rows_label = existing_label
		else:
			var rows_label = Label.new()
			rows_label.name = "TerritoryRowsLabel"
			rows_label.layout_mode = 0
			rows_label.offset_left = 80.0
			rows_label.offset_top = 1664.0
			rows_label.offset_right = 212.0
			rows_label.offset_bottom = 1688.0
			rows_label.text = "Territory Rows"
			options_content.add_child(rows_label)
			territory_rows_label = rows_label

	if territory_rows_spin_box == null:
		var existing_spin = options_content.get_node_or_null("TerritoryRowsSpinBox")
		if existing_spin is SpinBox:
			territory_rows_spin_box = existing_spin
		else:
			var rows_spin = SpinBox.new()
			rows_spin.name = "TerritoryRowsSpinBox"
			rows_spin.layout_mode = 0
			rows_spin.offset_left = 228.0
			rows_spin.offset_top = 1664.0
			rows_spin.offset_right = 332.0
			rows_spin.offset_bottom = 1688.0
			options_content.add_child(rows_spin)
			territory_rows_spin_box = rows_spin

func _territory_rows_value() -> int:
	if territory_rows_spin_box == null:
		return 3
	return max(int(round(territory_rows_spin_box.value)), 1)

func _apply_territory_rows(rows: int) -> void:
	if territory_rows_spin_box == null:
		return
	territory_rows_spin_box.value = float(max(rows, 1))

func _update_territory_controls_visibility() -> void:
	if territory_rows_label == null or territory_rows_spin_box == null:
		return
	var enabled = false
	if enable_territory_check_box != null and enable_territory_check_box.button_pressed:
		enabled = true
	if enable_muster_check_box != null and enable_muster_check_box.button_pressed:
		enabled = true
	territory_rows_label.visible = enabled
	territory_rows_spin_box.visible = enabled

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

func _build_spell_card_checkboxes() -> void:
	for child in available_spell_cards_list.get_children():
		child.queue_free()
	spell_card_checkboxes.clear()

	for card_data in $"/root/GameManager".get_spell_card_definitions():
		var card_id = str(card_data.get("id", ""))
		if card_id == "":
			continue
		var card_name = str(card_data.get("name", card_id.capitalize()))
		var card_type = str(card_data.get("type", "regular"))
		var card_description = str(card_data.get("description", ""))
		var check_box = CheckBox.new()
		check_box.text = "%s [%s]" % [card_name, "Power" if card_type == "power" else "Regular"]
		check_box.tooltip_text = card_description
		check_box.toggled.connect(_on_spell_card_toggled.bind(card_id))
		available_spell_cards_list.add_child(check_box)
		spell_card_checkboxes[card_id] = check_box

func _build_enabled_spell_card_ids() -> Array:
	var enabled_ids: Array = []
	for card_data in $"/root/GameManager".get_spell_card_definitions():
		var card_id = str(card_data.get("id", ""))
		if card_id == "" or not spell_card_checkboxes.has(card_id):
			continue
		var check_box: CheckBox = spell_card_checkboxes[card_id]
		if check_box.button_pressed:
			enabled_ids.append(card_id)
	return enabled_ids

func _apply_available_spell_card_ids(source_ids: Variant) -> void:
	var normalized_ids = $"/root/GameManager".normalize_spell_card_ids(source_ids)
	for card_id in spell_card_checkboxes.keys():
		var check_box: CheckBox = spell_card_checkboxes[card_id]
		check_box.button_pressed = normalized_ids.has(str(card_id))
	_refresh_spell_assign_option()
	_clamp_preview_spell_hands_to_rules()

func _build_spell_card_hands() -> Dictionary:
	return {
		"white": (preview_spell_hands.get("white", []) as Array).duplicate(true),
		"black": (preview_spell_hands.get("black", []) as Array).duplicate(true)
	}

func _deserialize_spell_card_hands(source_hands: Variant) -> Dictionary:
	return $"/root/GameManager".normalize_spell_card_hands(source_hands)

func _apply_spell_card_config(game_manager: Node) -> void:
	is_updating_spell_hand_sizes = true
	spell_hand_size_spin_box.value = float(max(int(game_manager.SpellCardHandSize), 0))
	spell_hand_size_white_spin_box.value = float(max(int(game_manager.SpellCardHandSizeWhite), 0))
	spell_hand_size_black_spin_box.value = float(max(int(game_manager.SpellCardHandSizeBlack), 0))
	random_spell_cards_check_box.button_pressed = bool(game_manager.SpellCardsRandom)
	spell_allow_duplicates_check_box.button_pressed = bool(game_manager.SpellCardAllowDuplicates)
	spell_draw_replacement_after_cast_check_box.button_pressed = bool(game_manager.SpellCardDrawReplacementAfterCast)
	spell_unbalanced_hand_sizes_check_box.button_pressed = int(game_manager.SpellCardHandSizeWhite) != int(game_manager.SpellCardHandSizeBlack)
	is_updating_spell_hand_sizes = false
	_apply_available_spell_card_ids(game_manager.SpellCardAvailableIds)
	preview_spell_hands = _deserialize_spell_card_hands(game_manager.StartingSpellHands)
	_update_spell_card_visibility()
	_clamp_preview_spell_hands_to_rules()

func _build_spell_card_config() -> Dictionary:
	return {
		"hand_size": _get_spell_hand_size_value(),
		"unbalanced_hand_sizes": spell_unbalanced_hand_sizes_check_box.button_pressed,
		"hand_size_white": _get_spell_hand_size_for_owner("white"),
		"hand_size_black": _get_spell_hand_size_for_owner("black"),
		"random_cards": random_spell_cards_check_box.button_pressed,
		"allow_duplicates": _is_spell_card_duplicates_allowed(),
		"draw_replacement_after_cast": _is_draw_replacement_after_cast_enabled(),
		"available_cards": _build_enabled_spell_card_ids(),
		"starting_hands": _build_spell_card_hands()
	}

func _apply_spell_card_config_from_preset(spell_config: Variant) -> void:
	if not (spell_config is Dictionary):
		spell_config = {
			"hand_size": 3,
			"unbalanced_hand_sizes": false,
			"hand_size_white": 3,
			"hand_size_black": 3,
			"random_cards": true,
			"allow_duplicates": true,
			"draw_replacement_after_cast": false,
			"available_cards": $"/root/GameManager".normalize_spell_card_ids([]),
			"starting_hands": {"white": [], "black": []}
		}
	is_updating_spell_hand_sizes = true
	spell_hand_size_spin_box.value = float(max(int(spell_config.get("hand_size", 3)), 0))
	spell_unbalanced_hand_sizes_check_box.button_pressed = bool(spell_config.get("unbalanced_hand_sizes", false))
	spell_hand_size_white_spin_box.value = float(max(int(spell_config.get("hand_size_white", spell_config.get("hand_size", 3))), 0))
	spell_hand_size_black_spin_box.value = float(max(int(spell_config.get("hand_size_black", spell_config.get("hand_size", 3))), 0))
	random_spell_cards_check_box.button_pressed = bool(spell_config.get("random_cards", true))
	spell_allow_duplicates_check_box.button_pressed = bool(spell_config.get("allow_duplicates", true))
	spell_draw_replacement_after_cast_check_box.button_pressed = bool(spell_config.get("draw_replacement_after_cast", false))
	is_updating_spell_hand_sizes = false
	_apply_available_spell_card_ids(spell_config.get("available_cards", []))
	preview_spell_hands = _deserialize_spell_card_hands(spell_config.get("starting_hands", {}))
	_update_spell_card_visibility()
	_clamp_preview_spell_hands_to_rules()

func _refresh_spell_assign_option() -> void:
	spell_assign_card_option.clear()
	spell_assign_card_ids.clear()
	for card_data in $"/root/GameManager".get_spell_card_definitions():
		var card_id = str(card_data.get("id", ""))
		if card_id == "":
			continue
		if not spell_card_checkboxes.has(card_id):
			continue
		var check_box: CheckBox = spell_card_checkboxes[card_id]
		if not check_box.button_pressed:
			continue
		var card_name = str(card_data.get("name", card_id.capitalize()))
		var card_type = str(card_data.get("type", "regular"))
		spell_assign_card_option.add_item("%s [%s]" % [card_name, "Power" if card_type == "power" else "Regular"])
		spell_assign_card_ids.append(card_id)

	if spell_assign_card_ids.is_empty():
		selected_spell_card_id = ""
		spell_assign_card_option.disabled = true
	else:
		spell_assign_card_option.disabled = false
		spell_assign_card_option.select(0)
		selected_spell_card_id = spell_assign_card_ids[0]

func _get_spell_hand_size_value() -> int:
	return max(int(round(spell_hand_size_spin_box.value)), 0)

func _get_spell_hand_size_for_owner(owner: String) -> int:
	if spell_unbalanced_hand_sizes_check_box.button_pressed:
		if owner == "white":
			return max(int(round(spell_hand_size_white_spin_box.value)), 0)
		return max(int(round(spell_hand_size_black_spin_box.value)), 0)
	return _get_spell_hand_size_value()

func _is_spell_cards_enabled() -> bool:
	return enable_spell_cards_check_box.button_pressed

func _is_random_spell_cards_enabled() -> bool:
	return random_spell_cards_check_box.button_pressed

func _is_spell_card_duplicates_allowed() -> bool:
	return spell_allow_duplicates_check_box.button_pressed

func _is_draw_replacement_after_cast_enabled() -> bool:
	return random_spell_cards_check_box.button_pressed and spell_draw_replacement_after_cast_check_box.button_pressed

func _clamp_preview_spell_hands_to_rules() -> void:
	for owner in ["white", "black"]:
		var clamped: Array = []
		var seen = {}
		var cap = _get_spell_hand_size_for_owner(owner)
		var current_hand: Array = preview_spell_hands.get(owner, [])
		for card_id in current_hand:
			var key = str(card_id)
			if not _is_spell_card_enabled_in_list(key):
				continue
			if not _is_spell_card_duplicates_allowed() and seen.has(key):
				continue
			if clamped.size() >= cap:
				break
			seen[key] = true
			clamped.append(key)
		preview_spell_hands[owner] = clamped

func _is_spell_card_enabled_in_list(card_id: String) -> bool:
	if not spell_card_checkboxes.has(card_id):
		return false
	var check_box: CheckBox = spell_card_checkboxes[card_id]
	return check_box.button_pressed

func _spell_card_name(card_id: String) -> String:
	for card_data in $"/root/GameManager".get_spell_card_definitions():
		if str(card_data.get("id", "")) == card_id:
			return str(card_data.get("name", card_id.capitalize()))
	return card_id.capitalize()

func _on_spell_card_toggled(is_checked: bool, card_id: String) -> void:
	if not is_checked and _build_enabled_spell_card_ids().is_empty() and spell_card_checkboxes.has(card_id):
		var check_box: CheckBox = spell_card_checkboxes[card_id]
		check_box.button_pressed = true
		return
	_refresh_spell_assign_option()
	_clamp_preview_spell_hands_to_rules()
	_refresh_preview()

func _on_spell_assign_card_selected(index: int) -> void:
	if index < 0 or index >= spell_assign_card_ids.size():
		selected_spell_card_id = ""
		return
	selected_spell_card_id = spell_assign_card_ids[index]

func _on_enable_spell_cards_toggled(_is_enabled: bool) -> void:
	_update_spell_card_visibility()
	_clamp_preview_spell_hands_to_rules()
	_refresh_preview()

func _on_spell_unbalanced_hand_sizes_toggled(_is_enabled: bool) -> void:
	_update_spell_card_visibility()
	_clamp_preview_spell_hands_to_rules()
	_refresh_preview()

func _on_random_spell_cards_toggled(_is_enabled: bool) -> void:
	if not _is_random_spell_cards_enabled():
		spell_draw_replacement_after_cast_check_box.button_pressed = false
	_update_spell_card_visibility()
	_refresh_preview()

func _on_spell_allow_duplicates_toggled(_is_enabled: bool) -> void:
	_clamp_preview_spell_hands_to_rules()
	_refresh_preview()

func _on_spell_hand_size_value_changed(_value: float) -> void:
	if is_updating_spell_hand_sizes:
		return
	_clamp_preview_spell_hands_to_rules()
	_refresh_preview()

func _update_promotion_piece_visibility() -> void:
	var show_promotion_piece_pool = promotion_check_box.button_pressed
	promotion_zones_title_background.visible = show_promotion_piece_pool
	promotion_zones_title.visible = show_promotion_piece_pool
	player1_promotion_zone_label.visible = show_promotion_piece_pool
	player1_promotion_zone_spin_box.visible = show_promotion_piece_pool
	player2_promotion_zone_label.visible = show_promotion_piece_pool
	player2_promotion_zone_spin_box.visible = show_promotion_piece_pool
	promotion_pieces_title_background.visible = show_promotion_piece_pool
	promotion_pieces_title.visible = show_promotion_piece_pool
	promotion_pieces_list.get_parent().visible = show_promotion_piece_pool

func _build_promotion_zones() -> Dictionary:
	return {
		"white_rows": max(int(round(player1_promotion_zone_spin_box.value)), 1),
		"black_rows": max(int(round(player2_promotion_zone_spin_box.value)), 1)
	}

func _apply_promotion_zones(source: Variant) -> void:
	var parsed = {
		"white_rows": 1,
		"black_rows": 1
	}
	if source is Dictionary:
		parsed["white_rows"] = max(int(source.get("white_rows", source.get("white", 1))), 1)
		parsed["black_rows"] = max(int(source.get("black_rows", source.get("black", 1))), 1)
	player1_promotion_zone_spin_box.value = float(parsed["white_rows"])
	player2_promotion_zone_spin_box.value = float(parsed["black_rows"])

func _update_promotion_zone_limits() -> void:
	var board_height = _get_dimension(height_spin_box.value, 8)
	var max_rows = max(board_height, 1)
	player1_promotion_zone_spin_box.max_value = float(max_rows)
	player2_promotion_zone_spin_box.max_value = float(max_rows)
	if player1_promotion_zone_spin_box.value > float(max_rows):
		player1_promotion_zone_spin_box.value = float(max_rows)
	if player2_promotion_zone_spin_box.value > float(max_rows):
		player2_promotion_zone_spin_box.value = float(max_rows)

func _update_piece_dropping_visibility() -> void:
	var show_capture_rule = piece_dropping_check_box.button_pressed
	capture_to_drop_pool_check_box.visible = show_capture_rule
	if not show_capture_rule:
		capture_to_drop_pool_check_box.button_pressed = false

func _update_spell_card_visibility() -> void:
	var enabled = _is_spell_cards_enabled()
	spell_hand_size_label.visible = enabled
	spell_hand_size_spin_box.visible = enabled
	spell_unbalanced_hand_sizes_check_box.visible = enabled
	random_spell_cards_check_box.visible = enabled
	spell_allow_duplicates_check_box.visible = enabled
	spell_draw_replacement_after_cast_check_box.visible = enabled and _is_random_spell_cards_enabled()
	available_spell_cards_title_background.visible = enabled
	available_spell_cards_title.visible = enabled
	available_spell_cards_scroll.visible = enabled

	var unbalanced = enabled and spell_unbalanced_hand_sizes_check_box.button_pressed
	spell_hand_size_white_label.visible = unbalanced
	spell_hand_size_white_spin_box.visible = unbalanced
	spell_hand_size_black_label.visible = unbalanced
	spell_hand_size_black_spin_box.visible = unbalanced

	var manual_assign = enabled and not _is_random_spell_cards_enabled()
	spell_assign_card_label.visible = manual_assign
	spell_assign_card_option.visible = manual_assign
	spell_cards_hint_label.visible = manual_assign

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
	_refresh_preview()

func _on_promotion_zone_value_changed(_value: float) -> void:
	_update_promotion_zone_limits()
	_refresh_preview()

func _on_piece_dropping_toggled(_is_enabled: bool) -> void:
	_update_piece_dropping_visibility()
	_refresh_preview()

func _on_piece_stacking_toggled(_is_enabled: bool) -> void:
	_refresh_preview()

func _on_territory_controls_toggled(_is_enabled: bool) -> void:
	_update_territory_controls_visibility()
	_refresh_preview()

func _on_territory_rows_value_changed(_value: float) -> void:
	_refresh_preview()

func _on_limit_army_strength_toggled(is_enabled: bool) -> void:
	_update_army_strength_limit_visibility()
	if is_enabled:
		_ensure_army_strength_cap_meets_current_position()
		_clear_army_strength_warning(true)
	else:
		_clear_army_strength_warning(true)
	_refresh_preview()

func _on_unbalanced_armies_toggled(_is_enabled: bool) -> void:
	_update_army_strength_limit_visibility()
	if _is_army_strength_rule_enabled():
		_ensure_army_strength_cap_meets_current_position()
	_clear_army_strength_warning(true)
	_refresh_preview()

func _on_army_strength_cap_value_changed(_value: float) -> void:
	if is_updating_army_strength_cap:
		return
	if not _is_army_strength_rule_enabled():
		return
	if _is_unbalanced_armies_enabled():
		return
	_ensure_army_strength_cap_meets_current_position()
	_clear_army_strength_warning()

func _on_unbalanced_army_strength_cap_value_changed(_value: float) -> void:
	if is_updating_unbalanced_army_strength_caps:
		return
	if not _is_army_strength_rule_enabled() or not _is_unbalanced_armies_enabled():
		return
	_ensure_army_strength_cap_meets_current_position()
	_clear_army_strength_warning()

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
	allow_undo_check_box.button_pressed = bool(special_rules.get("allow_undo", false))
	enable_spell_cards_check_box.button_pressed = bool(special_rules.get("enable_spell_cards", false))
	piece_dropping_check_box.button_pressed = bool(special_rules.get("piece_dropping", false))
	if piece_stacking_check_box != null:
		piece_stacking_check_box.button_pressed = bool(special_rules.get("piece_stacking", false))
	if enable_territory_check_box != null:
		enable_territory_check_box.button_pressed = bool(special_rules.get("enable_territory", false))
	if enable_muster_check_box != null:
		enable_muster_check_box.button_pressed = bool(special_rules.get("enable_muster", false))
	capture_to_drop_pool_check_box.button_pressed = bool(special_rules.get("capture_to_drop_pool", false))
	limit_army_strength_check_box.button_pressed = bool(special_rules.get("limit_army_strength", false))
	unbalanced_armies_check_box.button_pressed = bool(special_rules.get("unbalanced_armies", false))
	_update_castling_rule_availability()
	_update_spell_card_visibility()
	_update_piece_dropping_visibility()
	_update_territory_controls_visibility()
	_update_army_strength_limit_visibility()

func _update_army_strength_limit_visibility() -> void:
	var show_controls = limit_army_strength_check_box.button_pressed
	unbalanced_armies_check_box.visible = show_controls
	var unbalanced_enabled = show_controls and _is_unbalanced_armies_enabled()
	army_strength_cap_label.visible = show_controls and not unbalanced_enabled
	army_strength_cap_spin_box.visible = show_controls and not unbalanced_enabled
	white_army_strength_cap_label.visible = unbalanced_enabled
	white_army_strength_cap_spin_box.visible = unbalanced_enabled
	black_army_strength_cap_label.visible = unbalanced_enabled
	black_army_strength_cap_spin_box.visible = unbalanced_enabled
	if not show_controls:
		army_strength_warning_label.visible = false

func _is_unbalanced_armies_enabled() -> bool:
	return unbalanced_armies_check_box.button_pressed

func _is_army_strength_rule_enabled() -> bool:
	return limit_army_strength_check_box.button_pressed

func _get_army_strength_cap_value() -> int:
	return max(int(round(army_strength_cap_spin_box.value)), 2)

func _get_unbalanced_army_strength_cap_value(owner: String) -> int:
	if owner == "white":
		return max(int(round(white_army_strength_cap_spin_box.value)), 2)
	return max(int(round(black_army_strength_cap_spin_box.value)), 2)

func _get_army_strength_cap_for_owner(owner: String) -> int:
	if _is_unbalanced_armies_enabled():
		return _get_unbalanced_army_strength_cap_value(owner)
	return _get_army_strength_cap_value()

func _set_army_strength_cap_value(new_value: int) -> void:
	is_updating_army_strength_cap = true
	army_strength_cap_spin_box.value = float(max(new_value, 2))
	is_updating_army_strength_cap = false

func _set_unbalanced_army_strength_cap_value(owner: String, new_value: int) -> void:
	is_updating_unbalanced_army_strength_caps = true
	if owner == "white":
		white_army_strength_cap_spin_box.value = float(max(new_value, 2))
	else:
		black_army_strength_cap_spin_box.value = float(max(new_value, 2))
	is_updating_unbalanced_army_strength_caps = false

func _get_preview_piece_strength(piece_id: String) -> int:
	var include_king = _build_victory_condition() == "total_war"
	return int($"/root/GameManager".get_piece_strength(piece_id, include_king))

func _get_preview_army_strength_for_owner(owner: String, preview_board_state: Dictionary, preview_pool_state: Dictionary) -> int:
	var total = 0
	for square in preview_board_state.keys():
		var piece_data: Dictionary = preview_board_state[square]
		if str(piece_data.get("color", "")) != owner:
			continue
		total += _get_preview_piece_strength(str(piece_data.get("piece_id", "")))
	var pool_contents: Array = preview_pool_state.get(owner, [])
	for piece_id in pool_contents:
		total += _get_preview_piece_strength(str(piece_id))
	return total

func _format_owner_name(owner: String) -> String:
	if owner == "white":
		return "Player 1"
	if owner == "black":
		return "Player 2"
	return owner.capitalize()

func _set_army_strength_warning(owner: String, total_strength: int, cap: int) -> void:
	var warning_text = "%s cap blocked: %d / %d\nRemove a piece or raise the cap." % [_format_owner_name(owner), total_strength, cap]
	army_strength_warning_label.text = warning_text
	army_strength_warning_label.visible = true
	_show_preview_warning(warning_text)

func _clear_army_strength_warning(clear_preview_warning: bool = false) -> void:
	army_strength_warning_label.text = ""
	army_strength_warning_label.visible = false
	if clear_preview_warning:
		preview_warning_message_serial += 1
		preview_warning_label.text = ""
		preview_warning_label.visible = false

func _show_preview_warning(message: String) -> void:
	preview_warning_message_serial += 1
	var message_serial = preview_warning_message_serial
	preview_warning_label.text = message
	preview_warning_label.visible = true
	_hide_preview_warning_after_delay(message_serial)

func _hide_preview_warning_after_delay(message_serial: int) -> void:
	await get_tree().create_timer(3.0).timeout
	if message_serial != preview_warning_message_serial:
		return
	preview_warning_label.text = ""
	preview_warning_label.visible = false

func _preview_respects_army_strength(preview_board_state: Dictionary, preview_pool_state: Dictionary) -> bool:
	if not _is_army_strength_rule_enabled():
		return true
	for owner in ["white", "black"]:
		if _get_preview_army_strength_for_owner(owner, preview_board_state, preview_pool_state) > _get_army_strength_cap_for_owner(owner):
			return false
	return true

func _ensure_army_strength_cap_meets_current_position() -> void:
	if not _is_army_strength_rule_enabled():
		return
	var white_strength = _get_preview_army_strength_for_owner("white", preview_pieces, preview_drop_pools)
	var black_strength = _get_preview_army_strength_for_owner("black", preview_pieces, preview_drop_pools)
	if _is_unbalanced_armies_enabled():
		if _get_unbalanced_army_strength_cap_value("white") < white_strength:
			_set_unbalanced_army_strength_cap_value("white", max(2, white_strength))
		if _get_unbalanced_army_strength_cap_value("black") < black_strength:
			_set_unbalanced_army_strength_cap_value("black", max(2, black_strength))
		return
	var required_cap = max(2, max(white_strength, black_strength))
	if _get_army_strength_cap_value() < required_cap:
		_set_army_strength_cap_value(required_cap)

func _can_place_preview_piece(square: Vector2i, piece_id: String, piece_color: String) -> bool:
	if not _is_army_strength_rule_enabled():
		return true
	var next_board = preview_pieces.duplicate(true)
	next_board[square] = {
		"piece_id": piece_id,
		"color": piece_color
	}
	var cap = _get_army_strength_cap_for_owner(piece_color)
	var owner_total = _get_preview_army_strength_for_owner(piece_color, next_board, preview_drop_pools)
	if owner_total > cap:
		_set_army_strength_warning(piece_color, owner_total, cap)
		return false
	return _preview_respects_army_strength(next_board, preview_drop_pools)

func _can_add_to_preview_drop_pool(pool_owner: String, piece_id: String) -> bool:
	if not _is_army_strength_rule_enabled():
		return true
	var next_pools = _serialize_drop_pools()
	var pool_contents: Array = next_pools.get(pool_owner, [])
	pool_contents.append(piece_id)
	next_pools[pool_owner] = pool_contents
	var cap = _get_army_strength_cap_for_owner(pool_owner)
	var owner_total = _get_preview_army_strength_for_owner(pool_owner, preview_pieces, next_pools)
	if owner_total > cap:
		_set_army_strength_warning(pool_owner, owner_total, cap)
		return false
	return _preview_respects_army_strength(preview_pieces, next_pools)

func _reset_preview_to_default(should_refresh: bool = true, use_standard_layout: bool = true) -> void:
	width_spin_box.value = 8
	height_spin_box.value = 8
	preview_pieces.clear()
	preview_drop_pools = {
		"white": [],
		"black": []
	}
	preview_spell_hands = {
		"white": [],
		"black": []
	}
	if use_standard_layout:
		_apply_standard_chess_layout()
	_apply_special_rules({
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
	})
	_apply_territory_rows(3)
	_apply_spell_card_config_from_preset({
		"hand_size": 3,
		"unbalanced_hand_sizes": false,
		"hand_size_white": 3,
		"hand_size_black": 3,
		"random_cards": true,
		"allow_duplicates": true,
		"draw_replacement_after_cast": false,
		"available_cards": $"/root/GameManager".normalize_spell_card_ids([]),
		"starting_hands": {"white": [], "black": []}
	})
	_set_army_strength_cap_value(32)
	_set_unbalanced_army_strength_cap_value("white", 32)
	_set_unbalanced_army_strength_cap_value("black", 32)
	_apply_promotion_piece_pool(["queen", "rook", "bishop", "knight"])
	_apply_promotion_zones({"white_rows": 1, "black_rows": 1})
	_apply_victory_condition("checkmate")
	_apply_player_colors_from_serialized({})
	_apply_tile_colors_from_serialized({})
	_update_promotion_zone_limits()
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
	_clear_army_strength_warning(true)

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
				"allow_undo": false,
				"enable_spell_cards": false,
				"piece_dropping": false,
				"piece_stacking": false,
				"enable_territory": false,
				"enable_muster": false,
				"capture_to_drop_pool": false,
				"limit_army_strength": false,
				"unbalanced_armies": false
			})
			_apply_territory_rows(2)
			_apply_spell_card_config_from_preset({
				"hand_size": 3,
				"unbalanced_hand_sizes": false,
				"hand_size_white": 3,
				"hand_size_black": 3,
				"random_cards": true,
				"allow_duplicates": true,
				"draw_replacement_after_cast": false,
				"available_cards": $"/root/GameManager".normalize_spell_card_ids([]),
				"starting_hands": {"white": [], "black": []}
			})
			_set_army_strength_cap_value(32)
			_set_unbalanced_army_strength_cap_value("white", 32)
			_set_unbalanced_army_strength_cap_value("black", 32)
			_apply_promotion_piece_pool(["queen", "rook", "bishop", "knight"])
			_apply_promotion_zones({"white_rows": 1, "black_rows": 1})
			_apply_victory_condition("checkmate")
			_apply_player_colors_from_serialized({})
			_apply_tile_colors_from_serialized({})
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
				"allow_undo": false,
				"enable_spell_cards": false,
				"piece_dropping": true,
				"piece_stacking": false,
				"enable_territory": false,
				"enable_muster": false,
				"capture_to_drop_pool": true,
				"limit_army_strength": false,
				"unbalanced_armies": false
			})
			_apply_territory_rows(3)
			_apply_spell_card_config_from_preset({
				"hand_size": 3,
				"unbalanced_hand_sizes": false,
				"hand_size_white": 3,
				"hand_size_black": 3,
				"random_cards": true,
				"allow_duplicates": true,
				"draw_replacement_after_cast": false,
				"available_cards": $"/root/GameManager".normalize_spell_card_ids([]),
				"starting_hands": {"white": [], "black": []}
			})
			_set_army_strength_cap_value(32)
			_set_unbalanced_army_strength_cap_value("white", 32)
			_set_unbalanced_army_strength_cap_value("black", 32)
			_apply_promotion_piece_pool(["rook", "bishop", "silver_general", "gold_general", "lance", "shogi_knight", "shogi_pawn"])
			_apply_promotion_zones({"white_rows": 3, "black_rows": 3})
			_apply_victory_condition("checkmate")
			_apply_player_colors_from_serialized({})
			_apply_tile_colors_from_serialized({})
			preview_drop_pools = {
				"white": [],
				"black": []
			}
			_refresh_preview()
		"gungi":
			_reset_preview_to_default(false, false)
			width_spin_box.value = 9
			height_spin_box.value = 9
			preview_pieces.clear()
			_apply_special_rules({
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
			})
			_apply_territory_rows(3)
			_apply_spell_card_config_from_preset({
				"hand_size": 0,
				"unbalanced_hand_sizes": false,
				"hand_size_white": 0,
				"hand_size_black": 0,
				"random_cards": true,
				"allow_duplicates": true,
				"draw_replacement_after_cast": false,
				"available_cards": $"/root/GameManager".normalize_spell_card_ids([]),
				"starting_hands": {"white": [], "black": []}
			})
			_set_army_strength_cap_value(32)
			_set_unbalanced_army_strength_cap_value("white", 32)
			_set_unbalanced_army_strength_cap_value("black", 32)
			_apply_promotion_piece_pool(["rook", "bishop", "silver_general", "gold_general", "lance", "shogi_knight", "shogi_pawn"])
			_apply_promotion_zones({"white_rows": 3, "black_rows": 3})
			_apply_victory_condition("checkmate")
			_apply_player_colors_from_serialized({})
			_apply_tile_colors_from_serialized({})
			preview_drop_pools = {
				"white": ["lance", "shogi_knight", "silver_general", "gold_general", "king", "gold_general", "silver_general", "shogi_knight", "lance", "rook", "bishop", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn"],
				"black": ["lance", "shogi_knight", "silver_general", "gold_general", "king", "gold_general", "silver_general", "shogi_knight", "lance", "rook", "bishop", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn", "shogi_pawn"]
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
	_apply_victory_condition(str(preset_config.get("victory_condition", "checkmate")))
	_apply_special_rules(preset_config.get("special_rules", {}))
	_set_army_strength_cap_value(int(preset_config.get("army_strength_cap", 32)))
	var serialized_side_caps = preset_config.get("army_strength_caps", {})
	if serialized_side_caps is Dictionary:
		_set_unbalanced_army_strength_cap_value("white", int(serialized_side_caps.get("white", preset_config.get("army_strength_cap", 32))))
		_set_unbalanced_army_strength_cap_value("black", int(serialized_side_caps.get("black", preset_config.get("army_strength_cap", 32))))
	else:
		_set_unbalanced_army_strength_cap_value("white", int(preset_config.get("army_strength_cap", 32)))
		_set_unbalanced_army_strength_cap_value("black", int(preset_config.get("army_strength_cap", 32)))
	_apply_promotion_piece_pool(preset_config.get("promotion_pieces", ["queen", "rook", "bishop", "knight"]))
	_apply_promotion_zones(preset_config.get("promotion_zones", {}))
	_apply_spell_card_config_from_preset(preset_config.get("spell_cards", {}))
	_apply_territory_rows(int(preset_config.get("territory_rows", 3)))
	_update_promotion_zone_limits()
	_apply_player_colors_from_serialized(preset_config.get("player_colors", {}))
	_apply_tile_colors_from_serialized(preset_config.get("tile_colors", {}))
	_update_promotion_piece_visibility()
	_update_spell_card_visibility()
	_update_piece_dropping_visibility()
	_ensure_army_strength_cap_meets_current_position()
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

func _apply_pending_preset_selection() -> void:
	is_editing_preset_mode = false
	editing_preset_name = ""
	var pending_preset_name = str($"/root/GameManager".consume_pending_preset_for_edit())
	if pending_preset_name == "":
		return
	for index in range(preset_list.item_count):
		if preset_list.get_item_text(index) != pending_preset_name:
			continue
		preset_list.select(index)
		_on_preset_item_selected(index)
		is_editing_preset_mode = true
		editing_preset_name = pending_preset_name
		return

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
	var side_panel_width_estimate = 0.0
	if piece_dropping_check_box.button_pressed:
		side_panel_width_estimate = _preview_side_panel_width() + 16.0
	var top_bottom_spell_reserve = 0.0
	if _shows_preview_spell_hands():
		top_bottom_spell_reserve = _preview_spell_hand_panel_height_estimate() * 2.0 + 24.0
	var usable_width = max(board_preview.size.x - side_panel_width_estimate * 2.0, 80.0)
	var usable_height = max(board_preview.size.y - top_bottom_spell_reserve, 80.0)

	preview_tile_size = min(
		floor(usable_width / max(width, 1)),
		floor(usable_height / max(height, 1))
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
			tile.color = _get_board_tile_color(is_white)
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			board_preview.add_child(tile)
			is_white = !is_white

		if width % 2 == 0:
			is_white = !is_white

	_draw_preview_promotion_zone_tints(width, height)
	_draw_preview_selection()
	_draw_preview_pieces()
	_draw_preview_ghost()
	_draw_piece_bank_drag_preview()
	_draw_preview_drop_pools(board_pixel_size)
	_clamp_preview_spell_hands_to_rules()
	_draw_preview_spell_hands(board_pixel_size)
	_update_castling_rule_availability()

func _preview_side_panel_width() -> float:
	return clampf(board_preview.size.x * 0.18, 92.0, 150.0)

func _shows_preview_spell_hands() -> bool:
	return _is_spell_cards_enabled() and not _is_random_spell_cards_enabled()

func _preview_spell_hand_panel_height_estimate() -> float:
	return clampf(board_preview.size.y * 0.16, 80.0, 132.0)

func _draw_preview_spell_hands(board_pixel_size: Vector2) -> void:
	preview_white_spell_hand_rect = Rect2()
	preview_black_spell_hand_rect = Rect2()
	preview_spell_hand_entry_rects["white"] = []
	preview_spell_hand_entry_rects["black"] = []
	if not _shows_preview_spell_hands():
		return

	var hand_height = _preview_spell_hand_panel_height_estimate()
	var hand_width = max(board_pixel_size.x, 120.0)
	var hand_x = preview_board_origin.x
	var top_y = max(8.0, preview_board_origin.y - hand_height - 8.0)
	var bottom_y = min(board_preview.size.y - hand_height - 8.0, preview_board_origin.y + board_pixel_size.y + 8.0)

	preview_white_spell_hand_rect = Rect2(hand_x, top_y, hand_width, hand_height)
	preview_black_spell_hand_rect = Rect2(hand_x, bottom_y, hand_width, hand_height)

	_draw_single_preview_spell_hand(preview_white_spell_hand_rect, "Player 1 Hand", "white")
	_draw_single_preview_spell_hand(preview_black_spell_hand_rect, "Player 2 Hand", "black")

func _draw_single_preview_spell_hand(hand_rect: Rect2, title: String, owner: String) -> void:
	var background = ColorRect.new()
	background.position = hand_rect.position
	background.size = hand_rect.size
	background.color = _preview_drop_pool_color(owner, false)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(background)

	var border = Line2D.new()
	border.position = hand_rect.position
	border.width = 2.0
	border.default_color = PREVIEW_SPELL_HAND_BORDER
	border.closed = true
	border.points = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(hand_rect.size.x, 0.0),
		Vector2(hand_rect.size.x, hand_rect.size.y),
		Vector2(0.0, hand_rect.size.y)
	])
	board_preview.add_child(border)

	var title_label = Label.new()
	title_label.position = hand_rect.position + Vector2(8.0, 4.0)
	title_label.size = Vector2(max(hand_rect.size.x - 16.0, 20.0), 22.0)
	title_label.text = "%s (%d/%d)" % [title, (preview_spell_hands.get(owner, []) as Array).size(), _get_spell_hand_size_for_owner(owner)]
	title_label.add_theme_font_size_override("font_size", 12)
	title_label.add_theme_color_override("font_color", _preview_drop_pool_text_color(owner))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(title_label)

	var entries: Array = preview_spell_hands.get(owner, [])
	var row_height = max(preview_tile_size * 0.34, 16.0)
	var row_spacing = 2
	var content_x = hand_rect.position.x + 8.0
	var content_y = hand_rect.position.y + 24.0
	var content_width = max(hand_rect.size.x - 16.0, 24.0)
	var body_height = max(hand_rect.size.y - 30.0, row_height)
	preview_spell_hand_viewport_rects[owner] = Rect2(content_x, content_y, content_width, body_height)
	var entry_rects: Array = []

	if entries.is_empty():
		preview_spell_hand_scroll_offsets[owner] = 0
		var empty_label = Label.new()
		empty_label.position = Vector2(content_x, content_y)
		empty_label.size = Vector2(content_width, body_height)
		empty_label.text = "(click to add selected card)"
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.add_theme_color_override("font_color", _preview_drop_pool_text_color(owner))
		empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_preview.add_child(empty_label)
		preview_spell_hand_entry_rects[owner] = entry_rects
		return

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(content_x, content_y)
	scroll.size = Vector2(content_width, body_height)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	board_preview.add_child(scroll)

	var rows = VBoxContainer.new()
	rows.custom_minimum_size = Vector2(content_width, 0.0)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", row_spacing)
	scroll.add_child(rows)

	var total_rows_height = entries.size() * row_height + max(entries.size() - 1, 0) * row_spacing
	rows.custom_minimum_size = Vector2(content_width, max(body_height, total_rows_height))

	var y_offset = 0.0
	for index in range(entries.size()):
		var card_id = str(entries[index])
		var row_rect = Rect2(Vector2(0.0, y_offset), Vector2(content_width, row_height))
		var row_label = Label.new()
		row_label.custom_minimum_size = Vector2(content_width, row_height)
		row_label.clip_text = true
		row_label.text = _spell_card_name(card_id)
		row_label.tooltip_text = _spell_card_name(card_id)
		row_label.add_theme_font_size_override("font_size", 12)
		row_label.add_theme_color_override("font_color", _preview_drop_pool_text_color(owner))
		row_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rows.add_child(row_label)
		entry_rects.append({"card_id": card_id, "rect": row_rect})
		y_offset += row_height + row_spacing

	var saved_scroll = int(preview_spell_hand_scroll_offsets.get(owner, 0))
	scroll.scroll_vertical = saved_scroll
	preview_spell_hand_scroll_offsets[owner] = scroll.scroll_vertical

	preview_spell_hand_entry_rects[owner] = entry_rects

func _draw_preview_promotion_zone_tints(width: int, height: int) -> void:
	if not promotion_check_box.button_pressed:
		return
	if width <= 0 or height <= 0:
		return

	var zones = _build_promotion_zones()
	var white_rows = clamp(int(zones.get("white_rows", 1)), 1, height)
	var black_rows = clamp(int(zones.get("black_rows", 1)), 1, height)
	var white_tint = _promotion_zone_tint_color("white")
	var black_tint = _promotion_zone_tint_color("black")
	var overlap_tint = Color(
		(white_tint.r + black_tint.r) * 0.5,
		(white_tint.g + black_tint.g) * 0.5,
		(white_tint.b + black_tint.b) * 0.5,
		max(white_tint.a, black_tint.a)
	)

	for y in range(height):
		var in_white_zone = y < white_rows
		var in_black_zone = y >= height - black_rows
		if not in_white_zone and not in_black_zone:
			continue
		var row_tint = overlap_tint
		if in_white_zone and not in_black_zone:
			row_tint = white_tint
		elif in_black_zone and not in_white_zone:
			row_tint = black_tint
		for x in range(width):
			var overlay = ColorRect.new()
			overlay.position = preview_board_origin + Vector2(x * preview_tile_size, y * preview_tile_size)
			overlay.size = Vector2(preview_tile_size, preview_tile_size)
			overlay.color = row_tint
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			board_preview.add_child(overlay)

func _promotion_zone_tint_color(owner: String) -> Color:
	var base = _get_player_color(owner)
	return Color(
		clampf(base.r * 0.35 + 0.10, 0.0, 1.0),
		clampf(base.g * 0.35 + 0.10, 0.0, 1.0),
		clampf(base.b * 0.35 + 0.10, 0.0, 1.0),
		0.42
	)

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

	var pool_width = _preview_side_panel_width()
	var pool_height = clampf(board_pixel_size.y * 0.68, 120.0, board_preview.size.y - 24.0)
	var pool_y = clampf(preview_board_origin.y + (board_pixel_size.y - pool_height) * 0.5, 8.0, board_preview.size.y - pool_height - 8.0)

	preview_white_drop_pool_rect = Rect2(8.0, pool_y, pool_width, pool_height)
	preview_black_drop_pool_rect = Rect2(board_preview.size.x - pool_width - 8.0, pool_y, pool_width, pool_height)

	_draw_single_preview_drop_pool(preview_white_drop_pool_rect, "Player 1 Drop Pool", "white")
	_draw_single_preview_drop_pool(preview_black_drop_pool_rect, "Player 2 Drop Pool", "black")

func _draw_single_preview_drop_pool(pool_rect: Rect2, title: String, pool_owner: String) -> void:
	var background = ColorRect.new()
	background.position = pool_rect.position
	background.size = pool_rect.size
	background.color = _preview_drop_pool_color(pool_owner, preview_drop_pool_hover_owner == pool_owner)
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
	title_label.size = Vector2(max(pool_rect.size.x - 16.0, 20.0), 40.0)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	if title.ends_with(" Drop Pool"):
		title_label.text = "%s\nDrop Pool" % title.trim_suffix(" Drop Pool")
	else:
		title_label.text = title
	title_label.add_theme_font_size_override("font_size", 13)
	title_label.add_theme_color_override("font_color", _preview_drop_pool_text_color(pool_owner))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(title_label)

	var entries: Array = _get_preview_drop_pool_display_entries(pool_owner)
	var entry_rects: Array = []
	var content_x = pool_rect.position.x + 8.0
	var current_y = pool_rect.position.y + 48.0
	var row_height = max(preview_tile_size * 0.42, 18.0)
	var row_spacing = 2
	var content_width = max(pool_rect.size.x - 16.0, 24.0)
	var body_height = max(pool_rect.size.y - 58.0, row_height)
	preview_drop_pool_viewport_rects[pool_owner] = Rect2(content_x, current_y, content_width, body_height)
	var row_font_size = int(clampf(preview_tile_size * 0.34, 10.0, 13.0))
	if entries.is_empty():
		preview_drop_pool_scroll_offsets[pool_owner] = 0
		var empty_label = Label.new()
		empty_label.position = Vector2(content_x, current_y)
		empty_label.size = Vector2(content_width, body_height)
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.clip_text = true
		empty_label.text = "(empty)"
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", _preview_drop_pool_text_color(pool_owner))
		empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_preview.add_child(empty_label)
		preview_drop_pool_entry_rects[pool_owner] = entry_rects
		return

	var scroll = ScrollContainer.new()
	scroll.position = Vector2(content_x, current_y)
	scroll.size = Vector2(content_width, body_height)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	board_preview.add_child(scroll)

	var rows = VBoxContainer.new()
	rows.custom_minimum_size = Vector2(content_width, 0.0)
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", row_spacing)
	scroll.add_child(rows)

	var total_rows_height = entries.size() * row_height + max(entries.size() - 1, 0) * row_spacing
	rows.custom_minimum_size = Vector2(content_width, max(body_height, total_rows_height))

	var y_offset = 0.0
	for index in range(entries.size()):
		var entry = entries[index]
		var piece_id = str(entry.get("piece_id", ""))
		var count = int(entry.get("count", 0))
		var row_rect = Rect2(Vector2(0.0, y_offset), Vector2(content_width, row_height))
		var row_label = Label.new()
		row_label.custom_minimum_size = Vector2(content_width, row_height)
		row_label.clip_text = true
		row_label.text = "%s x%d" % [_get_piece_symbol(piece_id), count]
		row_label.add_theme_font_size_override("font_size", row_font_size)
		row_label.add_theme_color_override("font_color", _preview_drop_pool_text_color(pool_owner))
		row_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rows.add_child(row_label)
		entry_rects.append({"piece_id": piece_id, "rect": row_rect})
		y_offset += row_height + row_spacing

	var saved_scroll = int(preview_drop_pool_scroll_offsets.get(pool_owner, 0))
	scroll.scroll_vertical = saved_scroll
	preview_drop_pool_scroll_offsets[pool_owner] = scroll.scroll_vertical

	preview_drop_pool_entry_rects[pool_owner] = entry_rects

func _preview_drop_pool_color(owner: String, hovered: bool) -> Color:
	var base_color = _get_player_color(owner)
	var dim = 0.16
	var bright = 0.28 if hovered else 0.20
	return Color(
		clampf(base_color.r * 0.55 + bright, 0.0, 1.0),
		clampf(base_color.g * 0.55 + bright, 0.0, 1.0),
		clampf(base_color.b * 0.55 + bright, 0.0, 1.0),
		0.92 if hovered else 0.86
	)

func _preview_drop_pool_text_color(owner: String) -> Color:
	return _best_contrast_text_color(_preview_drop_pool_color(owner, false))

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
	var piece_id = str(piece_data.get("piece_id", ""))
	var path_strokes = $"/root/GameManager".get_piece_path_strokes(piece_id)
	if not path_strokes.is_empty():
		var icon_extent = max(preview_tile_size * 0.68, 12.0)
		var icon_offset = (preview_tile_size - icon_extent) * 0.5
		var stroke_width = icon_extent * $"/root/GameManager".get_piece_path_stroke_width(piece_id)
		_add_preview_piece_path_visual(piece_root, path_strokes, Vector2(icon_offset, icon_offset), icon_extent, stroke_width, _piece_fill_color(piece_data.get("color", "white")), _piece_outline_color(piece_data.get("color", "white")), tint)
		return piece_root

	var icon_texture = $"/root/GameManager".get_piece_icon_texture(piece_id)
	if icon_texture != null:
		var icon_extent = max(preview_tile_size * 0.68, 12.0)
		var icon_offset = (preview_tile_size - icon_extent) * 0.5
		var icon = TextureRect.new()
		icon.position = Vector2(icon_offset, icon_offset)
		icon.size = Vector2(icon_extent, icon_extent)
		icon.texture = icon_texture
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.modulate = tint
		piece_root.add_child(icon)
		return piece_root

	var label = Label.new()
	label.size = piece_root.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = _get_piece_symbol(piece_id)
	label.add_theme_font_size_override("font_size", int(max(preview_tile_size * 0.55, 12.0)))
	label.add_theme_constant_override("outline_size", max(int(preview_tile_size * 0.06), 2))
	label.add_theme_color_override("font_color", _piece_fill_color(piece_data.get("color", "white")))
	label.add_theme_color_override("font_outline_color", _piece_outline_color(piece_data.get("color", "white")))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.modulate = tint
	piece_root.add_child(label)

	return piece_root

func _add_preview_piece_path_visual(parent: Control, path_strokes: Array, origin: Vector2, extent: float, stroke_width: float, fill_color: Color, outline_color: Color, tint: Color) -> void:
	for stroke_data in path_strokes:
		if not (stroke_data is Array):
			continue
		var points := PackedVector2Array()
		for point_data in stroke_data:
			if not (point_data is Dictionary):
				continue
			var px = clampf(float(point_data.get("x", 0.0)), 0.0, 1.0)
			var py = clampf(float(point_data.get("y", 0.0)), 0.0, 1.0)
			points.append(Vector2(origin.x + px * extent, origin.y + py * extent))
		if points.size() < 2:
			continue

		var outline_line = Line2D.new()
		outline_line.points = points
		outline_line.default_color = outline_color
		outline_line.width = stroke_width + max(2.0, stroke_width * 0.4)
		outline_line.joint_mode = Line2D.LINE_JOINT_ROUND
		outline_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		outline_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		outline_line.modulate = tint
		parent.add_child(outline_line)

		var fill_line = Line2D.new()
		fill_line.points = points
		fill_line.default_color = fill_color
		fill_line.width = stroke_width
		fill_line.joint_mode = Line2D.LINE_JOINT_ROUND
		fill_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		fill_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		fill_line.modulate = tint
		parent.add_child(fill_line)

func _scaled_item_icon(texture: Texture2D, target_size: int) -> Texture2D:
	if texture == null or target_size <= 0:
		return texture
	var image = texture.get_image()
	if image == null or image.is_empty():
		return texture
	image.resize(target_size, target_size, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)

func _piece_fill_color(piece_color: String) -> Color:
	return _get_player_color(piece_color)

func _piece_outline_color(piece_color: String) -> Color:
	var fill = _get_player_color(piece_color)
	return Color(0.08, 0.08, 0.08, 1.0) if _color_luma(fill) > 0.56 else Color(1.0, 1.0, 1.0, 1.0)

func _get_player_color(owner: String) -> Color:
	if owner == "black":
		return player_side_colors.get("black", Color(0.08, 0.08, 0.08, 1.0))
	return player_side_colors.get("white", Color(1.0, 1.0, 1.0, 1.0))

func _color_luma(color_value: Color) -> float:
	return color_value.r * 0.299 + color_value.g * 0.587 + color_value.b * 0.114

func _best_contrast_text_color(background: Color) -> Color:
	return Color(0.08, 0.08, 0.08, 1.0) if _color_luma(background) > 0.55 else Color(0.95, 0.95, 0.95, 1.0)

func _serialize_color(color_value: Color) -> Dictionary:
	return {
		"r": color_value.r,
		"g": color_value.g,
		"b": color_value.b,
		"a": 1.0
	}

func _color_from_variant(source: Variant, fallback: Color) -> Color:
	if source is Dictionary:
		return Color(
			float(source.get("r", fallback.r)),
			float(source.get("g", fallback.g)),
			float(source.get("b", fallback.b)),
			1.0
		)
	if source is Array and source.size() >= 3:
		return Color(float(source[0]), float(source[1]), float(source[2]), 1.0)
	return fallback

func _apply_player_colors_from_serialized(serialized: Variant) -> void:
	var fallback_white = Color(1.0, 1.0, 1.0, 1.0)
	var fallback_black = Color(0.08, 0.08, 0.08, 1.0)
	var white_color = fallback_white
	var black_color = fallback_black
	if serialized is Dictionary:
		white_color = _color_from_variant(serialized.get("white", fallback_white), fallback_white)
		black_color = _color_from_variant(serialized.get("black", fallback_black), fallback_black)
	player_side_colors["white"] = white_color
	player_side_colors["black"] = black_color
	player1_color_button.color = white_color
	player2_color_button.color = black_color

func _serialize_player_colors() -> Dictionary:
	return {
		"white": _serialize_color(_get_player_color("white")),
		"black": _serialize_color(_get_player_color("black"))
	}

func _apply_tile_colors_from_serialized(serialized: Variant) -> void:
	var fallback_light = Color(1.0, 1.0, 1.0, 1.0)
	var fallback_dark = Color(0.41, 0.41, 0.41, 1.0)
	var light_color = fallback_light
	var dark_color = fallback_dark
	if serialized is Dictionary:
		light_color = _color_from_variant(serialized.get("light", fallback_light), fallback_light)
		dark_color = _color_from_variant(serialized.get("dark", fallback_dark), fallback_dark)
	board_tile_colors["light"] = light_color
	board_tile_colors["dark"] = dark_color
	light_tile_color_button.color = light_color
	dark_tile_color_button.color = dark_color

func _serialize_tile_colors() -> Dictionary:
	return {
		"light": _serialize_color(board_tile_colors.get("light", Color(1.0, 1.0, 1.0, 1.0))),
		"dark": _serialize_color(board_tile_colors.get("dark", Color(0.41, 0.41, 0.41, 1.0)))
	}

func _get_board_tile_color(is_light_tile: bool) -> Color:
	if is_light_tile:
		return board_tile_colors.get("light", Color(1.0, 1.0, 1.0, 1.0))
	return board_tile_colors.get("dark", Color(0.41, 0.41, 0.41, 1.0))

func _on_board_preview_gui_input(event: InputEvent) -> void:
	if dragging_piece_bank_piece:
		if event is InputEventMouseMotion:
			piece_bank_drag_preview_position = event.position
			preview_drop_pool_hover_owner = _preview_drop_pool_side_at_position(event.position)
			_refresh_preview()
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if _update_preview_panel_scroll(event.position, -1):
				return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if _update_preview_panel_scroll(event.position, 1):
				return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _try_add_preview_spell_hand_card(event.position):
					return
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
				if _try_remove_preview_spell_hand_card(event.position):
					return
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

func _try_add_preview_spell_hand_card(position: Vector2) -> bool:
	if not _is_spell_cards_enabled() or _is_random_spell_cards_enabled():
		return false
	var owner = _preview_spell_hand_side_at_position(position)
	if owner == "":
		return false
	if selected_spell_card_id == "":
		_show_preview_warning("Select a card in Assign Card before adding to Player Hand.")
		return true
	if not _is_spell_card_enabled_in_list(selected_spell_card_id):
		_show_preview_warning("Selected card is not enabled in Available Cards.")
		return true
	var hand: Array = preview_spell_hands.get(owner, [])
	if hand.size() >= _get_spell_hand_size_for_owner(owner):
		_show_preview_warning("%s hand is full (%d)." % [_format_owner_name(owner), _get_spell_hand_size_for_owner(owner)])
		return true
	if not _is_spell_card_duplicates_allowed() and hand.has(selected_spell_card_id):
		_show_preview_warning("%s hand cannot contain duplicate cards." % _format_owner_name(owner))
		return true
	hand.append(selected_spell_card_id)
	preview_spell_hands[owner] = hand
	_refresh_preview()
	return true

func _try_remove_preview_spell_hand_card(position: Vector2) -> bool:
	if not _is_spell_cards_enabled() or _is_random_spell_cards_enabled():
		return false
	var owner = _preview_spell_hand_side_at_position(position)
	if owner == "":
		return false
	var entry = _get_preview_spell_hand_entry_at_position(owner, position)
	if entry.is_empty():
		return true
	var card_id = str(entry.get("card_id", ""))
	var hand: Array = preview_spell_hands.get(owner, [])
	var remove_index = hand.find(card_id)
	if remove_index >= 0:
		hand.remove_at(remove_index)
		preview_spell_hands[owner] = hand
	_refresh_preview()
	return true

func _preview_spell_hand_side_at_position(position: Vector2) -> String:
	if preview_white_spell_hand_rect.has_point(position):
		return "white"
	if preview_black_spell_hand_rect.has_point(position):
		return "black"
	return ""

func _get_preview_spell_hand_entry_at_position(owner: String, position: Vector2) -> Dictionary:
	var viewport_rect: Rect2 = preview_spell_hand_viewport_rects.get(owner, Rect2())
	if not viewport_rect.has_point(position):
		return {}
	var local_position = Vector2(
		position.x - viewport_rect.position.x,
		position.y - viewport_rect.position.y + int(preview_spell_hand_scroll_offsets.get(owner, 0))
	)
	var entries: Array = preview_spell_hand_entry_rects.get(owner, [])
	for entry in entries:
		if entry is Dictionary and Rect2(entry.get("rect", Rect2())).has_point(local_position):
			return entry
	return {}

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
	_clear_army_strength_warning()
	_refresh_preview()
	return true

func _get_preview_drop_pool_entry_at_position(pool_owner: String, position: Vector2) -> Dictionary:
	var viewport_rect: Rect2 = preview_drop_pool_viewport_rects.get(pool_owner, Rect2())
	if not viewport_rect.has_point(position):
		return {}
	var local_position = Vector2(
		position.x - viewport_rect.position.x,
		position.y - viewport_rect.position.y + int(preview_drop_pool_scroll_offsets.get(pool_owner, 0))
	)
	var entries: Array = preview_drop_pool_entry_rects.get(pool_owner, [])
	for entry in entries:
		if entry is Dictionary and Rect2(entry.get("rect", Rect2())).has_point(local_position):
			return entry
	return {}

func _update_preview_panel_scroll(position: Vector2, direction: int) -> bool:
	if direction == 0:
		return false
	for owner in ["white", "black"]:
		var hand_view: Rect2 = preview_spell_hand_viewport_rects.get(owner, Rect2())
		if hand_view.has_point(position):
			var total_height = 0.0
			for entry in preview_spell_hand_entry_rects.get(owner, []):
				total_height = max(total_height, Rect2(entry.get("rect", Rect2())).end.y)
			var max_scroll = max(int(ceil(total_height - hand_view.size.y)), 0)
			var next_scroll = clamp(int(preview_spell_hand_scroll_offsets.get(owner, 0)) + direction * 24, 0, max_scroll)
			preview_spell_hand_scroll_offsets[owner] = next_scroll
			_refresh_preview()
			return true

	for owner in ["white", "black"]:
		var pool_view: Rect2 = preview_drop_pool_viewport_rects.get(owner, Rect2())
		if pool_view.has_point(position):
			var total_height = 0.0
			for entry in preview_drop_pool_entry_rects.get(owner, []):
				total_height = max(total_height, Rect2(entry.get("rect", Rect2())).end.y)
			var max_scroll = max(int(ceil(total_height - pool_view.size.y)), 0)
			var next_scroll = clamp(int(preview_drop_pool_scroll_offsets.get(owner, 0)) + direction * 24, 0, max_scroll)
			preview_drop_pool_scroll_offsets[owner] = next_scroll
			_refresh_preview()
			return true

	return false

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
		_add_piece_to_preview_drop_pool(target_pool, piece_bank_drag_piece_id, true)
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
	_add_piece_to_preview_drop_pool(target_pool, str(piece_data.get("piece_id", "")), false)
	preview_drop_pool_hover_owner = ""
	_refresh_preview()
	return true

func _preview_drop_pool_side_at_position(position: Vector2) -> String:
	if preview_white_drop_pool_rect.has_point(position):
		return "white"
	if preview_black_drop_pool_rect.has_point(position):
		return "black"
	return ""

func _add_piece_to_preview_drop_pool(pool_owner: String, piece_id: String, enforce_limit: bool) -> void:
	if piece_id == "":
		return
	if enforce_limit and not _can_add_to_preview_drop_pool(pool_owner, piece_id):
		return
	var pool_contents: Array = preview_drop_pools.get(pool_owner, [])
	pool_contents.append(piece_id)
	preview_drop_pools[pool_owner] = pool_contents
	_clear_army_strength_warning()

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
		if not _can_place_preview_piece(square, selected_piece_id, selected_piece_color):
			return
		preview_pieces[square] = {
			"piece_id": selected_piece_id,
			"color": selected_piece_color
		}
		_clear_army_strength_warning()
		selected_preview_square = square
	else:
		preview_pieces.erase(square)
		if selected_preview_square == square:
			selected_preview_square = INVALID_SQUARE
		_clear_army_strength_warning()

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
		"victory_condition": _build_victory_condition(),
		"special_rules": _build_special_rules(),
		"spell_cards": _build_spell_card_config(),
		"army_strength_cap": _get_army_strength_cap_value(),
		"army_strength_caps": {
			"white": _get_unbalanced_army_strength_cap_value("white"),
			"black": _get_unbalanced_army_strength_cap_value("black")
		},
		"promotion_pieces": _build_promotion_piece_pool(),
		"promotion_zones": _build_promotion_zones(),
		"territory_rows": _territory_rows_value(),
		"player_colors": _serialize_player_colors(),
		"tile_colors": _serialize_tile_colors()
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
	preview_spell_hands = {
		"white": [],
		"black": []
	}
	last_drag_square = INVALID_SQUARE
	selected_preview_square = INVALID_SQUARE
	_clear_army_strength_warning(true)
	_refresh_preview()

func _on_reset_setup_button_pressed() -> void:
	_reset_preview_to_default(true, false)

func _on_back_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_start_game_button_pressed() -> void:
	if is_editing_preset_mode:
		if PRESETS.has(editing_preset_name):
			preview_warning_label.text = "Built-in presets cannot be overwritten. Rename and save as a custom preset."
			preview_warning_label.visible = true
			return
		$"/root/GameManager".save_preset(editing_preset_name, _build_preset_config())
		get_tree().change_scene_to_file("res://Scenes/ManagePresets.tscn")
		return

	var height = height_spin_box.value
	var width = width_spin_box.value
	
	$"/root/GameManager".BoardHeight = height
	$"/root/GameManager".BoardWidth = width
	$"/root/GameManager".StartingPieces = _serialize_preview_pieces()
	$"/root/GameManager".StartingDropPools = _serialize_drop_pools()
	$"/root/GameManager".VictoryCondition = _build_victory_condition()
	$"/root/GameManager".SpecialRules = _build_special_rules()
	$"/root/GameManager".SpellCardHandSize = _get_spell_hand_size_value()
	$"/root/GameManager".SpellCardHandSizeWhite = _get_spell_hand_size_for_owner("white")
	$"/root/GameManager".SpellCardHandSizeBlack = _get_spell_hand_size_for_owner("black")
	$"/root/GameManager".SpellCardsRandom = _is_random_spell_cards_enabled()
	$"/root/GameManager".SpellCardAllowDuplicates = _is_spell_card_duplicates_allowed()
	$"/root/GameManager".SpellCardDrawReplacementAfterCast = _is_draw_replacement_after_cast_enabled()
	$"/root/GameManager".SpellCardAvailableIds = _build_enabled_spell_card_ids()
	$"/root/GameManager".StartingSpellHands = _build_spell_card_hands()
	$"/root/GameManager".ArmyStrengthCap = _get_army_strength_cap_value()
	$"/root/GameManager".ArmyStrengthCapWhite = _get_unbalanced_army_strength_cap_value("white")
	$"/root/GameManager".ArmyStrengthCapBlack = _get_unbalanced_army_strength_cap_value("black")
	$"/root/GameManager".PromotionPiecePool = _build_promotion_piece_pool()
	$"/root/GameManager".PromotionZones = _build_promotion_zones()
	$"/root/GameManager".TerritoryRows = _territory_rows_value()
	$"/root/GameManager".PlayerColors = _serialize_player_colors()
	$"/root/GameManager".TileColors = _serialize_tile_colors()

	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager != null and network_manager.is_hosting and not network_manager.is_online_active():
		if not network_manager.start_hosted_match():
			preview_warning_label.text = "Online start failed. Make sure player 2 is connected."
			preview_warning_label.visible = true
			return
	
	#var LocalGame = load("res://Scenes/LocalGame.tscn")
	#get_tree().current_scene.add_child(LocalGame)
	get_tree().change_scene_to_file("res://Scenes/LocalGame.tscn")
