extends Control

const UITheme = preload("res://Scripts/ui_theme.gd")

@onready var width_spin_box: SpinBox = $OptionsScroll/OptionsContent/WidthSpinBox
@onready var height_spin_box: SpinBox = $OptionsScroll/OptionsContent/HeightSpinBox
@onready var options_scroll: ScrollContainer = $OptionsScroll
@onready var preview_area: Panel = $PreviewArea
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
@onready var player1_color_button: Button = $OptionsScroll/OptionsContent/Player1ColorButton
@onready var player2_color_button: Button = $OptionsScroll/OptionsContent/Player2ColorButton
@onready var light_tile_color_button: Button = $OptionsScroll/OptionsContent/LightTileColorButton
@onready var dark_tile_color_button: Button = $OptionsScroll/OptionsContent/DarkTileColorButton
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
const PREVIEW_ZONE_PROMOTION_RING = Color(0.36, 0.84, 0.34, 0.92)
const PREVIEW_ZONE_MUSTER_RING = Color(0.52, 0.35, 0.18, 0.92)
const NAV_BUTTON_ACTIVE_COLOR = Color(0.18, 0.30, 0.45, 1.0)
const NAV_BUTTON_INACTIVE_COLOR = Color(0.12, 0.12, 0.14, 1.0)
const NAV_BUTTON_TEXT_COLOR = Color(0.94, 0.96, 1.0, 1.0)
const NAV_BUTTON_ACTIVE_TEXT_COLOR = Color(1.0, 1.0, 1.0, 1.0)
const RULE_BUTTON_ON_COLOR = Color(0.15, 0.38, 0.22, 1.0)
const RULE_BUTTON_OFF_COLOR = Color(0.34, 0.19, 0.16, 1.0)
const RULE_BUTTON_SELECTED_OUTLINE = Color(0.96, 0.84, 0.54, 1.0)
const RULE_BUTTON_DISABLED_COLOR = Color(0.22, 0.22, 0.22, 1.0)
const PAGE_ANIMATION_DURATION = 0.16
const SECTION_BUTTON_VERTICAL_PADDING = 10.0
const SECTION_CONTENT_TOP_GAP = 14.0
const SECTION_CONTENT_PANEL_HEIGHT = 1860.0
const SECTION_CONTENT_BOTTOM_PADDING = 36.0
const SPECIAL_RULE_BUTTON_VERTICAL_PADDING = 8.0
const PIECE_COLOR_SWATCH_SIZE = 16
const PRESETS = {
	"Standard Chess": "standard_chess",
	"Standard Shogi": "standard_shogi",
	"Gungi": "gungi"
}
const SECTION_ORDER: Array[String] = [
	"board",
	"pieces",
	"presets",
	"victory",
	"special_rules",
	"colors"
]
const SECTION_LABELS = {
	"board": "Board Setup",
	"pieces": "Available Pieces",
	"presets": "Presets",
	"victory": "Victory Condition",
	"special_rules": "Special Rules",
	"colors": "Colors"
}
const SECTION_ICONS = {
	"board": "▦",
	"pieces": "♞",
	"presets": "▤",
	"victory": "⚑",
	"special_rules": "◇",
	"colors": "◌"
}
const SECTION_HELPERS = {
	"board": "Choose the board dimensions before arranging anything else.",
	"pieces": "Pick from the available piece bank, then place pieces on the preview board.",
	"presets": "Load, save, and manage reusable game setups.",
	"victory": "Set the win condition that defines how the match ends.",
	"special_rules": "Select a rule card to toggle it and reveal its related options.",
	"colors": "Tune player and tile colors to match the mood of the variant."
}
const SECTION_NODE_NAMES = {
	"board": ["BoardSizeTitleBackground", "BoardSizeTitle", "BoardWidth", "WidthSpinBox", "BoardHeight", "HeightSpinBox", "PreviewInstructions"],
	"pieces": ["PieceBankTitleBackground", "PieceBankTitle", "PieceBankList", "PieceColorLabelBackground", "PieceColorLabel", "PieceColorOption"],
	"presets": ["PresetsTitleBackground", "PresetsTitle", "PresetList", "PresetNameInput", "SavePresetButton", "DeletePresetButton"],
	"victory": ["VictoryConditionTitleBackground", "VictoryConditionTitle", "VictoryConditionOption", "VictoryConditionDescription"],
	"special_rules": ["SpecialRulesTitleBackground", "SpecialRulesTitle", "SpecialRuleButtonBox"],
	"colors": ["PlayerColorsTitleBackground", "PlayerColorsTitle", "Player1ColorLabel", "Player1ColorButton", "Player2ColorLabel", "Player2ColorButton", "TileColorsTitleBackground", "TileColorsTitle", "LightTileColorLabel", "LightTileColorButton", "DarkTileColorLabel", "DarkTileColorButton"]
}
const SPECIAL_RULE_ORDER: Array[String] = [
	"allow_undo",
	"castling",
	"en_passant",
	"promotion",
	"piece_dropping",
	"piece_stacking",
	"enable_territory",
	"enable_muster",
	"limit_army_strength",
	"enable_spell_cards"
]
const SPECIAL_RULE_LABELS = {
	"allow_undo": "Undo",
	"castling": "Castling",
	"en_passant": "En Passant",
	"promotion": "Promotion",
	"piece_dropping": "Piece Dropping",
	"piece_stacking": "Stacking",
	"enable_territory": "Territory",
	"enable_muster": "Muster",
	"limit_army_strength": "Army Cap",
	"enable_spell_cards": "Spell Cards"
}
const SPECIAL_RULE_ICONS = {
	"allow_undo": "↺",
	"castling": "♖",
	"en_passant": "⇄",
	"promotion": "↑",
	"piece_dropping": "↓",
	"piece_stacking": "▥",
	"enable_territory": "⌂",
	"enable_muster": "◈",
	"limit_army_strength": "≡",
	"enable_spell_cards": "✦"
}
const SPECIAL_RULE_HELPERS = {
	"allow_undo": "Allow players to rewind the last action locally.",
	"castling": "Enable standard king-rook castling when the board setup supports it.",
	"en_passant": "Allow the special pawn capture after a two-square advance.",
	"promotion": "Configure promotion zones and which pieces promotion can become.",
	"piece_dropping": "Allow pieces from pools to be dropped back onto the board.",
	"piece_stacking": "Enable stack-based movement growth and same/lower-level stacking rules.",
	"enable_territory": "Restrict certain setup actions to each side's home territory.",
	"enable_muster": "Start with an empty board and deploy pieces through the muster phase.",
	"limit_army_strength": "Cap the total strength a side may field across board and pool.",
	"enable_spell_cards": "Enable spell-card hands and configure how cards are dealt and assigned."
}
const SPECIAL_RULE_NODE_NAMES = {
	"allow_undo": ["AllowUndoCheckBox"],
	"castling": ["CastlingCheckBox", "CastlingSupportHintBackground", "CastlingSupportHint"],
	"en_passant": ["EnPassantCheckBox"],
	"promotion": ["PromotionCheckBox", "PromotionZonesTitleBackground", "PromotionZonesTitle", "Player1PromotionZoneLabel", "Player1PromotionZoneSpinBox", "Player2PromotionZoneLabel", "Player2PromotionZoneSpinBox", "PromotionPiecesTitleBackground", "PromotionPiecesTitle", "PromotionPiecesScroll"],
	"piece_dropping": ["PieceDroppingCheckBox", "CaptureToDropPoolCheckBox"],
	"piece_stacking": ["PieceStackingCheckBox"],
	"enable_territory": ["EnableTerritoryCheckBox", "TerritoryRowsLabel", "TerritoryRowsSpinBox"],
	"enable_muster": ["EnableMusterCheckBox", "TerritoryRowsLabel", "TerritoryRowsSpinBox"],
	"limit_army_strength": ["LimitArmyStrengthCheckBox", "UnbalancedArmiesCheckBox", "ArmyStrengthCapLabel", "ArmyStrengthCapSpinBox", "WhiteArmyStrengthCapLabel", "WhiteArmyStrengthCapSpinBox", "BlackArmyStrengthCapLabel", "BlackArmyStrengthCapSpinBox", "ArmyStrengthWarningLabel"],
	"enable_spell_cards": ["SpellCardsTitleBackground", "SpellCardsTitle", "EnableSpellCardsCheckBox", "SpellHandSizeLabel", "SpellHandSizeSpinBox", "SpellUnbalancedHandSizesCheckBox", "SpellHandSizeWhiteLabel", "SpellHandSizeWhiteSpinBox", "SpellHandSizeBlackLabel", "SpellHandSizeBlackSpinBox", "RandomSpellCardsCheckBox", "SpellAllowDuplicatesCheckBox", "SpellDrawReplacementAfterCastCheckBox", "SpellAssignCardLabel", "SpellAssignCardOption", "SpellCardsHintLabel", "AvailableSpellCardsTitleBackground", "AvailableSpellCardsTitle", "AvailableSpellCardsScroll"]
}
const SPECIAL_RULE_SUBOPTION_NODE_NAMES = {
	"allow_undo": [],
	"castling": [],
	"en_passant": [],
	"promotion": ["Player1PromotionZoneSpinBox", "Player2PromotionZoneSpinBox", "PromotionPiecesScroll"],
	"piece_dropping": ["CaptureToDropPoolCheckBox"],
	"piece_stacking": [],
	"enable_territory": ["TerritoryRowsSpinBox"],
	"enable_muster": [],
	"limit_army_strength": ["UnbalancedArmiesCheckBox", "ArmyStrengthCapSpinBox", "WhiteArmyStrengthCapSpinBox", "BlackArmyStrengthCapSpinBox"],
	"enable_spell_cards": ["SpellHandSizeSpinBox", "SpellUnbalancedHandSizesCheckBox", "SpellHandSizeWhiteSpinBox", "SpellHandSizeBlackSpinBox", "RandomSpellCardsCheckBox", "SpellAllowDuplicatesCheckBox", "SpellDrawReplacementAfterCastCheckBox", "SpellAssignCardOption", "AvailableSpellCardsScroll"]
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
var en_passant_user_preference = true
var is_updating_castling_availability = false
var is_updating_en_passant_availability = false
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
var section_button_box: FlowContainer
var section_buttons: Dictionary = {}
var active_section_id = "pieces"
var navigation_helper_label: Label
var section_content_panel: PanelContainer
var section_content_root: VBoxContainer
var section_pages: Dictionary = {}
var section_layout_built = false
var special_rule_button_box: FlowContainer
var special_rule_buttons: Dictionary = {}
var active_special_rule_id = "castling"
var special_rule_helper_label: Label
var special_rule_detail_title_label: Label
var special_rule_content_root: VBoxContainer
var special_rule_pages: Dictionary = {}
var zone_legend_white_swatch: ColorRect
var zone_legend_black_swatch: ColorRect
var shared_color_picker_dialog: AcceptDialog
var shared_color_picker: ColorPicker
var pending_color_target = ""
var is_applying_online_setup_sync = false
var last_online_setup_signature = ""
var player_side_colors = {
	"white": Color(1.0, 1.0, 1.0, 1.0),
	"black": Color(0.08, 0.08, 0.08, 1.0)
}
var board_tile_colors = {
	"light": Color(1.0, 1.0, 1.0, 1.0),
	"dark": Color(0.41, 0.41, 0.41, 1.0)
}

func _ready() -> void:
	_apply_scene_chrome_style()
	width_spin_box.value_changed.connect(_on_board_dimension_changed)
	height_spin_box.value_changed.connect(_on_board_dimension_changed)
	board_preview.gui_input.connect(_on_board_preview_gui_input)
	piece_bank_list.gui_input.connect(_on_piece_bank_gui_input)
	board_preview.resized.connect(_refresh_preview)
	board_preview.mouse_exited.connect(_on_board_preview_mouse_exited)
	preset_list.item_selected.connect(_on_preset_item_selected)
	_populate_piece_bank()
	_populate_presets()
	_ensure_shared_color_picker_dialog()
	_setup_piece_color_picker()
	_setup_player_color_pickers()
	_setup_tile_color_pickers()
	_setup_victory_condition_picker()
	_setup_special_rules()
	_connect_online_setup_collaboration()
	_setup_section_navigation_ui()
	resized.connect(_on_menu_resized)
	_reset_preview_to_default(false, false)
	_apply_pending_preset_selection()
	_update_menu_title_for_mode()
	_update_primary_action_for_mode()
	_set_active_section(active_section_id)
	_refresh_preview(0.0)
	call_deferred("_update_section_navigation_layout")

func _apply_scene_chrome_style() -> void:
	UITheme.ensure_flat_background(self)
	options_scroll.add_theme_stylebox_override("panel", UITheme.panel_style(Color(0.08, 0.09, 0.11, 0.95), UITheme.PANEL_BORDER, 12, 2))
	preview_area.add_theme_stylebox_override("panel", UITheme.panel_style(Color(0.08, 0.09, 0.11, 0.95), UITheme.PANEL_BORDER, 14, 2))
	if not local_game_title.text.begins_with("▦"):
		local_game_title.text = _icon_text("▦", local_game_title.text)
	UITheme.apply_title_text(local_game_title, 28)
	preview_warning_label.add_theme_color_override("font_color", Color(1.0, 0.42, 0.42, 1.0))
	preview_warning_label.add_theme_font_size_override("font_size", 20)
	UITheme.apply_secondary_button_theme(back_to_main_menu_button, 38.0, 14)
	UITheme.apply_button_theme(start_game_button, Color(0.16, 0.35, 0.28, 1.0), 38.0, 14)

func _update_menu_title_for_mode() -> void:
	if is_editing_preset_mode:
		local_game_title.text = "Edit preset %s" % editing_preset_name
		return
	var title_text = "Create Local game"
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager != null and network_manager.is_session_connected() and not network_manager.is_online_active():
		title_text = "Create Online Game"
	local_game_title.text = title_text

func _update_primary_action_for_mode() -> void:
	if is_editing_preset_mode:
		start_game_button.text = "Save Preset"
		back_to_main_menu_button.visible = false
		return
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager != null and network_manager.is_session_connected() and not network_manager.is_online_active() and not network_manager.is_hosting:
		start_game_button.text = "Waiting For Host"
		start_game_button.disabled = true
	else:
		start_game_button.text = "Start Game"
		start_game_button.disabled = false
	back_to_main_menu_button.visible = true

func _connect_online_setup_collaboration() -> void:
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager == null:
		return
	if network_manager.setup_snapshot_received.is_connected(_on_online_setup_snapshot_received):
		network_manager.setup_snapshot_received.disconnect(_on_online_setup_snapshot_received)
	network_manager.setup_snapshot_received.connect(_on_online_setup_snapshot_received)

func _is_online_setup_collaboration_active() -> bool:
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager == null:
		return false
	return network_manager.is_session_connected() and not network_manager.is_online_active()

func _build_online_setup_snapshot() -> Dictionary:
	var game_manager = $"/root/GameManager"
	return {
		"board_height": _get_dimension(height_spin_box.value, 8),
		"board_width": _get_dimension(width_spin_box.value, 8),
		"starting_pieces": _serialize_preview_pieces(),
		"starting_drop_pools": _serialize_drop_pools(),
		"special_rules": _build_special_rules(),
		"spell_card_hand_size": _get_spell_hand_size_value(),
		"spell_card_hand_size_white": _get_spell_hand_size_for_owner("white"),
		"spell_card_hand_size_black": _get_spell_hand_size_for_owner("black"),
		"spell_cards_random": _is_random_spell_cards_enabled(),
		"spell_card_allow_duplicates": _is_spell_card_duplicates_allowed(),
		"spell_draw_replacement_after_cast": _is_draw_replacement_after_cast_enabled(),
		"spell_card_available_ids": _build_enabled_spell_card_ids(),
		"starting_spell_hands": _build_spell_card_hands(),
		"promotion_piece_pool": _build_promotion_piece_pool(),
		"promotion_zones": _build_promotion_zones(),
		"territory_rows": _territory_rows_value(),
		"victory_condition": _build_victory_condition(),
		"army_strength_cap": _get_army_strength_cap_value(),
		"army_strength_cap_white": _get_unbalanced_army_strength_cap_value("white"),
		"army_strength_cap_black": _get_unbalanced_army_strength_cap_value("black"),
		"player_colors": _serialize_player_colors(),
		"tile_colors": _serialize_tile_colors(),
		"piece_bank": game_manager.PieceBank.duplicate(true),
		"piece_definitions": game_manager.PieceDefinitions.duplicate(true)
	}

func _setup_snapshot_signature(snapshot: Dictionary) -> String:
	return JSON.stringify(snapshot)

func _sync_online_setup_if_needed() -> void:
	if is_applying_online_setup_sync:
		return
	if not _is_online_setup_collaboration_active():
		return
	var snapshot = _build_online_setup_snapshot()
	var signature = _setup_snapshot_signature(snapshot)
	if signature == last_online_setup_signature:
		return
	last_online_setup_signature = signature
	var network_manager = get_node_or_null("/root/NetworkManager")
	if network_manager != null:
		network_manager.submit_setup_snapshot(snapshot)

func _on_online_setup_snapshot_received(snapshot: Dictionary) -> void:
	if not _is_online_setup_collaboration_active():
		return
	var signature = _setup_snapshot_signature(snapshot)
	if signature == last_online_setup_signature:
		return
	is_applying_online_setup_sync = true
	last_online_setup_signature = signature
	if snapshot.has("piece_bank"):
		_populate_piece_bank()
	_build_promotion_piece_checkboxes()
	_apply_saved_preset_config({
		"width": int(snapshot.get("board_width", width_spin_box.value)),
		"height": int(snapshot.get("board_height", height_spin_box.value)),
		"pieces": snapshot.get("starting_pieces", []),
		"drop_pools": snapshot.get("starting_drop_pools", {}),
		"victory_condition": str(snapshot.get("victory_condition", "checkmate")),
		"special_rules": snapshot.get("special_rules", {}),
		"spell_cards": {
			"hand_size": int(snapshot.get("spell_card_hand_size", 3)),
			"unbalanced_hand_sizes": int(snapshot.get("spell_card_hand_size_white", 3)) != int(snapshot.get("spell_card_hand_size_black", 3)),
			"hand_size_white": int(snapshot.get("spell_card_hand_size_white", 3)),
			"hand_size_black": int(snapshot.get("spell_card_hand_size_black", 3)),
			"random_cards": bool(snapshot.get("spell_cards_random", true)),
			"allow_duplicates": bool(snapshot.get("spell_card_allow_duplicates", true)),
			"draw_replacement_after_cast": bool(snapshot.get("spell_draw_replacement_after_cast", false)),
			"available_cards": snapshot.get("spell_card_available_ids", []),
			"starting_hands": snapshot.get("starting_spell_hands", {})
		},
		"army_strength_cap": int(snapshot.get("army_strength_cap", 32)),
		"army_strength_caps": {
			"white": int(snapshot.get("army_strength_cap_white", snapshot.get("army_strength_cap", 32))),
			"black": int(snapshot.get("army_strength_cap_black", snapshot.get("army_strength_cap", 32)))
		},
		"promotion_pieces": snapshot.get("promotion_piece_pool", ["queen", "rook", "bishop", "knight"]),
		"promotion_zones": snapshot.get("promotion_zones", {}),
		"territory_rows": int(snapshot.get("territory_rows", 3)),
		"player_colors": snapshot.get("player_colors", {}),
		"tile_colors": snapshot.get("tile_colors", {})
	})
	is_applying_online_setup_sync = false
	_update_menu_title_for_mode()
	_update_primary_action_for_mode()

func _setup_section_navigation_ui() -> void:
	options_content.custom_minimum_size.y = max(options_content.custom_minimum_size.y, 2160.0)
	_ensure_section_button_box()
	_ensure_navigation_helper_label()
	_ensure_section_content_panel()
	_ensure_special_rule_button_box()
	_build_container_layout()
	call_deferred("_update_section_navigation_layout")
	_refresh_section_button_states()
	_refresh_special_rule_button_states()
	call_deferred("_update_special_rule_button_layout")
	_refresh_section_visibility()

func _ensure_section_button_box() -> void:
	if section_button_box != null:
		return
	var existing = options_content.get_node_or_null("SectionButtonBox")
	if existing is FlowContainer:
		section_button_box = existing
	else:
		var container = FlowContainer.new()
		container.name = "SectionButtonBox"
		container.layout_mode = 0
		container.offset_left = 76.0
		container.offset_top = 126.0
		container.offset_right = 412.0
		container.offset_bottom = 184.0
		container.add_theme_constant_override("h_separation", 6)
		container.add_theme_constant_override("v_separation", 6)
		options_content.add_child(container)
		section_button_box = container

	section_buttons.clear()
	for child in section_button_box.get_children():
		child.queue_free()

	for section_id in SECTION_ORDER:
		var button = Button.new()
		button.text = _icon_text(str(SECTION_ICONS.get(section_id, "")), str(SECTION_LABELS.get(section_id, section_id.capitalize())))
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(106.0, 36.0)
		button.pressed.connect(_on_section_button_pressed.bind(section_id))
		section_button_box.add_child(button)
		section_buttons[section_id] = button

func _ensure_navigation_helper_label() -> void:
	if navigation_helper_label != null:
		return
	var existing = options_content.get_node_or_null("NavigationHelperLabel")
	if existing is Label:
		navigation_helper_label = existing
		return
	var helper_label = Label.new()
	helper_label.name = "NavigationHelperLabel"
	helper_label.layout_mode = 0
	helper_label.offset_left = 76.0
	helper_label.offset_top = 70.0
	helper_label.offset_right = 412.0
	helper_label.offset_bottom = 118.0
	helper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UITheme.apply_body_text(helper_label, 14)
	options_content.add_child(helper_label)
	navigation_helper_label = helper_label

func _ensure_section_content_panel() -> void:
	if section_content_panel != null and section_content_root != null:
		return
	var existing_panel = options_content.get_node_or_null("SectionContentPanel")
	if existing_panel is PanelContainer:
		section_content_panel = existing_panel
		section_content_root = existing_panel.get_node_or_null("SectionContentMargin/SectionContentRoot")
		return
	section_content_panel = PanelContainer.new()
	section_content_panel.name = "SectionContentPanel"
	section_content_panel.layout_mode = 0
	section_content_panel.offset_left = 76.0
	section_content_panel.offset_top = 240.0
	section_content_panel.offset_right = 412.0
	section_content_panel.offset_bottom = 2100.0
	var panel_style = UITheme.panel_style(Color(0.07, 0.08, 0.1, 0.94), UITheme.PANEL_BORDER, 12, 2)
	section_content_panel.add_theme_stylebox_override("panel", panel_style)
	options_content.add_child(section_content_panel)

	var margin = MarginContainer.new()
	margin.name = "SectionContentMargin"
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	section_content_panel.add_child(margin)

	section_content_root = VBoxContainer.new()
	section_content_root.name = "SectionContentRoot"
	section_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section_content_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section_content_root.add_theme_constant_override("separation", 14)
	margin.add_child(section_content_root)

func _ensure_special_rule_button_box() -> void:
	if special_rule_button_box != null:
		return
	var existing = options_content.get_node_or_null("SpecialRuleButtonBox")
	if existing is FlowContainer:
		special_rule_button_box = existing
	else:
		var container = FlowContainer.new()
		container.name = "SpecialRuleButtonBox"
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container.add_theme_constant_override("h_separation", 6)
		container.add_theme_constant_override("v_separation", 6)
		special_rule_button_box = container

	special_rule_buttons.clear()
	for child in special_rule_button_box.get_children():
		child.queue_free()

	for rule_id in SPECIAL_RULE_ORDER:
		var button = Button.new()
		button.text = _icon_text(str(SPECIAL_RULE_ICONS.get(rule_id, "")), str(SPECIAL_RULE_LABELS.get(rule_id, rule_id.capitalize())))
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(126.0, 36.0)
		button.pressed.connect(_on_special_rule_button_pressed.bind(rule_id))
		special_rule_button_box.add_child(button)
		special_rule_buttons[rule_id] = button

func _build_container_layout() -> void:
	if section_layout_built:
		return
	_hide_unused_absolute_headers()
	_build_section_pages()
	section_layout_built = true

func _hide_unused_absolute_headers() -> void:
	for node_name in [
		"BoardSizeTitleBackground", "BoardSizeTitle",
		"PieceBankTitleBackground", "PieceBankTitle",
		"PieceColorLabelBackground",
		"PresetsTitleBackground", "PresetsTitle",
		"SpecialRulesTitleBackground", "SpecialRulesTitle",
		"VictoryConditionTitleBackground", "VictoryConditionTitle",
		"PlayerColorsTitleBackground", "PlayerColorsTitle",
		"TileColorsTitleBackground", "TileColorsTitle",
		"SpellCardsTitleBackground", "SpellCardsTitle",
		"AvailableSpellCardsTitleBackground", "AvailableSpellCardsTitle",
		"PromotionZonesTitleBackground", "PromotionZonesTitle",
		"PromotionPiecesTitleBackground", "PromotionPiecesTitle"
	]:
		var node = _find_option_node(node_name)
		if node is CanvasItem:
			node.visible = false

func _build_section_pages() -> void:
	section_pages.clear()
	section_content_root.add_child(_build_board_section_page())
	section_content_root.add_child(_build_pieces_section_page())
	section_content_root.add_child(_build_presets_section_page())
	section_content_root.add_child(_build_victory_section_page())
	section_content_root.add_child(_build_special_rules_section_page())
	section_content_root.add_child(_build_colors_section_page())

func _make_section_page(section_id: String, title: String) -> VBoxContainer:
	var page = VBoxContainer.new()
	page.name = "%sPage" % section_id.capitalize()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 10)
	var title_label = Label.new()
	title_label.text = _icon_text(str(SECTION_ICONS.get(section_id, "")), title)
	UITheme.apply_section_text(title_label, 18)
	page.add_child(title_label)
	section_pages[section_id] = page
	return page

