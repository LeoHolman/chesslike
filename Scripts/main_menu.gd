extends Control


func _ready() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)



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
