extends Node

const PRESET_SAVE_PATH = "user://saved_presets.json"
const CUSTOM_PIECES_SAVE_PATH = "user://custom_pieces.json"
const CUSTOM_PIECE_ICON_DIR = "user://custom_piece_icons"
const CUSTOM_MOVE_KIND_JUMP = "jump"
const CUSTOM_MOVE_KIND_SLIDE = "slide"
const CUSTOM_CAPTURE_MODE_ANY = "any"
const CUSTOM_CAPTURE_MODE_NON_CAPTURE = "non_capture"
const CUSTOM_CAPTURE_MODE_CAPTURE_ONLY = "capture_only"
const CUSTOM_SLIDE_SCOPE_INFINITE = "infinite"
const CUSTOM_SLIDE_SCOPE_HALTING = "halting"
const DEFAULT_SPELL_CARDS: Array[Dictionary] = [
	{"id": "haste", "name": "Haste", "type": "regular", "description": "Target piece moves twice this turn."},
	{"id": "assassinate", "name": "Assassinate", "type": "power", "description": "Target non-king piece is captured."},
	{"id": "fortify", "name": "Fortify", "type": "regular", "description": "Target allied piece cannot be captured until your next turn."},
	{"id": "teleport", "name": "Teleport", "type": "power", "description": "Move target allied piece to any empty square."},
	{"id": "barrier", "name": "Barrier", "type": "regular", "description": "Target square is blocked to movement this turn."}
]

var BoardHeight;
var BoardWidth;
var StartingPieces = []
var SpecialRules = {
	"castling": true,
	"en_passant": true,
	"promotion": true,
	"allow_undo": false,
	"enable_spell_cards": false,
	"piece_dropping": false,
	"piece_stacking": false,
	"enable_territory": false,
	"enable_muster": false,
	"capture_to_drop_pool": false,
	"limit_army_strength": false,
	"unbalanced_armies": false
}
var PromotionPiecePool = ["queen", "rook", "bishop", "knight"]
var PromotionZones = {
	"white_rows": 1,
	"black_rows": 1
}
var TerritoryRows = 3
var VictoryCondition = "checkmate"
var ArmyStrengthCap = 32
var ArmyStrengthCapWhite = 32
var ArmyStrengthCapBlack = 32
var StartingDropPools = {
	"white": [],
	"black": []
}
var PlayerColors = {
	"white": {"r": 1.0, "g": 1.0, "b": 1.0, "a": 1.0},
	"black": {"r": 0.08, "g": 0.08, "b": 0.08, "a": 1.0}
}
var TileColors = {
	"light": {"r": 1.0, "g": 1.0, "b": 1.0, "a": 1.0},
	"dark": {"r": 0.41, "g": 0.41, "b": 0.41, "a": 1.0}
}
var SpellCardHandSize = 3
var SpellCardHandSizeWhite = 3
var SpellCardHandSizeBlack = 3
var SpellCardsRandom = true
var SpellCardAllowDuplicates = true
var SpellCardDrawReplacementAfterCast = false
var SpellCardAvailableIds = ["haste", "assassinate", "fortify", "teleport", "barrier"]
var StartingSpellHands = {
	"white": [],
	"black": []
}
var PendingPresetName = ""
var PendingCustomPieceEditId = ""
var SavedPresets = {}
var PieceBank = [
	"pawn",
	"knight",
	"bishop",
	"rook",
	"queen",
	"king",
	"shogi_pawn",
	"lance",
	"shogi_knight",
	"silver_general",
	"gold_general"
]
var _base_piece_bank: Array = []
var PieceDefinitions = {
	"pawn": {
		"name": "Pawn",
		"symbol": "P",
		"move_type": "pawn",
		"stack_growth": ["pawn", "gold_general_step", "king_step"]
	},
	"knight": {
		"name": "Knight",
		"symbol": "N",
		"move_type": "knight_jump",
		"stack_growth": ["knight_jump", "silver_general_step", "gold_general_step"]
	},
	"bishop": {
		"name": "Bishop",
		"symbol": "B",
		"move_type": "diagonal_slide",
		"stack_growth": ["diagonal_slide", "omni_slide", "omni_slide"]
	},
	"rook": {
		"name": "Rook",
		"symbol": "R",
		"move_type": "cardinal_slide",
		"stack_growth": ["cardinal_slide", "omni_slide", "omni_slide"]
	},
	"queen": {
		"name": "Queen",
		"symbol": "Q",
		"move_type": "omni_slide",
		"stack_growth": ["omni_slide", "omni_slide", "omni_slide"]
	},
	"king": {
		"name": "King",
		"symbol": "K",
		"move_type": "king_step",
		"stack_growth": ["king_step", "king_step", "king_step"]
	},
	"shogi_pawn": {
		"name": "Shogi Pawn",
		"symbol": "歩",
		"move_type": "shogi_pawn",
		"stack_growth": ["shogi_pawn", "gold_general_step", "king_step"]
	},
	"lance": {
		"name": "Lance",
		"symbol": "香",
		"move_type": "lance_forward_slide",
		"stack_growth": ["lance_forward_slide", "cardinal_slide", "omni_slide"]
	},
	"shogi_knight": {
		"name": "Shogi Knight",
		"symbol": "桂",
		"move_type": "shogi_knight_jump",
		"stack_growth": ["shogi_knight_jump", "silver_general_step", "gold_general_step"]
	},
	"silver_general": {
		"name": "Silver General",
		"symbol": "銀",
		"move_type": "silver_general_step",
		"stack_growth": ["silver_general_step", "gold_general_step", "king_step"]
	},
	"gold_general": {
		"name": "Gold General",
		"symbol": "金",
		"move_type": "gold_general_step",
		"stack_growth": ["gold_general_step", "king_step", "omni_slide"]
	}
}
var _base_piece_definitions = {}
var CustomPieces = {}
var PieceIconCache = {}

