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

var BoardHeight;
var BoardWidth;
var StartingPieces = []
var SpecialRules = {
	"castling": true,
	"en_passant": true,
	"promotion": true,
	"piece_dropping": false,
	"capture_to_drop_pool": false,
	"limit_army_strength": false,
	"unbalanced_armies": false
}
var PromotionPiecePool = ["queen", "rook", "bishop", "knight"]
var VictoryCondition = "checkmate"
var ArmyStrengthCap = 32
var ArmyStrengthCapWhite = 32
var ArmyStrengthCapBlack = 32
var StartingDropPools = {
	"white": [],
	"black": []
}
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
		"move_type": "pawn"
	},
	"knight": {
		"name": "Knight",
		"symbol": "N",
		"move_type": "knight_jump"
	},
	"bishop": {
		"name": "Bishop",
		"symbol": "B",
		"move_type": "diagonal_slide"
	},
	"rook": {
		"name": "Rook",
		"symbol": "R",
		"move_type": "cardinal_slide"
	},
	"queen": {
		"name": "Queen",
		"symbol": "Q",
		"move_type": "omni_slide"
	},
	"king": {
		"name": "King",
		"symbol": "K",
		"move_type": "king_step"
	},
	"shogi_pawn": {
		"name": "Shogi Pawn",
		"symbol": "歩",
		"move_type": "shogi_pawn"
	},
	"lance": {
		"name": "Lance",
		"symbol": "香",
		"move_type": "lance_forward_slide"
	},
	"shogi_knight": {
		"name": "Shogi Knight",
		"symbol": "桂",
		"move_type": "shogi_knight_jump"
	},
	"silver_general": {
		"name": "Silver General",
		"symbol": "銀",
		"move_type": "silver_general_step"
	},
	"gold_general": {
		"name": "Gold General",
		"symbol": "金",
		"move_type": "gold_general_step"
	}
}
var _base_piece_definitions = {}
var CustomPieces = {}
var PieceIconCache = {}

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

	return {
		"id": piece_id,
		"name": piece_name,
		"symbol": piece_symbol,
		"move_type": "custom",
		"strength": piece_strength,
		"icon_path": icon_path,
		"movement_rules": movement_rules,
		"jump_offsets": _serialize_vector2i_array(jump_offsets),
		"slide_directions": _serialize_vector2i_array(slide_directions)
	}

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
	if icon_path == "":
		return null
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
