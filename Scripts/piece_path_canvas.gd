extends Control
class_name PiecePathCanvas

signal strokes_changed

const MIN_POINT_DISTANCE := 2.0

var stroke_width_px := 10.0
var fill_color := Color(0.94, 0.94, 0.94, 1.0)
var outline_color := Color(0.1, 0.1, 0.1, 1.0)
var grid_line_color := Color(0.26, 0.26, 0.26, 0.45)

var _strokes: Array[PackedVector2Array] = []
var _active_stroke := PackedVector2Array()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_CROSS
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				_active_stroke = PackedVector2Array()
				_append_point(mouse_button.position)
			else:
				if _active_stroke.size() >= 2:
					_strokes.append(_active_stroke)
					strokes_changed.emit()
				_active_stroke = PackedVector2Array()
				queue_redraw()
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_append_point(motion.position)

func _append_point(local_position: Vector2) -> void:
	var clamped = Vector2(
		clampf(local_position.x, 0.0, size.x),
		clampf(local_position.y, 0.0, size.y)
	)
	if _active_stroke.is_empty() or _active_stroke[_active_stroke.size() - 1].distance_to(clamped) >= MIN_POINT_DISTANCE:
		_active_stroke.append(clamped)
		queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.16, 0.16, 0.16, 1.0), true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.86, 0.86, 0.86, 0.8), false, 2.0)

	var grid_cells = 8
	if size.x > 0.0 and size.y > 0.0:
		for index in range(1, grid_cells):
			var x = size.x * float(index) / float(grid_cells)
			var y = size.y * float(index) / float(grid_cells)
			draw_line(Vector2(x, 0.0), Vector2(x, size.y), grid_line_color, 1.0)
			draw_line(Vector2(0.0, y), Vector2(size.x, y), grid_line_color, 1.0)

	for stroke in _strokes:
		_draw_stroke(stroke)
	if _active_stroke.size() >= 2:
		_draw_stroke(_active_stroke)

func _draw_stroke(stroke: PackedVector2Array) -> void:
	if stroke.size() < 2:
		return
	var outline_width = stroke_width_px + 4.0
	draw_polyline(stroke, outline_color, outline_width, true)
	draw_polyline(stroke, fill_color, stroke_width_px, true)

func clear_strokes() -> void:
	_strokes.clear()
	_active_stroke = PackedVector2Array()
	strokes_changed.emit()
	queue_redraw()

func undo_last_stroke() -> void:
	if _strokes.is_empty():
		return
	_strokes.remove_at(_strokes.size() - 1)
	strokes_changed.emit()
	queue_redraw()

func has_content() -> bool:
	return not _strokes.is_empty()

func get_normalized_strokes() -> Array:
	var output: Array = []
	var width = max(size.x, 1.0)
	var height = max(size.y, 1.0)
	for stroke in _strokes:
		if stroke.size() < 2:
			continue
		var encoded_points: Array = []
		for point in stroke:
			encoded_points.append({
				"x": clampf(point.x / width, 0.0, 1.0),
				"y": clampf(point.y / height, 0.0, 1.0)
			})
		if encoded_points.size() >= 2:
			output.append(encoded_points)
	return output

func set_normalized_strokes(normalized_strokes: Array) -> void:
	_strokes.clear()
	_active_stroke = PackedVector2Array()
	var width = max(size.x, 1.0)
	var height = max(size.y, 1.0)
	for stroke_data in normalized_strokes:
		if not (stroke_data is Array):
			continue
		var stroke := PackedVector2Array()
		for point_data in stroke_data:
			if not (point_data is Dictionary):
				continue
			stroke.append(Vector2(
				clampf(float(point_data.get("x", 0.0)), 0.0, 1.0) * width,
				clampf(float(point_data.get("y", 0.0)), 0.0, 1.0) * height
			))
		if stroke.size() >= 2:
			_strokes.append(stroke)
	strokes_changed.emit()
	queue_redraw()