const PATH_ICON_TEXTURE_SIZE = 96
const PATH_ICON_MARGIN_RATIO = 0.1

func _ready() -> void:
	_base_piece_bank = PieceBank.duplicate(true)
	_base_piece_definitions = PieceDefinitions.duplicate(true)
	_load_saved_presets()
	_load_custom_pieces()
	_rebuild_piece_catalog_with_custom_pieces()

func save_preset(preset_name: String, preset_config: Dictionary) -> void:
	SavedPresets[preset_name] = preset_config.duplicate(true)
	_write_saved_presets()

func delete_preset(preset_name: String) -> bool:
	if not SavedPresets.has(preset_name):
		return false
	SavedPresets.erase(preset_name)
	_write_saved_presets()
	return true

func rename_saved_preset(source_name: String, target_name: String) -> Dictionary:
	var old_name = source_name.strip_edges()
	var new_name = target_name.strip_edges()
	if old_name == "":
		return {"ok": false, "error": "Source preset name is empty."}
	if new_name == "":
		return {"ok": false, "error": "New preset name is empty."}
	if old_name == new_name:
		return {"ok": false, "error": "New name must be different."}
	if not SavedPresets.has(old_name):
		return {"ok": false, "error": "Selected preset no longer exists."}
	if SavedPresets.has(new_name):
		return {"ok": false, "error": "A preset with that name already exists."}
	SavedPresets[new_name] = SavedPresets[old_name].duplicate(true)
	SavedPresets.erase(old_name)
	_write_saved_presets()
	return {"ok": true}

func queue_preset_for_edit(preset_name: String) -> void:
	PendingPresetName = preset_name.strip_edges()

func consume_pending_preset_for_edit() -> String:
	var pending = PendingPresetName
	PendingPresetName = ""
	return pending

func get_spell_card_definitions() -> Array[Dictionary]:
	return DEFAULT_SPELL_CARDS.duplicate(true)

func is_valid_spell_card_id(card_id: String) -> bool:
	for card in DEFAULT_SPELL_CARDS:
		if str(card.get("id", "")) == card_id:
			return true
	return false

func normalize_spell_card_ids(source_ids: Variant) -> Array:
	var by_id = {}
	for card in DEFAULT_SPELL_CARDS:
		var id = str(card.get("id", ""))
		if id != "":
			by_id[id] = true

	var seen = {}
	var normalized: Array = []
	if source_ids is Array:
		for raw in source_ids:
			var card_id = str(raw)
			if card_id == "" or not by_id.has(card_id) or seen.has(card_id):
				continue
			seen[card_id] = true
			normalized.append(card_id)

	if normalized.is_empty():
		for card in DEFAULT_SPELL_CARDS:
			normalized.append(str(card.get("id", "")))

	return normalized