func _build_board_section_page() -> VBoxContainer:
	var page = _make_section_page("board", "Board Setup")
	page.add_child(_make_labeled_spin_row("BoardWidth", "WidthSpinBox", "BoardHeight", "HeightSpinBox"))
	page.add_child(_layout_existing_control(_find_option_node("PreviewInstructions"), true))
	page.add_child(_build_zone_legend_panel())
	return page

func _build_zone_legend_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var style = UITheme.panel_style(Color(0.11, 0.12, 0.15, 0.96), UITheme.PANEL_BORDER, 10, 1)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title = Label.new()
	title.text = _icon_text("◎", "Zone Ring Legend")
	UITheme.apply_body_text(title, 14)
	content.add_child(title)
	content.add_child(_build_zone_legend_row(PREVIEW_ZONE_PROMOTION_RING, "Promotion zone"))
	content.add_child(_build_zone_legend_row(PREVIEW_ZONE_MUSTER_RING, "Muster zone"))
	content.add_child(_build_zone_territory_legend_row())
	return panel

func _build_zone_legend_row(color_value: Color, text: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	row.add_child(_create_zone_legend_swatch(color_value))
	var label = Label.new()
	label.text = text
	UITheme.apply_muted_text(label, 13)
	row.add_child(label)
	return row

func _build_zone_territory_legend_row() -> VBoxContainer:
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var title = Label.new()
	title.text = "Territory rings use player colors"
	UITheme.apply_muted_text(title, 13)
	box.add_child(title)
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 14)
	zone_legend_white_swatch = _create_zone_legend_swatch(_get_player_color("white"))
	zone_legend_black_swatch = _create_zone_legend_swatch(_get_player_color("black"))
	row.add_child(_wrap_zone_legend_swatch(zone_legend_white_swatch, "Player 1 territory"))
	row.add_child(_wrap_zone_legend_swatch(zone_legend_black_swatch, "Player 2 territory"))
	box.add_child(row)
	return box

