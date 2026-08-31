extends Node


var BoardHeight;
var BoardWidth;
var StartingPieces = []
var PieceBank = ["pawn", "knight", "bishop", "rook", "queen", "king"]
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
	}
}
