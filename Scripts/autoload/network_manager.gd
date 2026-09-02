extends Node

signal network_status_changed(status: String, message: String)
signal peer_ready_changed(is_ready: bool)
signal online_match_started()
signal turn_state_received(state: Dictionary)
signal online_match_ended(reason: String)
signal setup_snapshot_received(snapshot: Dictionary)

const DEFAULT_PORT = 24567

var is_hosting = false
var is_online_match_active = false
var local_player_side = "white"
var remote_peer_id = 0

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(port: int = DEFAULT_PORT) -> bool:
	leave_session()
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port, 1)
	if result != OK:
		emit_signal("network_status_changed", "error", "Host failed on port %d (error %d)." % [port, result])
		return false
	multiplayer.multiplayer_peer = peer
	is_hosting = true
	is_online_match_active = false
	local_player_side = "white"
	remote_peer_id = 0
	emit_signal("network_status_changed", "hosting", "Hosting on port %d. Waiting for player 2..." % port)
	emit_signal("peer_ready_changed", false)
	return true

func join_game(address: String, port: int = DEFAULT_PORT) -> bool:
	leave_session()
	var host_address = address.strip_edges()
	if host_address == "":
		emit_signal("network_status_changed", "error", "Host address is required.")
		return false
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(host_address, port)
	if result != OK:
		emit_signal("network_status_changed", "error", "Join failed for %s:%d (error %d)." % [host_address, port, result])
		return false
	multiplayer.multiplayer_peer = peer
	is_hosting = false
	is_online_match_active = false
	local_player_side = "black"
	remote_peer_id = 1
	emit_signal("network_status_changed", "joining", "Connecting to %s:%d..." % [host_address, port])
	emit_signal("peer_ready_changed", false)
	return true

func leave_session() -> void:
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	is_hosting = false
	is_online_match_active = false
	local_player_side = "white"
	remote_peer_id = 0
	emit_signal("peer_ready_changed", false)

func can_start_hosted_match() -> bool:
	return is_hosting and remote_peer_id != 0 and multiplayer.multiplayer_peer != null

func start_hosted_match() -> bool:
	if not can_start_hosted_match():
		emit_signal("network_status_changed", "error", "A second player must be connected before starting.")
		return false
	var config = _build_match_config_from_game_manager()
	_rpc_start_online_match.rpc_id(remote_peer_id, config)
	_apply_match_config_to_game_manager(config)
	is_online_match_active = true
	local_player_side = "white"
	emit_signal("online_match_started")
	emit_signal("network_status_changed", "started", "Online match started.")
	return true

func submit_turn_state(state: Dictionary) -> void:
	if not is_online_match_active:
		return
	if multiplayer.multiplayer_peer == null:
		return
	if is_hosting:
		if remote_peer_id != 0:
			_rpc_receive_host_turn_state.rpc_id(remote_peer_id, state)
		return
	_rpc_submit_turn_state_from_client.rpc_id(1, state)

func is_session_connected() -> bool:
	return multiplayer.multiplayer_peer != null

func is_online_active() -> bool:
	return is_online_match_active

func get_local_player_side() -> String:
	return local_player_side

func _on_peer_connected(peer_id: int) -> void:
	if not is_hosting:
		return
	remote_peer_id = peer_id
	emit_signal("network_status_changed", "peer_connected", "Player 2 connected.")
	emit_signal("peer_ready_changed", true)
	_rpc_open_online_setup_menu.rpc_id(peer_id)
	var setup_snapshot = _build_match_config_from_game_manager()
	_rpc_receive_setup_snapshot.rpc_id(peer_id, setup_snapshot)

func _on_peer_disconnected(peer_id: int) -> void:
	if is_hosting and remote_peer_id == peer_id:
		remote_peer_id = 0
	emit_signal("network_status_changed", "peer_disconnected", "The other player disconnected.")
	if is_online_match_active:
		is_online_match_active = false
		emit_signal("online_match_ended", "Opponent disconnected.")
	emit_signal("peer_ready_changed", false)

