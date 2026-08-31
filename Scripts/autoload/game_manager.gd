extends Node

const PRESET_SAVE_PATH = "user://saved_presets.json"

var BoardHeight;
var BoardWidth;
var StartingPieces = []
var SpecialRules = {
	"castling": true,
	"en_passant": true,
	"promotion": true,
	"piece_dropping": false,
	"capture_to_drop_pool": false
}
var PromotionPiecePool = ["queen", "rook", "bishop", "knight"]
var VictoryCondition = "checkmate"
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

func _ready() -> void:
	_load_saved_presets()

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
