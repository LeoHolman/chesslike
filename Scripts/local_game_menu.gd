extends Control



func _on_start_game_button_pressed() -> void:
	var height = $HeightSpinBox.value
	var width = $WidthSpinBox.value
	
	$"/root/GameManager".BoardHeight = height
	$"/root/GameManager".BoardWidth = width
	
	#var LocalGame = load("res://Scenes/LocalGame.tscn")
	#get_tree().current_scene.add_child(LocalGame)
	get_tree().change_scene_to_file("res://Scenes/LocalGame.tscn")