func _wrap_zone_legend_swatch(swatch: ColorRect, text: String) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.add_child(swatch)
	var label = Label.new()
	label.text = text
	UITheme.apply_subtle_text(label, 12)
	row.add_child(label)
	return row

func _create_zone_legend_swatch(color_value: Color) -> ColorRect:
	var swatch = ColorRect.new()
	swatch.custom_minimum_size = Vector2(18.0, 18.0)
	swatch.color = color_value
	return swatch

func _update_zone_legend_colors() -> void:
	if zone_legend_white_swatch != null:
		zone_legend_white_swatch.color = _get_player_color("white")
	if zone_legend_black_swatch != null:
		zone_legend_black_swatch.color = _get_player_color("black")

func _build_pieces_section_page() -> VBoxContainer:
	var page = _make_section_page("pieces", "Available Pieces")
	page.add_child(_layout_existing_control(piece_bank_list, true, Vector2(0.0, 244.0)))
	page.add_child(_make_labeled_row(_find_option_node("PieceColorLabel"), piece_color_option))
	return page

func _build_presets_section_page() -> VBoxContainer:
	var page = _make_section_page("presets", "Presets")
	page.add_child(_layout_existing_control(preset_list, true, Vector2(0.0, 176.0)))
	page.add_child(_layout_existing_control(preset_name_input, true))
	page.add_child(_make_button_row(_find_option_node("SavePresetButton"), _find_option_node("DeletePresetButton")))
	return page