func _on_connected_to_server() -> void:
	emit_signal("network_status_changed", "connected", "Connected. Waiting for host to start the match...")
	emit_signal("peer_ready_changed", true)
	get_tree().change_scene_to_file("res://Scenes/LocalGameMenu.tscn")

func _on_connection_failed() -> void:
	emit_signal("network_status_changed", "error", "Connection failed.")
	leave_session()

func _on_server_disconnected() -> void:
	emit_signal("network_status_changed", "peer_disconnected", "Disconnected from host.")
	if is_online_match_active:
		is_online_match_active = false
		emit_signal("online_match_ended", "Disconnected from host.")
	leave_session()

@rpc("authority", "reliable")
func _rpc_start_online_match(config: Dictionary) -> void:
	_apply_match_config_to_game_manager(config)
	is_online_match_active = true
	local_player_side = "black"
	emit_signal("online_match_started")
	emit_signal("network_status_changed", "started", "Online match started.")
	get_tree().change_scene_to_file("res://Scenes/LocalGame.tscn")

@rpc("authority", "reliable")
func _rpc_open_online_setup_menu() -> void:
	if is_online_match_active:
		return
	if get_tree().current_scene != null and get_tree().current_scene.scene_file_path == "res://Scenes/LocalGameMenu.tscn":
		return
	get_tree().change_scene_to_file("res://Scenes/LocalGameMenu.tscn")

func submit_setup_snapshot(snapshot: Dictionary) -> void:
	if is_online_match_active:
		return
	if multiplayer.multiplayer_peer == null:
		return
	if is_hosting:
		_apply_match_config_to_game_manager(snapshot)
		emit_signal("setup_snapshot_received", snapshot)
		if remote_peer_id != 0:
			_rpc_receive_setup_snapshot.rpc_id(remote_peer_id, snapshot)
		return
	_rpc_submit_setup_snapshot_from_client.rpc_id(1, snapshot)

@rpc("any_peer", "reliable")
func _rpc_submit_setup_snapshot_from_client(snapshot: Dictionary) -> void:
	if not is_hosting:
		return
	if multiplayer.get_remote_sender_id() != remote_peer_id:
		return
	_apply_match_config_to_game_manager(snapshot)
	emit_signal("setup_snapshot_received", snapshot)
	_rpc_receive_setup_snapshot.rpc_id(remote_peer_id, snapshot)

@rpc("authority", "reliable")
func _rpc_receive_setup_snapshot(snapshot: Dictionary) -> void:
	if is_online_match_active:
		return
	_apply_match_config_to_game_manager(snapshot)
	emit_signal("setup_snapshot_received", snapshot)

@rpc("any_peer", "reliable")
func _rpc_submit_turn_state_from_client(state: Dictionary) -> void:
	if not is_hosting:
		return
	if multiplayer.get_remote_sender_id() != remote_peer_id:
		return
	emit_signal("turn_state_received", state)

@rpc("any_peer", "reliable")
func _rpc_receive_host_turn_state(state: Dictionary) -> void:
	if is_hosting:
		return
	emit_signal("turn_state_received", state)

func _build_match_config_from_game_manager() -> Dictionary:
	var game_manager = $"/root/GameManager"
	return {
		"board_height": int(game_manager.BoardHeight),
		"board_width": int(game_manager.BoardWidth),
		"starting_pieces": game_manager.StartingPieces.duplicate(true),
		"starting_drop_pools": game_manager.StartingDropPools.duplicate(true),
		"special_rules": game_manager.SpecialRules.duplicate(true),
		"spell_card_hand_size": int(game_manager.SpellCardHandSize),
		"spell_card_hand_size_white": int(game_manager.SpellCardHandSizeWhite),
		"spell_card_hand_size_black": int(game_manager.SpellCardHandSizeBlack),
		"spell_cards_random": bool(game_manager.SpellCardsRandom),
		"spell_card_allow_duplicates": bool(game_manager.SpellCardAllowDuplicates),
		"spell_draw_replacement_after_cast": bool(game_manager.SpellCardDrawReplacementAfterCast),
		"spell_card_available_ids": game_manager.SpellCardAvailableIds.duplicate(true),
		"starting_spell_hands": game_manager.StartingSpellHands.duplicate(true),
		"promotion_piece_pool": game_manager.PromotionPiecePool.duplicate(true),
		"promotion_zones": game_manager.PromotionZones.duplicate(true),
		"territory_rows": int(game_manager.TerritoryRows),
		"victory_condition": str(game_manager.VictoryCondition),
		"army_strength_cap": int(game_manager.ArmyStrengthCap),
		"army_strength_cap_white": int(game_manager.ArmyStrengthCapWhite),
		"army_strength_cap_black": int(game_manager.ArmyStrengthCapBlack),
		"player_colors": game_manager.PlayerColors.duplicate(true),
		"tile_colors": game_manager.TileColors.duplicate(true),
		"piece_bank": game_manager.PieceBank.duplicate(true),
		"piece_definitions": game_manager.PieceDefinitions.duplicate(true)
	}