func normalize_spell_card_hands(source_hands: Variant) -> Dictionary:
	var parsed = {
		"white": [],
		"black": []
	}
	if source_hands is Dictionary:
		for owner in ["white", "black"]:
			var values = source_hands.get(owner, [])
			if not (values is Array):
				continue
			for raw in values:
				var card_id = str(raw)
				if is_valid_spell_card_id(card_id):
					parsed[owner].append(card_id)
	return parsed

func queue_custom_piece_for_edit(piece_id: String) -> void:
	PendingCustomPieceEditId = piece_id.strip_edges()

func consume_pending_custom_piece_for_edit() -> String:
	var pending = PendingCustomPieceEditId
	PendingCustomPieceEditId = ""
	return pending

func _load_saved_presets() -> void:
	SavedPresets.clear()
	if not FileAccess.file_exists(PRESET_SAVE_PATH):
		return

	var preset_file = FileAccess.open(PRESET_SAVE_PATH, FileAccess.READ)
	if preset_file == null:
		return

	var parsed_json = JSON.parse_string(preset_file.get_as_text())
	if not (parsed_json is Dictionary):
		return

	for preset_name in parsed_json.keys():
		var preset_config = parsed_json[preset_name]
		if preset_config is Dictionary:
			SavedPresets[str(preset_name)] = preset_config

func _write_saved_presets() -> void:
	var preset_file = FileAccess.open(PRESET_SAVE_PATH, FileAccess.WRITE)
	if preset_file == null:
		return
	preset_file.store_string(JSON.stringify(SavedPresets))

func _load_custom_pieces() -> void:
	CustomPieces.clear()
	if not FileAccess.file_exists(CUSTOM_PIECES_SAVE_PATH):
		return

	var custom_piece_file = FileAccess.open(CUSTOM_PIECES_SAVE_PATH, FileAccess.READ)
	if custom_piece_file == null:
		return

	var parsed_json = JSON.parse_string(custom_piece_file.get_as_text())
	if not (parsed_json is Dictionary):
		return

	for custom_piece_id in parsed_json.keys():
		var custom_piece_data = parsed_json[custom_piece_id]
		if not (custom_piece_data is Dictionary):
			continue
		var normalized = _normalize_custom_piece_data(str(custom_piece_id), custom_piece_data)
		if normalized.is_empty():
			continue
		CustomPieces[str(normalized.get("id", custom_piece_id))] = normalized

func _write_custom_pieces() -> void:
	var custom_piece_file = FileAccess.open(CUSTOM_PIECES_SAVE_PATH, FileAccess.WRITE)
	if custom_piece_file == null:
		return
	custom_piece_file.store_string(JSON.stringify(CustomPieces))

