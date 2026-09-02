extends Control

const UITheme = preload("res://Scripts/ui_theme.gd")

@onready var center_container: CenterContainer = $CenterContainer
@onready var menu_content: VBoxContainer = $CenterContainer/MenuContent
@onready var title_label: Label = $CenterContainer/MenuContent/MainMenuTitle
@onready var local_game_button: Button = $CenterContainer/MenuContent/LocalGameButton
@onready var online_game_button: Button = $CenterContainer/MenuContent/OnlineGameButton
@onready var manage_pieces_button: Button = $CenterContainer/MenuContent/ManagePiecesButton
@onready var manage_presets_button: Button = $CenterContainer/MenuContent/ManagePresetsButton
@onready var options_button: Button = $CenterContainer/MenuContent/OptionsButton
@onready var exit_game_button: Button = $CenterContainer/MenuContent/ExitGameButton
@onready var resolution_option_button: OptionButton = $OptionsPopup/MarginContainer/VBoxContainer/ResolutionOptionButton
@onready var apply_resolution_button: Button = $OptionsPopup/MarginContainer/VBoxContainer/ApplyResolutionButton
@onready var cancel_resolution_button: Button = $OptionsPopup/MarginContainer/VBoxContainer/CancelResolutionButton

var menu_panel: PanelContainer
var resolution_options: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]

func _ready() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	_setup_resolution_options()
	_apply_visual_style()

func _apply_visual_style() -> void:
	UITheme.ensure_flat_background(self)
	_ensure_menu_panel()
	title_label.text = "♘  Chesslike"
	UITheme.apply_title_text(title_label, 30)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_content.add_theme_constant_override("separation", 12)
	UITheme.apply_button_theme(local_game_button, Color(0.16, 0.35, 0.28, 1.0), 40.0, 15)
	UITheme.apply_button_theme(online_game_button, Color(0.17, 0.28, 0.40, 1.0), 40.0, 15)
	UITheme.apply_button_theme(manage_pieces_button, Color(0.22, 0.24, 0.39, 1.0), 40.0, 15)
	UITheme.apply_button_theme(manage_presets_button, Color(0.25, 0.20, 0.38, 1.0), 40.0, 15)
	UITheme.apply_button_theme(options_button, Color(0.22, 0.30, 0.45, 1.0), 40.0, 15)
	UITheme.apply_button_theme(exit_game_button, Color(0.37, 0.19, 0.19, 1.0), 40.0, 15)

func _ensure_menu_panel() -> void:
	if menu_panel != null:
		return
	var existing = center_container.get_node_or_null("MenuPanel")
	if existing is PanelContainer:
		menu_panel = existing
		return
	if menu_content.get_parent() != null:
		menu_content.get_parent().remove_child(menu_content)
	menu_panel = PanelContainer.new()
	menu_panel.name = "MenuPanel"
	menu_panel.custom_minimum_size = Vector2(340.0, 0.0)
	menu_panel.add_theme_stylebox_override("panel", UITheme.panel_style(Color(0.08, 0.09, 0.11, 0.96)))
	center_container.add_child(menu_panel)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	menu_panel.add_child(margin)

	menu_content.layout_mode = 2
	menu_content.custom_minimum_size = Vector2(280.0, 0.0)
	margin.add_child(menu_content)



func _setup_resolution_options() -> void:
	resolution_option_button.clear()
	var current_size = DisplayServer.window_get_size()
	var current_index = 0
	for index in range(resolution_options.size()):
		var option = resolution_options[index]
		resolution_option_button.add_item("%dx%d" % [option.x, option.y])
		if option == current_size:
			current_index = index
	resolution_option_button.select(current_index)

func _on_options_button_pressed() -> void:
	_setup_resolution_options()
	var popup_panel = $OptionsPopup
	popup_panel.popup_centered(Vector2(420, 200))
	popup_panel.add_theme_stylebox_override("panel", UITheme.panel_style(Color(0.10, 0.11, 0.14, 1.0), Color(0.42, 0.47, 0.60, 1.0), 12, 2))
	var margin = $OptionsPopup/MarginContainer
	if margin != null:
		margin.modulate = Color(1.0, 1.0, 1.0, 1.0)
		margin.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_apply_resolution_button_pressed() -> void:
	var selected_index = resolution_option_button.selected
	if selected_index < 0 or selected_index >= resolution_options.size():
		return
	var target_size = resolution_options[selected_index]
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(target_size)
	$OptionsPopup.hide()

func _on_cancel_resolution_button_pressed() -> void:
	$OptionsPopup.hide()

func _on_exit_game_button_pressed() -> void:
	get_tree().quit()

func _on_local_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/LocalGameMenu.tscn")

func _on_online_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/OnlineGameMenu.tscn")

func _on_manage_pieces_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ManagePieces.tscn")

func _on_manage_presets_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ManagePresets.tscn")