func _build_victory_section_page() -> VBoxContainer:
	var page = _make_section_page("victory", "Victory Condition")
	page.add_child(_layout_existing_control(victory_condition_option, true))
	page.add_child(_layout_existing_control(victory_condition_description, true))
	return page

func _build_special_rules_section_page() -> VBoxContainer:
	var page = _make_section_page("special_rules", "Special Rules")
	page.add_child(_layout_existing_control(special_rule_button_box, true))
	var detail_title = Label.new()
	UITheme.apply_section_text(detail_title, 16)
	page.add_child(detail_title)
	special_rule_detail_title_label = detail_title
	var helper = Label.new()
	helper.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UITheme.apply_muted_text(helper, 13)
	page.add_child(helper)
	special_rule_helper_label = helper
	var detail_panel = PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var detail_style = UITheme.panel_style(Color(0.11, 0.12, 0.15, 0.96), UITheme.PANEL_BORDER, 10, 1)
	detail_panel.add_theme_stylebox_override("panel", detail_style)
	page.add_child(detail_panel)
	var detail_margin = MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 12)
	detail_margin.add_theme_constant_override("margin_top", 12)
	detail_margin.add_theme_constant_override("margin_right", 12)
	detail_margin.add_theme_constant_override("margin_bottom", 12)
	detail_panel.add_child(detail_margin)
	special_rule_content_root = VBoxContainer.new()
	special_rule_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	special_rule_content_root.add_theme_constant_override("separation", 8)
	detail_margin.add_child(special_rule_content_root)
	_build_special_rule_pages()
	return page

func _build_colors_section_page() -> VBoxContainer:
	var page = _make_section_page("colors", "Colors")
	var player_title = Label.new()
	player_title.text = _icon_text("◍", "Player Colors")
	player_title.add_theme_font_size_override("font_size", 15)
	page.add_child(player_title)
	page.add_child(_make_button_row(_make_labeled_control(player1_color_button, "Player 1"), _make_labeled_control(player2_color_button, "Player 2")))
	var tile_title = Label.new()
	tile_title.text = _icon_text("▣", "Board Tile Colors")
	tile_title.add_theme_font_size_override("font_size", 15)
	page.add_child(tile_title)
	page.add_child(_make_button_row(_make_labeled_control(light_tile_color_button, "Light Tiles"), _make_labeled_control(dark_tile_color_button, "Dark Tiles")))
	return page

func _build_special_rule_pages() -> void:
	special_rule_pages.clear()
	var undo_page = _make_rule_page()
	undo_page.add_child(_layout_existing_control(allow_undo_check_box, true))
	_register_special_rule_page("allow_undo", undo_page)

	var castling_page = _make_rule_page()
	castling_page.add_child(_layout_existing_control(castling_check_box, true))
	castling_page.add_child(_layout_existing_control(castling_support_hint, true))
	_register_special_rule_page("castling", castling_page)

	var en_passant_page = _make_rule_page()
	en_passant_page.add_child(_layout_existing_control(en_passant_check_box, true))
	_register_special_rule_page("en_passant", en_passant_page)

	var promotion_page = _make_rule_page()
	promotion_page.add_child(_layout_existing_control(promotion_check_box, true))
	promotion_page.add_child(_make_inline_heading("Promotion Zones"))
	promotion_page.add_child(_make_labeled_row(player1_promotion_zone_label, player1_promotion_zone_spin_box))
	promotion_page.add_child(_make_labeled_row(player2_promotion_zone_label, player2_promotion_zone_spin_box))
	promotion_page.add_child(_make_inline_heading("Promotion Pieces"))
	promotion_page.add_child(_layout_existing_control(promotion_pieces_list.get_parent(), true, Vector2(0.0, 220.0)))
	_register_special_rule_page("promotion", promotion_page)

	var dropping_page = _make_rule_page()
	dropping_page.add_child(_layout_existing_control(piece_dropping_check_box, true))
	dropping_page.add_child(_layout_existing_control(capture_to_drop_pool_check_box, true))
	_register_special_rule_page("piece_dropping", dropping_page)

	var stacking_page = _make_rule_page()
	stacking_page.add_child(_layout_existing_control(piece_stacking_check_box, true))
	_register_special_rule_page("piece_stacking", stacking_page)

	var territory_page = _make_rule_page()
	territory_page.add_child(_layout_existing_control(enable_territory_check_box, true))
	territory_page.add_child(_make_labeled_row(territory_rows_label, territory_rows_spin_box))
	_register_special_rule_page("enable_territory", territory_page)

	var muster_page = _make_rule_page()
	muster_page.add_child(_layout_existing_control(enable_muster_check_box, true))
	muster_page.add_child(_make_rule_note("Territory row depth is configured under the Territory rule."))
	_register_special_rule_page("enable_muster", muster_page)

	var army_page = _make_rule_page()
	army_page.add_child(_layout_existing_control(limit_army_strength_check_box, true))
	army_page.add_child(_layout_existing_control(unbalanced_armies_check_box, true))
	army_page.add_child(_make_labeled_row(army_strength_cap_label, army_strength_cap_spin_box))
	army_page.add_child(_make_labeled_row(white_army_strength_cap_label, white_army_strength_cap_spin_box))
	army_page.add_child(_make_labeled_row(black_army_strength_cap_label, black_army_strength_cap_spin_box))
	army_page.add_child(_layout_existing_control(army_strength_warning_label, true))
	_register_special_rule_page("limit_army_strength", army_page)

	var spell_page = _make_rule_page()
	spell_page.add_child(_layout_existing_control(enable_spell_cards_check_box, true))
	spell_page.add_child(_make_labeled_row(spell_hand_size_label, spell_hand_size_spin_box))
	spell_page.add_child(_layout_existing_control(spell_unbalanced_hand_sizes_check_box, true))
	spell_page.add_child(_make_labeled_row(spell_hand_size_white_label, spell_hand_size_white_spin_box))
	spell_page.add_child(_make_labeled_row(spell_hand_size_black_label, spell_hand_size_black_spin_box))
	spell_page.add_child(_layout_existing_control(random_spell_cards_check_box, true))
	spell_page.add_child(_layout_existing_control(spell_allow_duplicates_check_box, true))
	spell_page.add_child(_layout_existing_control(spell_draw_replacement_after_cast_check_box, true))
	spell_page.add_child(_make_labeled_row(spell_assign_card_label, spell_assign_card_option))
	spell_page.add_child(_layout_existing_control(spell_cards_hint_label, true))
	spell_page.add_child(_make_inline_heading("Available Cards"))
	spell_page.add_child(_layout_existing_control(available_spell_cards_scroll, true, Vector2(0.0, 214.0)))
	_register_special_rule_page("enable_spell_cards", spell_page)

func _make_rule_page() -> VBoxContainer:
	var page = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 8)
	if special_rule_content_root != null:
		special_rule_content_root.add_child(page)
	return page

func _register_special_rule_page(rule_id: String, page: VBoxContainer) -> void:
	special_rule_pages[rule_id] = page

func _make_inline_heading(text: String) -> Label:
	var label = Label.new()
	label.text = _icon_text("•", text)
	UITheme.apply_body_text(label, 14)
	return label

func _make_rule_note(text: String) -> Label:
	var label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.text = text
	UITheme.apply_subtle_text(label, 12)
	return label

func _icon_text(icon: String, text: String) -> String:
	if icon == "":
		return text
	return "%s  %s" % [icon, text]

func _layout_existing_control(node: Node, expand_width: bool, min_size: Vector2 = Vector2.ZERO) -> Control:
	var control = node as Control
	if control == null:
		return Control.new()
	if control.get_parent() != null:
		control.get_parent().remove_child(control)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL if expand_width else Control.SIZE_SHRINK_BEGIN
	if min_size != Vector2.ZERO:
		control.custom_minimum_size = min_size
	control.layout_mode = 2
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0
	return control

func _make_labeled_row(label_node: Node, field_node: Node) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	var label = label_node as Control
	var field = field_node as Control
	if label != null:
		if label.get_parent() != null:
			label.get_parent().remove_child(label)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.custom_minimum_size = Vector2(132.0, 0.0)
		label.layout_mode = 2
		label.offset_left = 0.0
		label.offset_top = 0.0
		label.offset_right = 0.0
		label.offset_bottom = 0.0
		row.add_child(label)
	if field != null:
		if field.get_parent() != null:
			field.get_parent().remove_child(field)
		field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		field.layout_mode = 2
		field.offset_left = 0.0
		field.offset_top = 0.0
		field.offset_right = 0.0
		field.offset_bottom = 0.0
		row.add_child(field)
	return row

func _make_labeled_spin_row(left_label_name: StringName, left_field_name: StringName, right_label_name: StringName, right_field_name: StringName) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	row.add_child(_make_labeled_row(_find_option_node(String(left_label_name)), _find_option_node(String(left_field_name))))
	row.add_child(_make_labeled_row(_find_option_node(String(right_label_name)), _find_option_node(String(right_field_name))))
	return row

func _make_button_row(left_node: Node, right_node: Node) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)
	for node in [left_node, right_node]:
		var control = node as Control
		if control == null:
			continue
		if control.get_parent() != null:
			control.get_parent().remove_child(control)
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.layout_mode = 2
		control.offset_left = 0.0
		control.offset_top = 0.0
		control.offset_right = 0.0
		control.offset_bottom = 0.0
		row.add_child(control)
	return row

func _make_labeled_control(control: Control, label_text: String) -> VBoxContainer:
	var box = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label = Label.new()
	label.text = label_text
	box.add_child(label)
	if control.get_parent() != null:
		control.get_parent().remove_child(control)
	control.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	control.layout_mode = 2
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0
	box.add_child(control)
	return box

func _on_section_button_pressed(section_id: String) -> void:
	_set_active_section(section_id)

func _set_active_section(section_id: String) -> void:
	if not SECTION_ORDER.has(section_id):
		return
	var previous_section_id = active_section_id
	active_section_id = section_id
	preview_warning_label.visible = false
	_refresh_section_button_states()
	_refresh_section_visibility()
	_animate_section_transition(previous_section_id, active_section_id)