func _normalize_custom_piece_data(custom_piece_id: String, source_data: Dictionary) -> Dictionary:
	var piece_id = source_data.get("id", custom_piece_id)
	piece_id = str(piece_id).strip_edges().to_lower().replace(" ", "_")
	if piece_id == "":
		return {}

	var piece_name = str(source_data.get("name", piece_id.capitalize())).strip_edges()
	if piece_name == "":
		piece_name = piece_id.capitalize()

	var piece_symbol = str(source_data.get("symbol", piece_name.substr(0, 1).to_upper())).strip_edges()
	if piece_symbol == "":
		piece_symbol = piece_name.substr(0, 1).to_upper()

	var piece_strength = int(source_data.get("strength", 1))
	piece_strength = max(piece_strength, 1)

	var icon_path = str(source_data.get("icon_path", "")).strip_edges()
	var path_strokes = _normalize_custom_path_strokes(source_data.get("path_strokes", []))
	var path_stroke_width = clampf(float(source_data.get("path_stroke_width", 0.18)), 0.05, 0.45)
	var jump_offsets: Array = []
	for value in source_data.get("jump_offsets", []):
		var parsed_jump = _parse_vector2i_data(value)
		if parsed_jump == Vector2i.ZERO:
			continue
		if jump_offsets.has(parsed_jump):
			continue
		jump_offsets.append(parsed_jump)

	var slide_directions: Array = []
	for value in source_data.get("slide_directions", []):
		var parsed_slide = _parse_vector2i_data(value)
		if parsed_slide == Vector2i.ZERO:
			continue
		if slide_directions.has(parsed_slide):
			continue
		slide_directions.append(parsed_slide)

	var movement_rules = _normalize_custom_movement_rules(source_data.get("movement_rules", []))
	if movement_rules.is_empty():
		for jump_offset in jump_offsets:
			movement_rules.append({
				"x": jump_offset.x,
				"y": jump_offset.y,
				"kind": CUSTOM_MOVE_KIND_JUMP,
				"capture_mode": CUSTOM_CAPTURE_MODE_ANY,
				"initial_only": false,
				"slide_scope": CUSTOM_SLIDE_SCOPE_INFINITE
			})
		for slide_direction in slide_directions:
			var normalized_slide = _normalize_direction_vector(slide_direction)
			if normalized_slide == Vector2i.ZERO:
				continue
			movement_rules.append({
				"x": normalized_slide.x,
				"y": normalized_slide.y,
				"kind": CUSTOM_MOVE_KIND_SLIDE,
				"capture_mode": CUSTOM_CAPTURE_MODE_ANY,
					"initial_only": false,
					"slide_scope": CUSTOM_SLIDE_SCOPE_INFINITE
			})

	if not movement_rules.is_empty():
		jump_offsets = []
		slide_directions = []
		var jump_seen = {}
		var slide_seen = {}
		for movement_rule in movement_rules:
			var movement_delta = Vector2i(int(movement_rule.get("x", 0)), int(movement_rule.get("y", 0)))
			var movement_kind = str(movement_rule.get("kind", CUSTOM_MOVE_KIND_JUMP))
			var slide_scope = str(movement_rule.get("slide_scope", CUSTOM_SLIDE_SCOPE_INFINITE))
			if movement_kind == CUSTOM_MOVE_KIND_SLIDE and slide_scope == CUSTOM_SLIDE_SCOPE_INFINITE:
				var slide_key = "%d:%d" % [movement_delta.x, movement_delta.y]
				if not slide_seen.has(slide_key):
					slide_seen[slide_key] = true
					slide_directions.append(movement_delta)
			else:
				var jump_key = "%d:%d" % [movement_delta.x, movement_delta.y]
				if not jump_seen.has(jump_key):
					jump_seen[jump_key] = true
					jump_offsets.append(movement_delta)

	if jump_offsets.is_empty() and slide_directions.is_empty() and movement_rules.is_empty():
		return {}
	if path_strokes.is_empty() and icon_path == "":
		return {}

	return {
		"id": piece_id,
		"name": piece_name,
		"symbol": piece_symbol,
		"move_type": "custom",
		"strength": piece_strength,
		"icon_path": icon_path,
		"path_strokes": path_strokes,
		"path_stroke_width": path_stroke_width,
		"movement_rules": movement_rules,
		"jump_offsets": _serialize_vector2i_array(jump_offsets),
		"slide_directions": _serialize_vector2i_array(slide_directions)
	}

func _normalize_custom_path_strokes(source_strokes: Variant) -> Array:
	var normalized: Array = []
	if not (source_strokes is Array):
		return normalized

	for raw_stroke in source_strokes:
		if not (raw_stroke is Array):
			continue
		var stroke_points: Array = []
		for raw_point in raw_stroke:
			var parsed = _parse_normalized_path_point(raw_point)
			if parsed == null:
				continue
			stroke_points.append(parsed)
		if stroke_points.size() >= 2:
			normalized.append(stroke_points)

	return normalized

func _parse_normalized_path_point(value: Variant) -> Variant:
	if value is Dictionary:
		return {
			"x": clampf(float(value.get("x", 0.0)), 0.0, 1.0),
			"y": clampf(float(value.get("y", 0.0)), 0.0, 1.0)
		}
	if value is Array and value.size() >= 2:
		return {
			"x": clampf(float(value[0]), 0.0, 1.0),
			"y": clampf(float(value[1]), 0.0, 1.0)
		}
	if value is Vector2:
		var point: Vector2 = value
		return {
			"x": clampf(point.x, 0.0, 1.0),
			"y": clampf(point.y, 0.0, 1.0)
		}
	return null

