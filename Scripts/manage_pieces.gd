extends Control

@onready var pieces_list: ItemList = %PiecesList
@onready var message_label: Label = %MessageLabel

var list_piece_ids: Array[String] = []

func _ready() -> void:
	_refresh_piece_list()

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
		message_label.text = "No custom pieces yet."
	else:
		message_label.text = ""

func _on_create_piece_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/CreatePiece.tscn")

func _on_delete_piece_button_pressed() -> void:
	var selected = pieces_list.get_selected_items()
	if selected.is_empty():
		message_label.text = "Select a custom piece to delete."
		return
	var selected_index = int(selected[0])
	if selected_index < 0 or selected_index >= list_piece_ids.size():
		message_label.text = "Invalid selection."
		return

	var piece_id = list_piece_ids[selected_index]
	if not $"/root/GameManager".delete_custom_piece(piece_id):
		message_label.text = "Could not delete custom piece."
		return

	message_label.text = "Deleted custom piece: %s" % piece_id
	_refresh_piece_list()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