func _refresh_section_button_states() -> void:
	for section_id in section_buttons.keys():
		var button: Button = section_buttons[section_id]
		button.button_pressed = str(section_id) == active_section_id
		_style_section_button(button, str(section_id) == active_section_id)

func _style_section_button(button: Button, is_active: bool) -> void:
	button.add_theme_color_override("font_color", NAV_BUTTON_ACTIVE_TEXT_COLOR if is_active else NAV_BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_focus_color", NAV_BUTTON_ACTIVE_TEXT_COLOR if is_active else NAV_BUTTON_TEXT_COLOR)
	button.add_theme_color_override("font_hover_color", NAV_BUTTON_ACTIVE_TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", NAV_BUTTON_ACTIVE_TEXT_COLOR)
	button.add_theme_stylebox_override("normal", _make_tab_stylebox(NAV_BUTTON_ACTIVE_COLOR if is_active else NAV_BUTTON_INACTIVE_COLOR, RULE_BUTTON_SELECTED_OUTLINE if is_active else Color(0.28, 0.31, 0.38, 1.0), 12.0))
	button.add_theme_stylebox_override("hover", _make_tab_stylebox(Color(0.21, 0.25, 0.31, 1.0), RULE_BUTTON_SELECTED_OUTLINE, 12.0))
	button.add_theme_stylebox_override("pressed", _make_tab_stylebox(NAV_BUTTON_ACTIVE_COLOR, RULE_BUTTON_SELECTED_OUTLINE, 12.0))
	button.add_theme_stylebox_override("focus", _make_tab_stylebox(NAV_BUTTON_ACTIVE_COLOR, RULE_BUTTON_SELECTED_OUTLINE, 12.0))

func _make_tab_stylebox(fill: Color, border: Color, radius: float) -> StyleBoxFlat:
	return UITheme.button_style(fill, border, int(radius), 2, 10.0, 10.0, 6.0, 6.0)

func _set_nodes_visible_by_name(node_names: Array, is_visible: bool) -> void:
	for node_name in node_names:
		var node = _find_option_node(str(node_name))
		if node is CanvasItem:
			node.visible = is_visible

func _find_option_node(node_name: String) -> Node:
	return options_content.find_child(node_name, true, false)

func _refresh_section_visibility() -> void:
	if navigation_helper_label != null:
		navigation_helper_label.text = str(SECTION_HELPERS.get(active_section_id, ""))
		call_deferred("_update_section_navigation_layout")
	for section_id in section_pages.keys():
		var page = section_pages[section_id] as VBoxContainer
		if page != null:
			page.visible = str(section_id) == active_section_id

	if active_section_id == "special_rules":
		_refresh_special_rule_visibility()

	if options_scroll != null:
		options_scroll.scroll_vertical = 0

func _on_menu_resized() -> void:
	call_deferred("_update_section_navigation_layout")

func _update_section_navigation_layout() -> void:
	if section_button_box == null or navigation_helper_label == null or section_content_panel == null:
		return
	var button_height = _measure_flow_container_height(section_button_box)
	var button_top = section_button_box.offset_top
	section_button_box.offset_bottom = button_top + button_height + SECTION_BUTTON_VERTICAL_PADDING * 2.0
	var panel_top = section_button_box.offset_bottom + SECTION_CONTENT_TOP_GAP
	section_content_panel.offset_top = panel_top

	var visible_content_height = 120.0
	for child in section_content_root.get_children():
		if not (child is Control):
			continue
		var control := child as Control
		if not control.visible:
			continue
		visible_content_height = max(visible_content_height, control.get_combined_minimum_size().y + 32.0)

	section_content_panel.offset_bottom = panel_top + visible_content_height
	options_content.custom_minimum_size.y = max(280.0, section_content_panel.offset_bottom + SECTION_CONTENT_BOTTOM_PADDING)
	call_deferred("_update_special_rule_button_layout")

func _update_special_rule_button_layout() -> void:
	if special_rule_button_box == null:
		return
	var button_height = _measure_flow_container_height(special_rule_button_box)
	special_rule_button_box.custom_minimum_size.y = button_height + SPECIAL_RULE_BUTTON_VERTICAL_PADDING * 2.0

func _measure_flow_container_height(container: FlowContainer) -> float:
	var available_width = _flow_container_available_width(container)
	var h_separation = float(container.get_theme_constant("h_separation", "FlowContainer"))
	var v_separation = float(container.get_theme_constant("v_separation", "FlowContainer"))
	var current_row_width = 0.0
	var current_row_height = 0.0
	var total_height = 0.0
	var row_count = 0
	for child in container.get_children():
		if not (child is Control):
			continue
		var control := child as Control
		if not control.visible:
			continue
		var min_size = control.get_combined_minimum_size()
		var child_width = min_size.x
		var child_height = min_size.y
		if row_count == 0:
			row_count = 1
		if current_row_width > 0.0 and current_row_width + h_separation + child_width > available_width:
			total_height += current_row_height
			total_height += v_separation
			current_row_width = child_width
			current_row_height = child_height
			row_count += 1
			continue
		if current_row_width > 0.0:
			current_row_width += h_separation
		current_row_width += child_width
		current_row_height = max(current_row_height, child_height)
	if row_count == 0:
		return 0.0
	total_height += current_row_height
	return total_height

func _flow_container_available_width(container: FlowContainer) -> float:
	var available_width = container.size.x
	if available_width <= 1.0 and container.get_parent() is Control:
		available_width = (container.get_parent() as Control).size.x
	if available_width <= 1.0:
		available_width = container.offset_right - container.offset_left
	return max(available_width, 1.0)

func _animate_section_transition(previous_section_id: String, next_section_id: String) -> void:
	if navigation_helper_label != null:
		navigation_helper_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var helper_tween = create_tween()
		helper_tween.tween_property(navigation_helper_label, "modulate:a", 1.0, PAGE_ANIMATION_DURATION)
	if previous_section_id == next_section_id:
		var current_page = section_pages.get(next_section_id, null) as Control
		if current_page != null:
			_animate_page_in(current_page)
		return
	var next_page = section_pages.get(next_section_id, null) as Control
	if next_page != null:
		_animate_page_in(next_page)

func _section_scroll_target(section_id: String) -> int:
	return 0

func _on_special_rule_button_pressed(rule_id: String) -> void:
	var previous_rule_id = active_special_rule_id
	active_special_rule_id = rule_id
	_refresh_special_rule_button_states()
	_refresh_special_rule_visibility()
	_animate_rule_transition(previous_rule_id, active_special_rule_id)

func _refresh_special_rule_button_states() -> void:
	for rule_id in special_rule_buttons.keys():
		var button: Button = special_rule_buttons[rule_id]
		var enabled = false
		var check_box = _special_rule_checkbox(str(rule_id))
		var disabled = false
		if check_box != null:
			enabled = check_box.button_pressed
			disabled = check_box.disabled
		var title = _icon_text(str(SPECIAL_RULE_ICONS.get(rule_id, "")), str(SPECIAL_RULE_LABELS.get(rule_id, str(rule_id).capitalize())))
		button.text = "%s | %s" % [title, "N/A" if disabled else ("ON" if enabled else "OFF")]
		button.button_pressed = str(rule_id) == active_special_rule_id
		_style_special_rule_button(button, enabled, str(rule_id) == active_special_rule_id, disabled)
	call_deferred("_update_special_rule_button_layout")

func _style_special_rule_button(button: Button, is_enabled: bool, is_active: bool, is_disabled: bool) -> void:
	var fill = RULE_BUTTON_DISABLED_COLOR if is_disabled else (RULE_BUTTON_ON_COLOR if is_enabled else RULE_BUTTON_OFF_COLOR)
	var text_color = Color(0.82, 0.82, 0.82, 1.0) if is_disabled else NAV_BUTTON_ACTIVE_TEXT_COLOR
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_color_override("font_focus_color", text_color)
	button.add_theme_color_override("font_hover_color", NAV_BUTTON_ACTIVE_TEXT_COLOR)
	button.add_theme_color_override("font_pressed_color", NAV_BUTTON_ACTIVE_TEXT_COLOR)
	button.add_theme_stylebox_override("normal", _make_tab_stylebox(fill, RULE_BUTTON_SELECTED_OUTLINE if is_active else Color(0.29, 0.30, 0.34, 1.0), 10.0))
	button.add_theme_stylebox_override("hover", _make_tab_stylebox(fill.lightened(0.08), RULE_BUTTON_SELECTED_OUTLINE, 10.0))
	button.add_theme_stylebox_override("pressed", _make_tab_stylebox(fill, RULE_BUTTON_SELECTED_OUTLINE, 10.0))
	button.add_theme_stylebox_override("focus", _make_tab_stylebox(fill, RULE_BUTTON_SELECTED_OUTLINE, 10.0))

func _special_rule_checkbox(rule_id: String) -> CheckBox:
	match rule_id:
		"allow_undo":
			return allow_undo_check_box
		"castling":
			return castling_check_box
		"en_passant":
			return en_passant_check_box
		"promotion":
			return promotion_check_box
		"piece_dropping":
			return piece_dropping_check_box
		"piece_stacking":
			return piece_stacking_check_box
		"enable_territory":
			return enable_territory_check_box
		"enable_muster":
			return enable_muster_check_box
		"limit_army_strength":
			return limit_army_strength_check_box
		"enable_spell_cards":
			return enable_spell_cards_check_box
		_:
			return null

func _refresh_special_rule_visibility() -> void:
	if special_rule_detail_title_label != null:
		special_rule_detail_title_label.text = _icon_text(str(SPECIAL_RULE_ICONS.get(active_special_rule_id, "")), str(SPECIAL_RULE_LABELS.get(active_special_rule_id, "Rule Details")))
	if special_rule_helper_label != null:
		special_rule_helper_label.text = str(SPECIAL_RULE_HELPERS.get(active_special_rule_id, ""))
	for rule_id in special_rule_pages.keys():
		var page = special_rule_pages[rule_id] as VBoxContainer
		if page != null:
			page.visible = str(rule_id) == active_special_rule_id

	if active_special_rule_id == "castling":
		_update_castling_rule_availability()
	if active_special_rule_id == "promotion":
		_update_promotion_piece_visibility()
	if active_special_rule_id == "piece_dropping":
		_update_piece_dropping_visibility()
	if active_special_rule_id == "enable_spell_cards":
		_update_spell_card_visibility()
	if active_special_rule_id == "limit_army_strength":
		_update_army_strength_limit_visibility()
	if active_special_rule_id == "enable_territory" or active_special_rule_id == "enable_muster":
		_update_territory_controls_visibility()

	_apply_special_rule_suboption_enabled_state(active_special_rule_id)

func _animate_rule_transition(previous_rule_id: String, next_rule_id: String) -> void:
	if special_rule_helper_label != null:
		special_rule_helper_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var helper_tween = create_tween()
		helper_tween.tween_property(special_rule_helper_label, "modulate:a", 1.0, PAGE_ANIMATION_DURATION)
	if special_rule_detail_title_label != null:
		special_rule_detail_title_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var title_tween = create_tween()
		title_tween.tween_property(special_rule_detail_title_label, "modulate:a", 1.0, PAGE_ANIMATION_DURATION)
	if previous_rule_id == next_rule_id:
		var current_page = special_rule_pages.get(next_rule_id, null) as Control
		if current_page != null:
			_animate_page_in(current_page)
		return
	var next_page = special_rule_pages.get(next_rule_id, null) as Control
	if next_page != null:
		_animate_page_in(next_page)

func _animate_page_in(control: Control) -> void:
	control.scale = Vector2(0.985, 0.985)
	control.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "modulate:a", 1.0, PAGE_ANIMATION_DURATION)
	tween.tween_property(control, "scale", Vector2.ONE, PAGE_ANIMATION_DURATION)

func _set_control_interactive_state(node: Node, is_enabled: bool) -> void:
	if node is Button:
		(node as Button).disabled = not is_enabled
		(node as Button).modulate = Color(1.0, 1.0, 1.0, 1.0) if is_enabled else Color(0.72, 0.72, 0.72, 1.0)
		return
	if node is OptionButton:
		(node as OptionButton).disabled = not is_enabled
		(node as OptionButton).modulate = Color(1.0, 1.0, 1.0, 1.0) if is_enabled else Color(0.72, 0.72, 0.72, 1.0)
		return
	if node is SpinBox:
		(node as SpinBox).editable = is_enabled
		(node as SpinBox).modulate = Color(1.0, 1.0, 1.0, 1.0) if is_enabled else Color(0.7, 0.7, 0.7, 1.0)
		return
	if node is ScrollContainer:
		(node as ScrollContainer).mouse_filter = Control.MOUSE_FILTER_PASS if is_enabled else Control.MOUSE_FILTER_IGNORE
		(node as ScrollContainer).modulate = Color(1.0, 1.0, 1.0, 1.0) if is_enabled else Color(0.7, 0.7, 0.7, 1.0)

func _apply_special_rule_suboption_enabled_state(rule_id: String) -> void:
	var check_box = _special_rule_checkbox(rule_id)
	var is_enabled = check_box != null and check_box.button_pressed
	var node_names: Array = SPECIAL_RULE_SUBOPTION_NODE_NAMES.get(rule_id, [])
	for node_name in node_names:
		var node = _find_option_node(str(node_name))
		if node != null:
			_set_control_interactive_state(node, is_enabled)

func _refresh_special_rules_ui_state() -> void:
	_refresh_special_rule_button_states()
	if active_section_id == "special_rules":
		_refresh_special_rule_visibility()

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
	_refresh_piece_color_picker_items()
	piece_color_option.select(1 if selected_piece_color == "black" else 0)
	piece_color_option.item_selected.connect(_on_piece_color_selected)

func _refresh_piece_color_picker_items() -> void:
	if piece_color_option == null:
		return
	var selected_index = piece_color_option.selected
	piece_color_option.clear()
	piece_color_option.add_icon_item(_create_color_swatch_texture(_get_player_color("white")), "Player 1")
	piece_color_option.add_icon_item(_create_color_swatch_texture(_get_player_color("black")), "Player 2")
	piece_color_option.set_item_tooltip(0, "Place as Player 1")
	piece_color_option.set_item_tooltip(1, "Place as Player 2")
	if selected_index >= 0 and selected_index < piece_color_option.item_count:
		piece_color_option.select(selected_index)
	else:
		piece_color_option.select(1 if selected_piece_color == "black" else 0)

func _create_color_swatch_texture(color_value: Color) -> Texture2D:
	var image = Image.create(PIECE_COLOR_SWATCH_SIZE, PIECE_COLOR_SWATCH_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(color_value.r, color_value.g, color_value.b, 1.0))
	var border = _best_contrast_text_color(color_value)
	for x in range(PIECE_COLOR_SWATCH_SIZE):
		image.set_pixel(x, 0, border)
		image.set_pixel(x, PIECE_COLOR_SWATCH_SIZE - 1, border)
	for y in range(PIECE_COLOR_SWATCH_SIZE):
		image.set_pixel(0, y, border)
		image.set_pixel(PIECE_COLOR_SWATCH_SIZE - 1, y, border)
	return ImageTexture.create_from_image(image)

func _setup_player_color_pickers() -> void:
	player1_color_button.pressed.connect(_on_color_picker_button_pressed.bind("player_white"))
	player2_color_button.pressed.connect(_on_color_picker_button_pressed.bind("player_black"))
	_apply_player_colors_from_serialized($"/root/GameManager".PlayerColors)

func _setup_tile_color_pickers() -> void:
	light_tile_color_button.pressed.connect(_on_color_picker_button_pressed.bind("tile_light"))
	dark_tile_color_button.pressed.connect(_on_color_picker_button_pressed.bind("tile_dark"))
	_apply_tile_colors_from_serialized($"/root/GameManager".TileColors)


func _ensure_shared_color_picker_dialog() -> void:
	if shared_color_picker_dialog != null:
		return
	shared_color_picker_dialog = AcceptDialog.new()
	shared_color_picker_dialog.title = "Choose Color"
	shared_color_picker_dialog.confirmed.connect(_on_shared_color_picker_confirmed)
	shared_color_picker_dialog.canceled.connect(_on_shared_color_picker_closed)
	shared_color_picker = ColorPicker.new()
	shared_color_picker.custom_minimum_size = Vector2(320.0, 360.0)
	shared_color_picker.color_modes_visible = false
	shared_color_picker.sliders_visible = true
	shared_color_picker.presets_visible = true
	shared_color_picker_dialog.add_child(shared_color_picker)
	add_child(shared_color_picker_dialog)

func _on_color_picker_button_pressed(target: String) -> void:
	pending_color_target = target
	if shared_color_picker_dialog == null:
		return
	if shared_color_picker != null:
		shared_color_picker.color = _current_color_for_target(target)
	shared_color_picker_dialog.popup_centered_ratio(0.55)

func _on_shared_color_picker_confirmed() -> void:
	if shared_color_picker == null:
		pending_color_target = ""
		return
	_apply_selected_color_target(pending_color_target, shared_color_picker.color)
	pending_color_target = ""

func _on_shared_color_picker_closed() -> void:
	pending_color_target = ""

func _current_color_for_target(target: String) -> Color:
	match target:
		"player_white":
			return _get_player_color("white")
		"player_black":
			return _get_player_color("black")
		"tile_light":
			return board_tile_colors.get("light", Color(1.0, 1.0, 1.0, 1.0))
		"tile_dark":
			return board_tile_colors.get("dark", Color(0.41, 0.41, 0.41, 1.0))
		_:
			return Color(1.0, 1.0, 1.0, 1.0)

func _apply_selected_color_target(target: String, selected_color: Color) -> void:
	var next_color = Color(selected_color.r, selected_color.g, selected_color.b, 1.0)
	match target:
		"player_white":
			player_side_colors["white"] = next_color
			_update_color_button_visual(player1_color_button, next_color)
		"player_black":
			player_side_colors["black"] = next_color
			_update_color_button_visual(player2_color_button, next_color)
		"tile_light":
			board_tile_colors["light"] = next_color
			_update_color_button_visual(light_tile_color_button, next_color)
		"tile_dark":
			board_tile_colors["dark"] = next_color
			_update_color_button_visual(dark_tile_color_button, next_color)
		_:
			return
	_refresh_piece_color_picker_items()
	_update_zone_legend_colors()
	_refresh_preview()

func _update_color_button_visual(button: Button, color_value: Color) -> void:
	if button == null:
		return
	button.text = _format_color_button_text(color_value)
	button.add_theme_color_override("font_color", _best_contrast_text_color(color_value))
	button.add_theme_stylebox_override("normal", _make_color_button_style(color_value, color_value.darkened(0.35)))
	button.add_theme_stylebox_override("hover", _make_color_button_style(color_value.lightened(0.08), color_value.darkened(0.35)))
	button.add_theme_stylebox_override("pressed", _make_color_button_style(color_value, color_value.darkened(0.45)))
	button.add_theme_stylebox_override("focus", _make_color_button_style(color_value, color_value.darkened(0.45)))

func _make_color_button_style(fill: Color, border: Color) -> StyleBoxFlat:
	return UITheme.button_style(fill, border, 8, 2, 8.0, 8.0, 6.0, 6.0)

func _format_color_button_text(color_value: Color) -> String:
	return "#%02X%02X%02X" % [int(round(color_value.r * 255.0)), int(round(color_value.g * 255.0)), int(round(color_value.b * 255.0))]

func _setup_victory_condition_picker() -> void:
	victory_condition_option.clear()
	victory_condition_option.add_item("Checkmate")
	victory_condition_option.add_item("Total War")
	victory_condition_option.item_selected.connect(_on_victory_condition_selected)
	_apply_victory_condition($"/root/GameManager".VictoryCondition)
	_update_victory_condition_availability()

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
	_update_victory_condition_availability()

func _update_victory_condition_description() -> void:
	if victory_condition_option.selected == 1:
		victory_condition_description.text = "TOTAL WAR\nWin when the opponent has no pieces left on the board.\nIf neither side has any legal capture remaining, the game is a stalemate."
	else:
		victory_condition_description.text = "CHECKMATE\nWin by checkmating the king."

func _setup_special_rules() -> void:
	_ensure_piece_stacking_check_box()
	_ensure_gungi_rule_controls()
	castling_check_box.toggled.connect(_on_castling_rule_toggled)
	en_passant_check_box.toggled.connect(_on_en_passant_rule_toggled)
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
	_update_preview_rule_dependencies()

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
	_refresh_special_rules_ui_state()
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
	player1_promotion_zone_label.visible = show_promotion_piece_pool
	player1_promotion_zone_spin_box.visible = show_promotion_piece_pool
	player2_promotion_zone_label.visible = show_promotion_piece_pool
	player2_promotion_zone_spin_box.visible = show_promotion_piece_pool
	promotion_pieces_list.get_parent().visible = show_promotion_piece_pool
	promotion_zones_title_background.visible = false
	promotion_zones_title.visible = false
	promotion_pieces_title_background.visible = false
	promotion_pieces_title.visible = false

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
	available_spell_cards_scroll.visible = enabled
	available_spell_cards_title_background.visible = false
	available_spell_cards_title.visible = false

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
		castling_check_box.button_pressed = castling_user_preference
	else:
		castling_support_hint.visible = true
		castling_check_box.button_pressed = false
	castling_support_hint_background.visible = false
	is_updating_castling_availability = false

func _update_preview_rule_dependencies() -> void:
	_update_castling_rule_availability()
	_update_en_passant_rule_availability()
	_update_victory_condition_availability()

func _update_en_passant_rule_availability() -> void:
	var supports_en_passant = _preview_supports_en_passant()
	is_updating_en_passant_availability = true
	en_passant_check_box.disabled = not supports_en_passant
	if supports_en_passant:
		en_passant_check_box.button_pressed = en_passant_user_preference
	else:
		en_passant_check_box.button_pressed = false
	is_updating_en_passant_availability = false
	_refresh_special_rules_ui_state()

func _update_victory_condition_availability() -> void:
	var has_king = _preview_has_any_piece_id("king")
	var popup = victory_condition_option.get_popup()
	if popup != null:
		popup.set_item_disabled(0, not has_king)
	if not has_king and victory_condition_option.selected == 0:
		victory_condition_option.select(1)
	_update_victory_condition_description()

func _preview_supports_castling() -> bool:
	return _preview_has_piece("white", "king") and _preview_has_piece("black", "king") and _preview_has_piece("white", "rook") and _preview_has_piece("black", "rook")

func _preview_supports_en_passant() -> bool:
	return _preview_has_any_piece_id("pawn")

func _preview_has_piece(piece_color: String, piece_id: String) -> bool:
	for square in preview_pieces.keys():
		var piece_data: Dictionary = preview_pieces[square]
		if piece_data.get("color", "") == piece_color and piece_data.get("piece_id", "") == piece_id:
			return true
	return false

func _preview_has_any_piece_id(piece_id: String) -> bool:
	for square in preview_pieces.keys():
		var piece_data: Dictionary = preview_pieces[square]
		if piece_data.get("piece_id", "") == piece_id:
			return true
	return false

func _on_castling_rule_toggled(is_enabled: bool) -> void:
	if is_updating_castling_availability:
		return
	if castling_check_box.disabled:
		return
	castling_user_preference = is_enabled
	_refresh_special_rules_ui_state()

func _on_en_passant_rule_toggled(is_enabled: bool) -> void:
	if is_updating_en_passant_availability:
		return
	if en_passant_check_box.disabled:
		return
	en_passant_user_preference = is_enabled
	_refresh_special_rules_ui_state()

func _on_promotion_rule_toggled(_is_enabled: bool) -> void:
	_update_promotion_piece_visibility()
	_refresh_special_rules_ui_state()
	_refresh_preview()

func _on_promotion_zone_value_changed(_value: float) -> void:
	_update_promotion_zone_limits()
	_refresh_preview()

func _on_piece_dropping_toggled(_is_enabled: bool) -> void:
	_update_piece_dropping_visibility()
	_refresh_special_rules_ui_state()
	_refresh_preview()

func _on_piece_stacking_toggled(_is_enabled: bool) -> void:
	_refresh_special_rules_ui_state()
	_refresh_preview()

func _on_territory_controls_toggled(_is_enabled: bool) -> void:
	if enable_muster_check_box != null and enable_muster_check_box.button_pressed and enable_territory_check_box != null and not enable_territory_check_box.button_pressed:
		enable_territory_check_box.button_pressed = true
	if enable_muster_check_box != null and enable_muster_check_box.button_pressed and not piece_dropping_check_box.button_pressed:
		piece_dropping_check_box.button_pressed = true
	_update_territory_controls_visibility()
	_refresh_special_rules_ui_state()
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
	_refresh_special_rules_ui_state()
	_refresh_preview()

func _on_unbalanced_armies_toggled(_is_enabled: bool) -> void:
	_update_army_strength_limit_visibility()
	if _is_army_strength_rule_enabled():
		_ensure_army_strength_cap_meets_current_position()
	_clear_army_strength_warning(true)
	_refresh_special_rules_ui_state()
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
	_refresh_special_rules_ui_state()
	_update_victory_condition_availability()

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
	var top_reserve = 0.0
	var bottom_reserve = 0.0
	if _shows_preview_spell_hands():
		var spell_hand_height = _preview_spell_hand_panel_height_estimate()
		top_reserve += spell_hand_height + 16.0
		bottom_reserve += spell_hand_height + 16.0
	if _preview_has_active_zone_rings():
		top_reserve += _preview_zone_legend_panel_height_estimate() + 10.0
	var usable_width = max(board_preview.size.x - side_panel_width_estimate * 2.0, 80.0)
	var usable_height = max(board_preview.size.y - top_reserve - bottom_reserve, 80.0)

	preview_tile_size = min(
		floor(usable_width / max(width, 1)),
		floor(usable_height / max(height, 1))
	)
	if preview_tile_size < 1:
		preview_tile_size = 1

	var board_pixel_size = Vector2(width * preview_tile_size, height * preview_tile_size)
	preview_board_origin = Vector2(
		(board_preview.size.x - board_pixel_size.x) / 2.0,
		top_reserve + (max(board_preview.size.y - top_reserve - bottom_reserve, board_pixel_size.y) - board_pixel_size.y) / 2.0
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

	_draw_preview_zone_rings(width, height)
	_draw_preview_selection()
	_draw_preview_pieces()
	_draw_preview_ghost()
	_draw_preview_drop_pools(board_pixel_size)
	_clamp_preview_spell_hands_to_rules()
	_draw_preview_spell_hands(board_pixel_size)
	_draw_preview_zone_legend(board_pixel_size)
	_draw_piece_bank_drag_preview()
	_update_preview_rule_dependencies()
	_sync_online_setup_if_needed()

func _preview_side_panel_width() -> float:
	return clampf(board_preview.size.x * 0.18, 92.0, 150.0)

func _shows_preview_spell_hands() -> bool:
	return _is_spell_cards_enabled() and not _is_random_spell_cards_enabled()

func _preview_spell_hand_panel_height_estimate() -> float:
	return clampf(board_preview.size.y * 0.16, 80.0, 132.0)

func _preview_zone_legend_panel_height_estimate() -> float:
	return clampf(board_preview.size.y * 0.18, 86.0, 118.0)

func _preview_has_active_zone_rings() -> bool:
	return promotion_check_box.button_pressed or (enable_territory_check_box != null and enable_territory_check_box.button_pressed) or (enable_muster_check_box != null and enable_muster_check_box.button_pressed)

func _draw_preview_zone_legend(board_pixel_size: Vector2) -> void:
	if not _preview_has_active_zone_rings():
		return
	var panel_width = clampf(board_preview.size.x * 0.24, 138.0, 190.0)
	var panel_height = _preview_zone_legend_panel_height_estimate()
	var panel_x = preview_board_origin.x
	var panel_y = max(preview_board_origin.y - panel_height - 8.0, 8.0)

	var panel = ColorRect.new()
	panel.position = Vector2(panel_x, panel_y)
	panel.size = Vector2(panel_width, panel_height)
	panel.color = Color(0.07, 0.08, 0.10, 0.90)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(panel)

	var border = Line2D.new()
	border.position = panel.position
	border.width = 2.0
	border.default_color = Color(0.82, 0.85, 0.92, 0.95)
	border.closed = true
	border.points = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(panel_width, 0.0),
		Vector2(panel_width, panel_height),
		Vector2(0.0, panel_height)
	])
	board_preview.add_child(border)

	var title = Label.new()
	title.position = panel.position + Vector2(8.0, 5.0)
	title.size = Vector2(panel_width - 16.0, 18.0)
	title.text = "Zone Rings"
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color(0.96, 0.97, 1.0, 1.0))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(title)

	var row_y = panel.position.y + 24.0
	if promotion_check_box.button_pressed:
		row_y = _draw_preview_zone_legend_row(panel.position.x, row_y, PREVIEW_ZONE_PROMOTION_RING, "Promotion")
	if enable_muster_check_box != null and enable_muster_check_box.button_pressed:
		row_y = _draw_preview_zone_legend_row(panel.position.x, row_y, PREVIEW_ZONE_MUSTER_RING, "Muster")
	if enable_territory_check_box != null and enable_territory_check_box.button_pressed:
		_draw_preview_zone_legend_dual_row(panel.position.x, row_y, _get_player_color("white"), "P1", _get_player_color("black"), "P2")