func _normalize_custom_movement_rules(source_rules: Variant) -> Array:
	var normalized_rules: Array = []
	if not (source_rules is Array):
		return normalized_rules

	var seen_keys = {}
	for raw_rule in source_rules:
		if not (raw_rule is Dictionary):
			continue

		var delta = _parse_vector2i_data(raw_rule)
		if delta == Vector2i.ZERO and raw_rule.has("offset"):
			delta = _parse_vector2i_data(raw_rule.get("offset"))
		if delta == Vector2i.ZERO:
			continue

		var move_kind = str(raw_rule.get("kind", CUSTOM_MOVE_KIND_JUMP)).to_lower()
		if move_kind != CUSTOM_MOVE_KIND_SLIDE:
			move_kind = CUSTOM_MOVE_KIND_JUMP

		var slide_scope = _normalize_custom_slide_scope(raw_rule.get("slide_scope", CUSTOM_SLIDE_SCOPE_INFINITE))
		if move_kind != CUSTOM_MOVE_KIND_SLIDE:
			slide_scope = CUSTOM_SLIDE_SCOPE_INFINITE

		if move_kind == CUSTOM_MOVE_KIND_SLIDE and slide_scope == CUSTOM_SLIDE_SCOPE_INFINITE:
			delta = _normalize_direction_vector(delta)
			if delta == Vector2i.ZERO:
				continue

		var capture_mode = _normalize_custom_capture_mode(raw_rule.get("capture_mode", CUSTOM_CAPTURE_MODE_ANY))
		var initial_only = bool(raw_rule.get("initial_only", false))

		var rule_key = "%s|%d|%d|%s|%d|%s" % [move_kind, delta.x, delta.y, capture_mode, int(initial_only), slide_scope]
		if seen_keys.has(rule_key):
			continue
		seen_keys[rule_key] = true
		normalized_rules.append({
			"x": delta.x,
			"y": delta.y,
			"kind": move_kind,
			"capture_mode": capture_mode,
			"initial_only": initial_only,
			"slide_scope": slide_scope
		})

	return normalized_rules

func _normalize_custom_capture_mode(value: Variant) -> String:
	var capture_mode = str(value).to_lower().strip_edges()
	if capture_mode == CUSTOM_CAPTURE_MODE_NON_CAPTURE:
		return CUSTOM_CAPTURE_MODE_NON_CAPTURE
	if capture_mode == CUSTOM_CAPTURE_MODE_CAPTURE_ONLY:
		return CUSTOM_CAPTURE_MODE_CAPTURE_ONLY
	return CUSTOM_CAPTURE_MODE_ANY

func _normalize_custom_slide_scope(value: Variant) -> String:
	var slide_scope = str(value).to_lower().strip_edges()
	if slide_scope == CUSTOM_SLIDE_SCOPE_HALTING:
		return CUSTOM_SLIDE_SCOPE_HALTING
	return CUSTOM_SLIDE_SCOPE_INFINITE

func _normalize_direction_vector(delta: Vector2i) -> Vector2i:
	var gcd_value = _gcd(abs(delta.x), abs(delta.y))
	if gcd_value <= 0:
		return Vector2i.ZERO
	return Vector2i(int(delta.x / gcd_value), int(delta.y / gcd_value))

func _gcd(a: int, b: int) -> int:
	var x = abs(a)
	var y = abs(b)
	while y != 0:
		var remainder = x % y
		x = y
		y = remainder
	return max(x, 1)

func _parse_vector2i_data(value: Variant) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Dictionary:
		return Vector2i(int(value.get("x", 0)), int(value.get("y", 0)))
	if value is Array and value.size() >= 2:
		return Vector2i(int(value[0]), int(value[1]))
	return Vector2i.ZERO

func _serialize_vector2i_array(values: Array) -> Array:
	var serialized: Array = []
	for value in values:
		var vector_value: Vector2i = value
		serialized.append({"x": vector_value.x, "y": vector_value.y})
	return serialized

