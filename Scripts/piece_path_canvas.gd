extends Control
class_name PiecePathCanvas

signal strokes_changed

enum ToolMode {
	FREEHAND,
	ERASER,
	LINE,
	RECTANGLE,
	ELLIPSE,
}

const MIN_POINT_DISTANCE := 1.2
const SMOOTHING_FACTOR := 0.28
const MIN_VISIBLE_WIDTH := 1.5
const MIN_SNAPSHOT_DISTANCE := 18.0

var stroke_width_px := 2.0
var fill_color := Color(0.94, 0.94, 0.94, 1.0)
var outline_color := Color(0.1, 0.1, 0.1, 1.0)
var grid_line_color := Color(0.26, 0.26, 0.26, 0.45)

var current_tool: int = ToolMode.FREEHAND
var symmetry_enabled := false
var symmetry_count := 2
var snap_enabled := true
var snap_angle_degrees := 45.0

var _strokes: Array[PackedVector2Array] = []
var _active_stroke := PackedVector2Array()
var _stroke_origin := Vector2.ZERO
var _is_drawing := false
var _template_handles: Array[Dictionary] = []
var _template_drag_handle_index := -1
var _template_drag_stroke_index := -1
var _template_drag_point_index := -1
var _template_drag_start_mouse := Vector2.ZERO
var _template_drag_start_point := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_CROSS
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				if _template_drag_handle_index == -1:
					var handle_index = _find_template_handle_at(mouse_button.position)
					if handle_index != -1:
						_begin_template_drag(handle_index, mouse_button.position)
						return
				_begin_stroke(mouse_button.position)
			else:
				if _template_drag_handle_index != -1:
					_finish_template_drag()
					return
				_finish_stroke()
	elif event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		if _template_drag_handle_index != -1:
			var delta = motion.position - _template_drag_start_mouse
			var target_point = _template_drag_start_point + delta
			if _template_drag_stroke_index >= 0 and _template_drag_stroke_index < _strokes.size():
				if _template_drag_point_index >= 0 and _template_drag_point_index < _strokes[_template_drag_stroke_index].size():
					_strokes[_template_drag_stroke_index][_template_drag_point_index] = _clamp_point(target_point)
					_template_handles[_template_drag_handle_index]["position"] = _clamp_point(target_point)
					strokes_changed.emit()
					queue_redraw()
			return
		if _is_drawing and (motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			if current_tool == ToolMode.FREEHAND or current_tool == ToolMode.ERASER:
				_append_point(motion.position)
			else:
				_active_stroke = _build_preview_points(_stroke_origin, _clamp_point(motion.position))
				queue_redraw()

func _begin_stroke(position: Vector2) -> void:
	_is_drawing = true
	_stroke_origin = _clamp_point(position)
	_active_stroke = PackedVector2Array()
	_active_stroke.append(_stroke_origin)

	if current_tool == ToolMode.FREEHAND:
		_append_point(position)
	elif current_tool == ToolMode.ERASER:
		_append_eraser_point(position)
	else:
		_active_stroke = _build_preview_points(_stroke_origin, _stroke_origin)
	queue_redraw()

func _finish_stroke() -> void:
	if not _is_drawing:
		return

	var finished_strokes: Array[PackedVector2Array] = []
	if current_tool == ToolMode.FREEHAND and _active_stroke.size() >= 2:
		finished_strokes = _apply_symmetry(_refine_stroke(_active_stroke), _stroke_origin)
	elif current_tool == ToolMode.ERASER:
		_strokes = _erase_strokes_nearby(_stroke_origin)
		_is_drawing = false
		_stroke_origin = Vector2.ZERO
		_active_stroke = PackedVector2Array()
		strokes_changed.emit()
		queue_redraw()
		return
	elif current_tool == ToolMode.LINE and _active_stroke.size() >= 2:
		finished_strokes = _apply_symmetry(_build_preview_points(_stroke_origin, _active_stroke[_active_stroke.size() - 1]), _stroke_origin)
	elif current_tool == ToolMode.RECTANGLE and _active_stroke.size() >= 2:
		finished_strokes = _apply_symmetry(_build_preview_points(_stroke_origin, _active_stroke[_active_stroke.size() - 1]), _stroke_origin)
	elif current_tool == ToolMode.ELLIPSE and _active_stroke.size() >= 2:
		finished_strokes = _apply_symmetry(_build_preview_points(_stroke_origin, _active_stroke[_active_stroke.size() - 1]), _stroke_origin)

	for stroke in finished_strokes:
		if stroke.size() >= 2:
			_strokes.append(stroke)

	_is_drawing = false
	_stroke_origin = Vector2.ZERO
	_active_stroke = PackedVector2Array()
	strokes_changed.emit()
	queue_redraw()

func _append_point(local_position: Vector2) -> void:
	var clamped = _clamp_point(local_position)
	if _active_stroke.is_empty():
		_active_stroke.append(clamped)
		queue_redraw()
		return

	var last_point = _active_stroke[_active_stroke.size() - 1]
	if last_point.distance_to(clamped) < MIN_POINT_DISTANCE:
		return

	_active_stroke.append(clamped)
	if _active_stroke.size() > 2048:
		_active_stroke = _refine_stroke(_active_stroke)
	queue_redraw()

func _append_eraser_point(local_position: Vector2) -> void:
	var clamped = _clamp_point(local_position)
	var nearest_index := _find_nearest_stroke_index(clamped)
	if nearest_index != -1:
		_strokes.remove_at(nearest_index)
		strokes_changed.emit()
	queue_redraw()

func _erase_strokes_nearby(point: Vector2) -> Array[PackedVector2Array]:
	var remaining: Array[PackedVector2Array] = []
	for stroke in _strokes:
		var nearest = INF
		for candidate in stroke:
			nearest = min(nearest, candidate.distance_to(point))
		if nearest > MIN_SNAPSHOT_DISTANCE:
			remaining.append(stroke)
	return remaining

func _find_nearest_stroke_index(point: Vector2) -> int:
	var closest_index := -1
	var closest_distance := INF
	for index in range(_strokes.size()):
		for candidate in _strokes[index]:
			var distance = candidate.distance_to(point)
			if distance < closest_distance:
				closest_distance = distance
				closest_index = index
	if closest_distance > MIN_SNAPSHOT_DISTANCE:
		return -1
	return closest_index

func _clamp_point(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, 0.0, size.x),
		clampf(point.y, 0.0, size.y)
	)