func _draw_preview_zone_legend_row(panel_x: float, y: float, swatch_color: Color, label_text: String) -> float:
	var swatch = ColorRect.new()
	swatch.position = Vector2(panel_x + 8.0, y + 1.0)
	swatch.size = Vector2(12.0, 12.0)
	swatch.color = swatch_color
	swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(swatch)

	var label = Label.new()
	label.position = Vector2(panel_x + 26.0, y - 2.0)
	label.size = Vector2(96.0, 16.0)
	label.text = label_text
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.90, 0.92, 0.97, 1.0))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(label)
	return y + 16.0

func _draw_preview_zone_legend_dual_row(panel_x: float, y: float, left_color: Color, left_text: String, right_color: Color, right_text: String) -> void:
	var left_swatch = ColorRect.new()
	left_swatch.position = Vector2(panel_x + 8.0, y + 1.0)
	left_swatch.size = Vector2(12.0, 12.0)
	left_swatch.color = left_color
	left_swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(left_swatch)

	var left_label = Label.new()
	left_label.position = Vector2(panel_x + 26.0, y - 2.0)
	left_label.size = Vector2(28.0, 16.0)
	left_label.text = left_text
	left_label.add_theme_font_size_override("font_size", 11)
	left_label.add_theme_color_override("font_color", Color(0.90, 0.92, 0.97, 1.0))
	left_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(left_label)

	var right_swatch = ColorRect.new()
	right_swatch.position = Vector2(panel_x + 70.0, y + 1.0)
	right_swatch.size = Vector2(12.0, 12.0)
	right_swatch.color = right_color
	right_swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(right_swatch)

	var right_label = Label.new()
	right_label.position = Vector2(panel_x + 88.0, y - 2.0)
	right_label.size = Vector2(28.0, 16.0)
	right_label.text = right_text
	right_label.add_theme_font_size_override("font_size", 11)
	right_label.add_theme_color_override("font_color", Color(0.90, 0.92, 0.97, 1.0))
	right_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_preview.add_child(right_label)

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