func _rebuild_piece_catalog_with_custom_pieces() -> void:
	PieceBank = _base_piece_bank.duplicate(true)
	PieceDefinitions = _base_piece_definitions.duplicate(true)

	var custom_piece_ids = CustomPieces.keys()
	custom_piece_ids.sort()
	for custom_piece_id in custom_piece_ids:
		var custom_piece_data: Dictionary = CustomPieces[custom_piece_id]
		if custom_piece_data.is_empty():
			continue
		var piece_id = str(custom_piece_data.get("id", custom_piece_id))
		if not PieceBank.has(piece_id):
			PieceBank.append(piece_id)
		PieceDefinitions[piece_id] = custom_piece_data.duplicate(true)

func get_custom_pieces() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var custom_piece_ids = CustomPieces.keys()
	custom_piece_ids.sort()
	for custom_piece_id in custom_piece_ids:
		var custom_piece_data: Dictionary = CustomPieces[custom_piece_id]
		entries.append(custom_piece_data.duplicate(true))
	return entries

func get_custom_piece_by_id(piece_id: String) -> Dictionary:
	var key = piece_id.strip_edges()
	if key == "" or not CustomPieces.has(key):
		return {}
	var custom_piece_data: Dictionary = CustomPieces[key]
	return custom_piece_data.duplicate(true)

func save_custom_piece(source_data: Dictionary) -> Dictionary:
	var normalized = _normalize_custom_piece_data(str(source_data.get("id", "")), source_data)
	if normalized.is_empty():
		return {"ok": false, "error": "Invalid custom piece data."}

	var custom_piece_id = str(normalized.get("id", ""))
	if _base_piece_definitions.has(custom_piece_id):
		return {"ok": false, "error": "Piece ID collides with built-in piece."}

	CustomPieces[custom_piece_id] = normalized
	_write_custom_pieces()
	_rebuild_piece_catalog_with_custom_pieces()
	PieceIconCache.clear()
	return {"ok": true, "piece_id": custom_piece_id}

func delete_custom_piece(piece_id: String) -> bool:
	if not CustomPieces.has(piece_id):
		return false
	CustomPieces.erase(piece_id)
	_write_custom_pieces()
	_rebuild_piece_catalog_with_custom_pieces()
	PieceIconCache.clear()
	return true

func save_custom_piece_icon(piece_id: String, source_file_path: String) -> String:
	var image = Image.new()
	var load_result = image.load(source_file_path)
	if load_result != OK:
		return ""

	var icon_folder = ProjectSettings.globalize_path(CUSTOM_PIECE_ICON_DIR)
	DirAccess.make_dir_recursive_absolute(icon_folder)
	var target_path = "%s/%s.png" % [CUSTOM_PIECE_ICON_DIR, piece_id]
	var save_result = image.save_png(ProjectSettings.globalize_path(target_path))
	if save_result != OK:
		return ""

	PieceIconCache.erase(target_path)
	return target_path

func get_piece_icon_texture(piece_id: String) -> Texture2D:
	if not PieceDefinitions.has(piece_id):
		return null
	var piece_definition: Dictionary = PieceDefinitions[piece_id]
	var icon_path = str(piece_definition.get("icon_path", "")).strip_edges()
	if icon_path != "":
		if PieceIconCache.has(icon_path):
			return PieceIconCache[icon_path]

		var absolute_path = ProjectSettings.globalize_path(icon_path)
		if not FileAccess.file_exists(absolute_path):
			return null

		var image = Image.new()
		var load_result = image.load(absolute_path)
		if load_result != OK:
			return null

		var texture = ImageTexture.create_from_image(image)
		PieceIconCache[icon_path] = texture
		return texture

	var path_strokes = _normalize_custom_path_strokes(piece_definition.get("path_strokes", []))
	if path_strokes.is_empty():
		return null

	var path_stroke_width = clampf(float(piece_definition.get("path_stroke_width", 0.18)), 0.05, 0.45)
	var cache_key = "path:%s:%0.3f" % [piece_id, path_stroke_width]
	if PieceIconCache.has(cache_key):
		return PieceIconCache[cache_key]

	var generated_texture = _build_path_piece_icon_texture(path_strokes, path_stroke_width)
	if generated_texture != null:
		PieceIconCache[cache_key] = generated_texture
	return generated_texture

