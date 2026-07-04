extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var height = $"/root/GameManager".BoardHeight
	var width = $"/root/GameManager".BoardWidth
	var WhiteTile = load("res://Scenes/WhiteTile.tscn")
	var BlackTile = load("res://Scenes/BlackTile.tscn")
	var viewportSize = get_viewport_rect().size
	var currentX = 0.0
	var currentY = viewportSize.y
	
	var isWhiteTile = true
	
	for i in height:
		currentX = 0.0
		currentY -= 100.0
		if i > 0 and fmod(width,2.0) == 0:
			isWhiteTile = not isWhiteTile
		for j in width:
			var tile
			if isWhiteTile:
				tile = WhiteTile.instantiate()
			else:
				tile = BlackTile.instantiate()
			get_tree().current_scene.add_child(tile)
			tile.position = Vector2(currentX, currentY)
			isWhiteTile = not isWhiteTile
			currentX += 100.0
			

	