func _build_preview_points(start: Vector2, end: Vector2) -> PackedVector2Array:
	var snapped_end = _snap_point(end, start)
	match current_tool:
		ToolMode.LINE:
			return _line_points(start, snapped_end)
		ToolMode.RECTANGLE:
			return _rectangle_points(start, snapped_end)
		ToolMode.ELLIPSE:
			return _ellipse_points(start, snapped_end)
		_: return [start, snapped_end]

func _snap_point(point: Vector2, anchor: Vector2) -> Vector2:
	if not snap_enabled:
		return point
	var delta = point - anchor
	if delta.length_squared() < 0.0001:
		return point
	var angle = atan2(delta.y, delta.x)
	var snap_radians = deg_to_rad(snap_angle_degrees)
	var snapped_angle = round(angle / snap_radians) * snap_radians
	var distance = delta.length()
	return anchor + Vector2(cos(snapped_angle), sin(snapped_angle)) * distance

func _line_points(start: Vector2, end: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.append(start)
	points.append(end)
	return points

func _rectangle_points(start: Vector2, end: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.append(start)
	points.append(Vector2(end.x, start.y))
	points.append(end)
	points.append(Vector2(start.x, end.y))
	points.append(start)
	return points

func _ellipse_points(start: Vector2, end: Vector2) -> PackedVector2Array:
	var center = (start + end) * 0.5
	var radius_x = abs(end.x - start.x) * 0.5
	var radius_y = abs(end.y - start.y) * 0.5
	var points := PackedVector2Array()
	var segment_count = 48
	for index in range(segment_count + 1):
		var angle = (float(index) / float(segment_count)) * TAU
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points

func _apply_symmetry(stroke: PackedVector2Array, center: Vector2) -> Array[PackedVector2Array]:
	if not symmetry_enabled or symmetry_count <= 1:
		return [stroke]

	var output: Array[PackedVector2Array] = []
	for iteration in range(symmetry_count):
		var rotated_stroke := PackedVector2Array()
		var rotation = (TAU / float(symmetry_count)) * float(iteration)
		for point in stroke:
			var rotated = point - center
			var x = rotated.x * cos(rotation) - rotated.y * sin(rotation)
			var y = rotated.x * sin(rotation) + rotated.y * cos(rotation)
			rotated_stroke.append(center + Vector2(x, y))
		if rotated_stroke.size() >= 2:
			output.append(rotated_stroke)
	return output

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
	_draw_template_handles()

func _draw_stroke(stroke: PackedVector2Array) -> void:
	if stroke.size() < 2:
		return

	var refined = _refine_stroke(stroke)
	if refined.size() < 2:
		return

	var outline_width = max(1.4, stroke_width_px * 0.9)
	var core_width = max(1.0, stroke_width_px * 0.6)
	draw_polyline(refined, outline_color, outline_width, true)
	draw_polyline(refined, fill_color, core_width, true)
	draw_polyline(refined, Color(1.0, 1.0, 1.0, 0.10), max(0.7, stroke_width_px * 0.2), true)

	if refined.size() >= 2:
		draw_circle(refined[0], max(1.0, stroke_width_px * 0.18), outline_color)
		draw_circle(refined[refined.size() - 1], max(1.0, stroke_width_px * 0.18), outline_color)

func _draw_template_handles() -> void:
	if _template_handles.is_empty():
		return
	for handle in _template_handles:
		var position: Vector2 = handle.get("position", Vector2.ZERO)
		var radius = 6.0
		draw_arc(position, radius, 0.0, TAU, 18, Color(0.96, 0.88, 0.50, 1.0), 2.0, true)
		draw_circle(position, radius * 0.5, Color(1.0, 0.95, 0.65, 1.0))

func _begin_template_drag(handle_index: int, mouse_position: Vector2) -> void:
	if handle_index < 0 or handle_index >= _template_handles.size():
		return
	_template_drag_handle_index = handle_index
	var handle = _template_handles[handle_index]
	_template_drag_stroke_index = int(handle.get("stroke_index", -1))
	_template_drag_point_index = int(handle.get("point_index", -1))
	_template_drag_start_mouse = mouse_position
	if _template_drag_stroke_index >= 0 and _template_drag_stroke_index < _strokes.size():
		if _template_drag_point_index >= 0 and _template_drag_point_index < _strokes[_template_drag_stroke_index].size():
			_template_drag_start_point = _strokes[_template_drag_stroke_index][_template_drag_point_index]
			return
	_template_drag_handle_index = -1
	_template_drag_stroke_index = -1
	_template_drag_point_index = -1
	_template_drag_start_mouse = Vector2.ZERO
	_template_drag_start_point = Vector2.ZERO

func _finish_template_drag() -> void:
	_template_drag_handle_index = -1
	_template_drag_stroke_index = -1
	_template_drag_point_index = -1
	_template_drag_start_mouse = Vector2.ZERO
	_template_drag_start_point = Vector2.ZERO
	strokes_changed.emit()
	queue_redraw()

func _find_template_handle_at(position: Vector2) -> int:
	for index in range(_template_handles.size()):
		var handle = _template_handles[index]
		var handle_position: Vector2 = handle.get("position", Vector2.ZERO)
		if handle_position.distance_to(position) <= 12.0:
			return index
	return -1

func _refine_stroke(stroke: PackedVector2Array) -> PackedVector2Array:
	if stroke.size() < 3:
		return stroke

	var smoothed = _smooth_stroke(stroke)
	var tolerance = max(0.8, stroke_width_px * 0.35)
	var simplified = _simplify_stroke(smoothed, tolerance)
	if simplified.size() < 2:
		return smoothed
	return simplified

func _smooth_stroke(stroke: PackedVector2Array) -> PackedVector2Array:
	if stroke.size() < 3:
		return stroke

	var smoothed := PackedVector2Array()
	for index in range(stroke.size()):
		var point = stroke[index]
		var prev = stroke[max(0, index - 1)]
		var next = stroke[min(stroke.size() - 1, index + 1)]
		var midpoint = Vector2(
			(prev.x + point.x + next.x) / 3.0,
			(prev.y + point.y + next.y) / 3.0
		)
		smoothed.append(Vector2(
			lerp(point.x, midpoint.x, SMOOTHING_FACTOR),
			lerp(point.y, midpoint.y, SMOOTHING_FACTOR)
		))
	return smoothed

func _simplify_stroke(stroke: PackedVector2Array, tolerance: float) -> PackedVector2Array:
	if stroke.size() <= 2:
		return stroke

	var keep: Dictionary = {}
	var stack: Array = [[0, stroke.size() - 1]]
	while not stack.is_empty():
		var segment = stack.pop_back()
		var start_index = int(segment[0])
		var end_index = int(segment[1])
		if end_index <= start_index + 1:
			continue

		var farthest_index = -1
		var farthest_distance = 0.0
		for index in range(start_index + 1, end_index):
			var distance = _distance_to_segment(stroke[index], stroke[start_index], stroke[end_index])
			if distance > farthest_distance:
				farthest_distance = distance
				farthest_index = index

		if farthest_index != -1 and farthest_distance > tolerance:
			keep[farthest_index] = true
			stack.append([start_index, farthest_index])
			stack.append([farthest_index, end_index])

	var output := PackedVector2Array()
	for index in range(stroke.size()):
		if index == 0 or index == stroke.size() - 1 or keep.has(index):
			output.append(stroke[index])
	return output if output.size() >= 2 else stroke

func _distance_to_segment(point: Vector2, start: Vector2, end: Vector2) -> float:
	var segment := end - start
	var length_squared = segment.length_squared()
	if length_squared <= 0.0001:
		return point.distance_to(start)
	var t = clamp((point - start).dot(segment) / length_squared, 0.0, 1.0)
	var projection = start + segment * t
	return point.distance_to(projection)

func clear_strokes() -> void:
	_strokes.clear()
	_template_handles.clear()
	_active_stroke = PackedVector2Array()
	_is_drawing = false
	_stroke_origin = Vector2.ZERO
	_template_drag_handle_index = -1
	_template_drag_stroke_index = -1
	_template_drag_point_index = -1
	_template_drag_start_mouse = Vector2.ZERO
	_template_drag_start_point = Vector2.ZERO
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
		var cleaned = _refine_stroke(stroke)
		if cleaned.size() < 2:
			continue
		var encoded_points: Array = []
		for point in cleaned:
			encoded_points.append({
				"x": clampf(point.x / width, 0.0, 1.0),
				"y": clampf(point.y / height, 0.0, 1.0)
			})
		if encoded_points.size() >= 2:
			output.append(encoded_points)
	return output

func set_normalized_strokes(normalized_strokes: Array) -> void:
	_strokes.clear()
	_template_handles.clear()
	_active_stroke = PackedVector2Array()
	_is_drawing = false
	_stroke_origin = Vector2.ZERO
	_template_drag_handle_index = -1
	_template_drag_stroke_index = -1
	_template_drag_point_index = -1
	_template_drag_start_mouse = Vector2.ZERO
	_template_drag_start_point = Vector2.ZERO
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
			var refined = _refine_stroke(stroke)
			if refined.size() >= 2:
				_strokes.append(refined)
	strokes_changed.emit()
	queue_redraw()

func set_template_data(template_data: Dictionary) -> void:
	if template_data.is_empty():
		_template_handles.clear()
		return
	var template_strokes = template_data.get("strokes", [])
	set_normalized_strokes(template_strokes)
	var handle_data = template_data.get("handles", [])
	for handle in handle_data:
		if not (handle is Dictionary):
			continue
		var stroke_index = int(handle.get("stroke_index", -1))
		var point_index = int(handle.get("point_index", -1))
		if stroke_index < 0 or stroke_index >= _strokes.size():
			continue
		if point_index < 0 or point_index >= _strokes[stroke_index].size():
			continue
		_template_handles.append({
			"stroke_index": stroke_index,
			"point_index": point_index,
			"position": _strokes[stroke_index][point_index]
		})
	queue_redraw()

func set_tool(tool: int) -> void:
	current_tool = tool
	if current_tool == ToolMode.ERASER:
		symmetry_enabled = false
		queue_redraw()

func set_symmetry(enabled: bool) -> void:
	symmetry_enabled = enabled
	queue_redraw()

func set_symmetry_count(count: int) -> void:
	symmetry_count = max(1, count)
	queue_redraw()

func set_snap_enabled(enabled: bool) -> void:
	snap_enabled = enabled
	queue_redraw()

func set_snap_angle_degrees(angle_degrees: float) -> void:
	snap_angle_degrees = max(1.0, absf(angle_degrees))
	queue_redraw()
