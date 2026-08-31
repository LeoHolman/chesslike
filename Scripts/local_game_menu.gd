extends Control

@onready var width_spin_box: SpinBox = $WidthSpinBox
@onready var height_spin_box: SpinBox = $HeightSpinBox
@onready var board_preview: Control = $PreviewArea/BoardPreview

func _ready() -> void:
	width_spin_box.value_changed.connect(_refresh_preview)
	height_spin_box.value_changed.connect(_refresh_preview)
	_refresh_preview(0.0)

func _refresh_preview(_value: float = 0.0) -> void:
	for child in board_preview.get_children():
		child.queue_free()

	var width = int(width_spin_box.value)
	var height = int(height_spin_box.value)

	var tile_size = min(
		int(board_preview.size.x / max(width, 1)),
		int(board_preview.size.y / max(height, 1))
	)
	if tile_size < 1:
		tile_size = 1

	var is_white = true
	for y in range(height):
		for x in range(width):
			var tile = ColorRect.new()
			tile.size = Vector2(tile_size, tile_size)
			tile.position = Vector2(x * tile_size, y * tile_size)
			tile.color = Color.WHITE if is_white else Color.DIM_GRAY
			board_preview.add_child(tile)
			is_white = !is_white

		if width % 2 == 0:
			is_white = !is_white

func _on_start_game_button_pressed() -> void:
	var height = $HeightSpinBox.value
	var width = $WidthSpinBox.value
	
	$"/root/GameManager".BoardHeight = height
	$"/root/GameManager".BoardWidth = width
	
	#var LocalGame = load("res://Scenes/LocalGame.tscn")
	#get_tree().current_scene.add_child(LocalGame)
	get_tree().change_scene_to_file("res://Scenes/LocalGame.tscn")
