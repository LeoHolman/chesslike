extends Control



func _on_exit_game_button_pressed() -> void:
	get_tree().quit()



func _on_local_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/LocalGameMenu.tscn")

func _on_manage_pieces_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ManagePieces.tscn")
