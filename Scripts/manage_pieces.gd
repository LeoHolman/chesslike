extends Control

const UITheme = preload("res://Scripts/ui_theme.gd")

@onready var pieces_list: ItemList = %PiecesList
@onready var message_label: Label = %MessageLabel
@onready var title_label: Label = $RootMargin/RootVBox/TitleLabel
@onready var root_margin: MarginContainer = $RootMargin
@onready var root_vbox: VBoxContainer = $RootMargin/RootVBox
@onready var actions_row: HBoxContainer = $RootMargin/RootVBox/ActionsRow
@onready var create_piece_button: Button = $RootMargin/RootVBox/ActionsRow/CreatePieceButton
@onready var edit_piece_button: Button = $RootMargin/RootVBox/ActionsRow/EditPieceButton
@onready var delete_piece_button: Button = $RootMargin/RootVBox/ActionsRow/DeletePieceButton
@onready var back_button: Button = $RootMargin/RootVBox/ActionsRow/BackButton

var list_piece_ids: Array[String] = []
var content_panel: PanelContainer

func _ready() -> void:
	_apply_visual_style()
	_refresh_piece_list()
	if message_label.text == "":
		message_label.text = "Select a custom piece to edit or delete, or create a new one."

func _apply_visual_style() -> void:
	title_label.text = "▤ Manage Pieces"
	UITheme.apply_title_text(title_label, 27)
	UITheme.apply_body_text(message_label, 14)
	UITheme.ensure_atmospheric_background(self)
	_ensure_content_panel()
	_style_item_list()
	_style_action_button(create_piece_button, Color(0.16, 0.35, 0.28, 1.0))
	_style_action_button(edit_piece_button, Color(0.17, 0.29, 0.40, 1.0))
	_style_action_button(delete_piece_button, Color(0.40, 0.20, 0.20, 1.0))
	_style_secondary_button(back_button)

func _ensure_content_panel() -> void:
	if content_panel != null:
		return
	content_panel = PanelContainer.new()
	content_panel.name = "ContentPanel"
	content_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style = UITheme.panel_style(Color(0.08, 0.09, 0.11, 0.96))
	content_panel.add_theme_stylebox_override("panel", panel_style)
	root_margin.add_child(content_panel)
	root_margin.move_child(content_panel, 0)

func _style_item_list() -> void:
	var list_style = UITheme.panel_style(Color(0.12, 0.13, 0.16, 0.98), UITheme.INNER_PANEL_BORDER, 10, 2)
	pieces_list.add_theme_stylebox_override("panel", list_style)
	pieces_list.add_theme_color_override("font_color", Color(0.93, 0.95, 0.98, 1.0))

func _style_action_button(button: Button, fill: Color) -> void:
	UITheme.apply_button_theme(button, fill, 42.0, 15)

func _style_secondary_button(button: Button) -> void:
	UITheme.apply_secondary_button_theme(button, 42.0, 15)

func _refresh_piece_list() -> void:
	pieces_list.clear()
	list_piece_ids.clear()
	var game_manager = $"/root/GameManager"
	for piece_data in game_manager.get_custom_pieces():
		var piece_id = str(piece_data.get("id", ""))
		var piece_name = str(piece_data.get("name", piece_id))
		var piece_symbol = str(piece_data.get("symbol", "?"))
		var piece_strength = int(piece_data.get("strength", 1))
		pieces_list.add_item("%s (%s)  [id: %s]  STR %d" % [piece_name, piece_symbol, piece_id, piece_strength])
		list_piece_ids.append(piece_id)

	if list_piece_ids.is_empty():
		message_label.text = "No custom pieces yet. Create one to get started."
	else:
		message_label.text = "Select a custom piece to edit or delete, or create a new one."

func _on_create_piece_button_pressed() -> void:
	$"/root/GameManager".queue_custom_piece_for_edit("")
	get_tree().change_scene_to_file("res://Scenes/CreatePiece.tscn")

func _on_edit_piece_button_pressed() -> void:
	var piece_id = _get_selected_piece_id_or_show_error("Select a custom piece to edit.")
	if piece_id == "":
		return
	$"/root/GameManager".queue_custom_piece_for_edit(piece_id)
	get_tree().change_scene_to_file("res://Scenes/CreatePiece.tscn")

func _on_delete_piece_button_pressed() -> void:
	var piece_id = _get_selected_piece_id_or_show_error("Select a custom piece to delete.")
	if piece_id == "":
		return

	if not $"/root/GameManager".delete_custom_piece(piece_id):
		message_label.text = "Could not delete custom piece."
		return

	message_label.text = "Deleted custom piece: %s" % piece_id
	_refresh_piece_list()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _get_selected_piece_id_or_show_error(error_text: String) -> String:
	var selected = pieces_list.get_selected_items()
	if selected.is_empty():
		message_label.text = error_text
		return ""
	var selected_index = int(selected[0])
	if selected_index < 0 or selected_index >= list_piece_ids.size():
		message_label.text = "Invalid selection."
		return ""
	return list_piece_ids[selected_index]