func _draw_preview_zone_rings(width: int, height: int) -> void:
	if width <= 0 or height <= 0:
		return
	for y in range(height):
		for x in range(width):
			var square = Vector2i(x, y)
			var ring_colors = _preview_zone_ring_colors_for_square(square, height)
			if ring_colors.is_empty():
				continue
			_draw_preview_square_rings(square, ring_colors)

func _preview_zone_ring_colors_for_square(square: Vector2i, height: int) -> Array[Color]:
	var ring_colors: Array[Color] = []
	if promotion_check_box.button_pressed and _is_preview_square_in_any_promotion_zone(square, height):
		ring_colors.append(PREVIEW_ZONE_PROMOTION_RING)
	if enable_muster_check_box != null and enable_muster_check_box.button_pressed and _is_preview_square_in_any_territory(square, height):
		ring_colors.append(PREVIEW_ZONE_MUSTER_RING)
	if enable_territory_check_box != null and enable_territory_check_box.button_pressed:
		if _is_preview_square_in_owner_territory("white", square, height):
			ring_colors.append(_get_player_color("white"))
		if _is_preview_square_in_owner_territory("black", square, height):
			ring_colors.append(_get_player_color("black"))
	return ring_colors

func _is_preview_square_in_any_promotion_zone(square: Vector2i, height: int) -> bool:
	return _is_preview_square_in_promotion_zone("white", square, height) or _is_preview_square_in_promotion_zone("black", square, height)

