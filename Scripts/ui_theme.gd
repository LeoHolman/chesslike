extends RefCounted
class_name UITheme

const PANEL_BORDER = Color(0.27, 0.31, 0.38, 1.0)
const INNER_PANEL_BORDER = Color(0.29, 0.33, 0.40, 1.0)
const FIELD_FILL = Color(0.12, 0.13, 0.16, 1.0)
const FIELD_BORDER = Color(0.30, 0.34, 0.40, 1.0)
const BUTTON_BORDER = Color(0.30, 0.35, 0.41, 1.0)
const BUTTON_HIGHLIGHT = Color(0.95, 0.83, 0.58, 1.0)
const BUTTON_TEXT = Color(0.98, 0.98, 0.98, 1.0)
const TEXT_TITLE = Color(1.0, 0.94, 0.84, 1.0)
const TEXT_SECTION = Color(0.98, 0.94, 0.83, 1.0)
const TEXT_BODY = Color(0.84, 0.88, 0.94, 1.0)
const TEXT_MUTED = Color(0.82, 0.86, 0.92, 1.0)
const TEXT_SUBTLE = Color(0.80, 0.84, 0.90, 1.0)

static func ensure_atmospheric_background(root: Control, top_anchors: Vector4 = Vector4(0.14, 0.08, 0.86, 0.22), bottom_anchors: Vector4 = Vector4(0.20, 0.72, 0.80, 0.88), base_color: Color = Color(0.05, 0.06, 0.08, 1.0), top_color: Color = Color(0.18, 0.26, 0.36, 0.24), bottom_color: Color = Color(0.26, 0.19, 0.14, 0.20)) -> void:
	_ensure_background_layer(root, "Background", 0, Vector4(0.0, 0.0, 1.0, 1.0), base_color)
	_ensure_background_layer(root, "GlowTop", 1, top_anchors, top_color)
	_ensure_background_layer(root, "GlowBottom", 2, bottom_anchors, bottom_color)

static func panel_style(fill: Color, border: Color = PANEL_BORDER, radius: int = 14, border_width: int = 2) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	return style

static func button_style(fill: Color, border: Color, radius: int = 10, border_width: int = 2, margin_left: float = 10.0, margin_right: float = 10.0, margin_top: float = 6.0, margin_bottom: float = 6.0) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.content_margin_left = margin_left
	style.content_margin_right = margin_right
	style.content_margin_top = margin_top
	style.content_margin_bottom = margin_bottom
	return style

static func apply_button_theme(button: Button, fill: Color, min_height: float = 40.0, font_size: int = 14, border: Color = BUTTON_BORDER, highlight: Color = BUTTON_HIGHLIGHT, text_color: Color = BUTTON_TEXT) -> void:
	button.custom_minimum_size.y = min_height
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", text_color)
	button.add_theme_stylebox_override("normal", button_style(fill, border))
	button.add_theme_stylebox_override("hover", button_style(fill.lightened(0.08), highlight))
	button.add_theme_stylebox_override("pressed", button_style(fill.darkened(0.10), highlight))
	button.add_theme_stylebox_override("focus", button_style(fill, highlight))

static func apply_secondary_button_theme(button: Button, min_height: float = 40.0, font_size: int = 14) -> void:
	apply_button_theme(button, Color(0.14, 0.15, 0.18, 1.0), min_height, font_size, Color(0.28, 0.31, 0.37, 1.0), BUTTON_HIGHLIGHT, Color(0.95, 0.97, 1.0, 1.0))

static func field_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = FIELD_FILL
	style.border_color = FIELD_BORDER
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style

static func field_focus_style() -> StyleBoxFlat:
	var style = field_style()
	style.border_color = BUTTON_HIGHLIGHT
	return style

static func apply_field_theme(control: Control) -> void:
	control.add_theme_stylebox_override("normal", field_style())
	control.add_theme_stylebox_override("focus", field_focus_style())

static func apply_label_theme(label: Label, font_size: int, font_color: Color) -> void:
	if label == null:
		return
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)

static func apply_title_text(label: Label, font_size: int = 27) -> void:
	apply_label_theme(label, font_size, TEXT_TITLE)

static func apply_section_text(label: Label, font_size: int = 18) -> void:
	apply_label_theme(label, font_size, TEXT_SECTION)

static func apply_body_text(label: Label, font_size: int = 14) -> void:
	apply_label_theme(label, font_size, TEXT_BODY)

static func apply_muted_text(label: Label, font_size: int = 13) -> void:
	apply_label_theme(label, font_size, TEXT_MUTED)

static func apply_subtle_text(label: Label, font_size: int = 12) -> void:
	apply_label_theme(label, font_size, TEXT_SUBTLE)

static func _ensure_background_layer(root: Control, name: String, index: int, anchors: Vector4, color: Color) -> void:
	var layer = root.get_node_or_null(name)
	if layer == null:
		layer = ColorRect.new()
		layer.name = name
		root.add_child(layer)
	if not (layer is ColorRect):
		return
	var color_layer: ColorRect = layer
	color_layer.layout_mode = 1
	color_layer.anchor_left = anchors.x
	color_layer.anchor_top = anchors.y
	color_layer.anchor_right = anchors.z
	color_layer.anchor_bottom = anchors.w
	color_layer.grow_horizontal = 2
	color_layer.grow_vertical = 2
	color_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_layer.color = color
	root.move_child(color_layer, index)