func _build_path_piece_icon_texture(path_strokes: Array, path_stroke_width: float) -> Texture2D:
	var image = Image.create(PATH_ICON_TEXTURE_SIZE, PATH_ICON_TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	var min_pos = PATH_ICON_TEXTURE_SIZE * PATH_ICON_MARGIN_RATIO
	var max_pos = PATH_ICON_TEXTURE_SIZE * (1.0 - PATH_ICON_MARGIN_RATIO)
	var draw_span = max_pos - min_pos
	var fill_color = Color(0.95, 0.95, 0.95, 1.0)
	var outline_color = Color(0.08, 0.08, 0.08, 1.0)
	var fill_width = max(1, int(round(PATH_ICON_TEXTURE_SIZE * path_stroke_width)))
	var outline_width = fill_width + max(2, int(round(fill_width * 0.4)))

	for stroke_data in path_strokes:
		if not (stroke_data is Array):
			continue
		if stroke_data.size() < 2:
			continue

		for point_index in range(stroke_data.size() - 1):
			var a = stroke_data[point_index]
			var b = stroke_data[point_index + 1]
			if not (a is Dictionary) or not (b is Dictionary):
				continue

			var ax = clampf(float(a.get("x", 0.0)), 0.0, 1.0)
			var ay = clampf(float(a.get("y", 0.0)), 0.0, 1.0)
			var bx = clampf(float(b.get("x", 0.0)), 0.0, 1.0)
			var by = clampf(float(b.get("y", 0.0)), 0.0, 1.0)
			var from = Vector2(min_pos + ax * draw_span, min_pos + ay * draw_span)
			var to = Vector2(min_pos + bx * draw_span, min_pos + by * draw_span)

			_draw_thick_segment(image, from, to, outline_width, outline_color)
			_draw_thick_segment(image, from, to, fill_width, fill_color)

	return ImageTexture.create_from_image(image)

func _draw_thick_segment(image: Image, from: Vector2, to: Vector2, width: int, color: Color) -> void:
	var radius = max(1, int(round(float(width) * 0.5)))
	var segment_length = from.distance_to(to)
	var steps = max(int(ceil(segment_length * 2.0)), 1)
	for step in range(steps + 1):
		var t = float(step) / float(steps)
		_stamp_circle(image, from.lerp(to, t), radius, color)

func _stamp_circle(image: Image, center: Vector2, radius: int, color: Color) -> void:
	var min_x = max(0, int(floor(center.x - radius)))
	var max_x = min(image.get_width() - 1, int(ceil(center.x + radius)))
	var min_y = max(0, int(floor(center.y - radius)))
	var max_y = min(image.get_height() - 1, int(ceil(center.y + radius)))
	var radius_sq = float(radius * radius)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var dx = float(x) - center.x
			var dy = float(y) - center.y
			if dx * dx + dy * dy <= radius_sq:
				image.set_pixel(x, y, color)

func get_piece_path_strokes(piece_id: String) -> Array:
	if not PieceDefinitions.has(piece_id):
		return []
	var piece_definition: Dictionary = PieceDefinitions[piece_id]
	var normalized = _normalize_custom_path_strokes(piece_definition.get("path_strokes", []))
	return normalized.duplicate(true)

func get_piece_path_stroke_width(piece_id: String) -> float:
	if not PieceDefinitions.has(piece_id):
		return 0.18
	var piece_definition: Dictionary = PieceDefinitions[piece_id]
	return clampf(float(piece_definition.get("path_stroke_width", 0.18)), 0.05, 0.45)

func get_piece_strength(piece_id: String, include_king: bool = false) -> int:
	if PieceDefinitions.has(piece_id):
		var piece_definition: Dictionary = PieceDefinitions[piece_id]
		if piece_definition.has("strength"):
			return max(int(piece_definition.get("strength", 1)), 1)
	match piece_id:
		"pawn", "shogi_pawn":
			return 1
		"knight", "bishop", "shogi_knight", "silver_general", "gold_general", "lance":
			return 3
		"rook":
			return 5
		"queen":
			return 8
		"king":
			return 2 if include_king else 0
		_:
			return 0