func _is_preview_square_in_promotion_zone(owner: String, square: Vector2i, height: int) -> bool:
	var zones = _build_promotion_zones()
	var zone_rows = clamp(int(zones.get("white_rows" if owner == "white" else "black_rows", 1)), 1, max(height, 1))
	if owner == "white":
		return square.y < zone_rows
	return square.y >= height - zone_rows

func _is_preview_square_in_any_territory(square: Vector2i, height: int) -> bool:
	return _is_preview_square_in_owner_territory("white", square, height) or _is_preview_square_in_owner_territory("black", square, height)

func _is_preview_square_in_owner_territory(owner: String, square: Vector2i, height: int) -> bool:
	var rows = clamp(_territory_rows_value(), 1, max(height, 1))
	if owner == "white":
		return square.y >= height - rows
	if owner == "black":
		return square.y < rows
	return false

func _draw_preview_square_rings(square: Vector2i, ring_colors: Array[Color]) -> void:
	var tile_position = preview_board_origin + Vector2(square.x * preview_tile_size, square.y * preview_tile_size)
	var ring_metrics = _zone_ring_metrics(preview_tile_size)
	var ring_width = float(ring_metrics.get("width", 2.0))
	var base_inset = float(ring_metrics.get("base_inset", 4.0))
	var ring_step = float(ring_metrics.get("step", 3.0))
	for index in range(ring_colors.size()):
		var inset = base_inset + ring_step * index
		var ring = _create_rect_ring(tile_position, preview_tile_size, ring_colors[index], inset, ring_width)
		board_preview.add_child(ring)

func _zone_ring_metrics(tile_extent: float) -> Dictionary:
	if tile_extent <= 36.0:
		var compact_width = clampf(tile_extent * 0.045, 1.5, 2.5)
		return {
			"width": compact_width,
			"base_inset": clampf(tile_extent * 0.07, 2.0, 4.0),
			"step": compact_width + clampf(tile_extent * 0.02, 1.0, 2.0)
		}
	var ring_width = clampf(tile_extent * 0.06, 2.0, 4.0)
	return {
		"width": ring_width,
		"base_inset": clampf(tile_extent * 0.10, 4.0, 9.0),
		"step": ring_width + clampf(tile_extent * 0.04, 2.0, 4.0)
	}

func _create_rect_ring(position: Vector2, tile_extent: float, color: Color, inset: float, ring_width: float) -> Line2D:
	var usable_extent = max(tile_extent - inset * 2.0, ring_width * 2.0)
	var ring = Line2D.new()
	ring.position = position + Vector2(inset, inset)
	ring.width = ring_width
	ring.default_color = color
	ring.closed = true
	ring.joint_mode = Line2D.LINE_JOINT_ROUND
	ring.begin_cap_mode = Line2D.LINE_CAP_ROUND
	ring.end_cap_mode = Line2D.LINE_CAP_ROUND
	ring.points = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(usable_extent, 0.0),
		Vector2(usable_extent, usable_extent),
		Vector2(0.0, usable_extent)
	])
	return ring

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
		var stroke_width = clampf(icon_extent * 0.010, 1.1, 2.1)
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

		var is_closed = points.size() >= 3 and points[0].distance_to(points[points.size() - 1]) <= max(4.0, extent * 0.12)
		var outline_line = Line2D.new()
		outline_line.points = points
		outline_line.closed = is_closed
		outline_line.default_color = outline_color
		outline_line.width = max(1.2, stroke_width)
		outline_line.joint_mode = Line2D.LINE_JOINT_ROUND
		outline_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		outline_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		outline_line.modulate = tint
		parent.add_child(outline_line)

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
	_update_color_button_visual(player1_color_button, white_color)
	_update_color_button_visual(player2_color_button, black_color)
	_refresh_piece_color_picker_items()
	_update_zone_legend_colors()

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
	_update_color_button_visual(light_tile_color_button, light_color)
	_update_color_button_visual(dark_tile_color_button, dark_color)

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
			piece_bank_drag_preview_position = _preview_mouse_local_position()
			preview_drop_pool_hover_owner = _preview_drop_pool_side_at_position(piece_bank_drag_preview_position)
			_refresh_preview()
		else:
			_try_commit_piece_bank_drop()

func _input(event: InputEvent) -> void:
	if not dragging_piece_bank_piece:
		return
	if event is InputEventMouseMotion:
		piece_bank_drag_preview_position = _preview_mouse_local_position()
		preview_drop_pool_hover_owner = _preview_drop_pool_side_at_position(piece_bank_drag_preview_position)
		_refresh_preview()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_try_commit_piece_bank_drop()

func _try_commit_piece_bank_drop() -> void:
	if not dragging_piece_bank_piece:
		return
	var mouse_position = _preview_mouse_local_position()
	var target_pool = _preview_drop_pool_side_at_position(mouse_position)
	var dropped = false
	if target_pool != "":
		_add_piece_to_preview_drop_pool(target_pool, piece_bank_drag_piece_id, true)
		dropped = true
	else:
		var target_square = _preview_position_to_square(mouse_position)
		if target_square != INVALID_SQUARE and _can_place_preview_piece(target_square, piece_bank_drag_piece_id, piece_bank_drag_piece_color):
			preview_pieces[target_square] = {
				"piece_id": piece_bank_drag_piece_id,
				"color": piece_bank_drag_piece_color
			}
			selected_preview_square = target_square
			_clear_army_strength_warning()
			dropped = true
	_clear_piece_bank_drag_state()
	if not dropped:
		last_drag_square = INVALID_SQUARE
	_refresh_preview()

func _preview_mouse_local_position() -> Vector2:
	return board_preview.get_global_transform_with_canvas().affine_inverse() * get_viewport().get_mouse_position()

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
	if network_manager != null and network_manager.is_session_connected() and not network_manager.is_online_active() and not network_manager.is_hosting:
		preview_warning_label.text = "Host starts the online match after setup is ready."
		preview_warning_label.visible = true
		return
	if network_manager != null and network_manager.is_hosting and not network_manager.is_online_active():
		if not network_manager.start_hosted_match():
			preview_warning_label.text = "Online start failed. Make sure player 2 is connected."
			preview_warning_label.visible = true
			return
	
	#var LocalGame = load("res://Scenes/LocalGame.tscn")
	#get_tree().current_scene.add_child(LocalGame)
	get_tree().change_scene_to_file("res://Scenes/LocalGame.tscn")