func _apply_match_config_to_game_manager(config: Dictionary) -> void:
	var game_manager = $"/root/GameManager"
	game_manager.BoardHeight = int(config.get("board_height", game_manager.BoardHeight))
	game_manager.BoardWidth = int(config.get("board_width", game_manager.BoardWidth))
	game_manager.StartingPieces = config.get("starting_pieces", game_manager.StartingPieces).duplicate(true)
	game_manager.StartingDropPools = config.get("starting_drop_pools", game_manager.StartingDropPools).duplicate(true)
	game_manager.SpecialRules = config.get("special_rules", game_manager.SpecialRules).duplicate(true)
	game_manager.SpellCardHandSize = int(config.get("spell_card_hand_size", game_manager.SpellCardHandSize))
	game_manager.SpellCardHandSizeWhite = int(config.get("spell_card_hand_size_white", game_manager.SpellCardHandSizeWhite))
	game_manager.SpellCardHandSizeBlack = int(config.get("spell_card_hand_size_black", game_manager.SpellCardHandSizeBlack))
	game_manager.SpellCardsRandom = bool(config.get("spell_cards_random", game_manager.SpellCardsRandom))
	game_manager.SpellCardAllowDuplicates = bool(config.get("spell_card_allow_duplicates", game_manager.SpellCardAllowDuplicates))
	game_manager.SpellCardDrawReplacementAfterCast = bool(config.get("spell_draw_replacement_after_cast", game_manager.SpellCardDrawReplacementAfterCast))
	game_manager.SpellCardAvailableIds = game_manager.normalize_spell_card_ids(config.get("spell_card_available_ids", game_manager.SpellCardAvailableIds))
	game_manager.StartingSpellHands = game_manager.normalize_spell_card_hands(config.get("starting_spell_hands", game_manager.StartingSpellHands))
	game_manager.PromotionPiecePool = config.get("promotion_piece_pool", game_manager.PromotionPiecePool).duplicate(true)
	game_manager.PromotionZones = config.get("promotion_zones", game_manager.PromotionZones).duplicate(true)
	game_manager.TerritoryRows = int(config.get("territory_rows", game_manager.TerritoryRows))
	game_manager.VictoryCondition = str(config.get("victory_condition", game_manager.VictoryCondition))
	game_manager.ArmyStrengthCap = int(config.get("army_strength_cap", game_manager.ArmyStrengthCap))
	game_manager.ArmyStrengthCapWhite = int(config.get("army_strength_cap_white", game_manager.ArmyStrengthCapWhite))
	game_manager.ArmyStrengthCapBlack = int(config.get("army_strength_cap_black", game_manager.ArmyStrengthCapBlack))
	game_manager.PlayerColors = config.get("player_colors", game_manager.PlayerColors).duplicate(true)
	game_manager.TileColors = config.get("tile_colors", game_manager.TileColors).duplicate(true)
	if config.has("piece_bank"):
		game_manager.PieceBank = config.get("piece_bank", game_manager.PieceBank).duplicate(true)
	if config.has("piece_definitions"):
		game_manager.PieceDefinitions = config.get("piece_definitions", game_manager.PieceDefinitions).duplicate(true)
