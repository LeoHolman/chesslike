extends Control

@onready var status_label: Label = $CenterContainer/MenuContent/StatusPanel/StatusMargin/StatusLabel
@onready var host_address_input: LineEdit = $CenterContainer/MenuContent/ConnectionPanel/ConnectionMargin/ConnectionContent/HostAddressInput
@onready var port_spin_box: SpinBox = $CenterContainer/MenuContent/ConnectionPanel/ConnectionMargin/ConnectionContent/PortSpinBox
@onready var start_match_button: Button = $CenterContainer/MenuContent/ActionRow/StartMatchButton

func _ready() -> void:
	var network_manager = $"/root/NetworkManager"
	if network_manager == null:
		status_label.text = "Network manager missing. Check project autoload configuration."
		start_match_button.disabled = true
		return
	network_manager.network_status_changed.connect(_on_network_status_changed)
	network_manager.peer_ready_changed.connect(_on_peer_ready_changed)
	network_manager.online_match_ended.connect(_on_online_match_ended)
	host_address_input.text = "127.0.0.1"
	port_spin_box.min_value = 1024
	port_spin_box.max_value = 65535
	port_spin_box.step = 1
	port_spin_box.rounded = true
	port_spin_box.value = float(network_manager.DEFAULT_PORT)
	start_match_button.visible = false
	start_match_button.disabled = true
	status_label.text = "Host a game, or join with your friend's public IP and port."

func _exit_tree() -> void:
	var network_manager = $"/root/NetworkManager"
	if network_manager == null:
		return
	if network_manager.network_status_changed.is_connected(_on_network_status_changed):
		network_manager.network_status_changed.disconnect(_on_network_status_changed)
	if network_manager.peer_ready_changed.is_connected(_on_peer_ready_changed):
		network_manager.peer_ready_changed.disconnect(_on_peer_ready_changed)
	if network_manager.online_match_ended.is_connected(_on_online_match_ended):
		network_manager.online_match_ended.disconnect(_on_online_match_ended)

func _on_host_button_pressed() -> void:
	var port = int(round(port_spin_box.value))
	var network_manager = $"/root/NetworkManager"
	if network_manager == null:
		return
	if not network_manager.host_game(port):
		return
	status_label.text = "Hosting started. Opening game setup..."
	get_tree().change_scene_to_file("res://Scenes/LocalGameMenu.tscn")

func _on_join_button_pressed() -> void:
	var host_address = host_address_input.text.strip_edges()
	var port = int(round(port_spin_box.value))
	var network_manager = $"/root/NetworkManager"
	if network_manager != null:
		network_manager.join_game(host_address, port)

func _on_start_match_button_pressed() -> void:
	# Host now starts the online match from LocalGameMenu after configuring the board.
	pass

func _on_cancel_button_pressed() -> void:
	var network_manager = $"/root/NetworkManager"
	if network_manager != null:
		network_manager.leave_session()
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_network_status_changed(_status: String, message: String) -> void:
	status_label.text = message

func _on_peer_ready_changed(is_ready: bool) -> void:
	var network_manager = $"/root/NetworkManager"
	if network_manager == null:
		start_match_button.disabled = true
		return
	start_match_button.disabled = not network_manager.can_start_hosted_match()
	if is_ready and not network_manager.is_hosting:
		start_match_button.disabled = true

func _on_online_match_ended(reason: String) -> void:
	status_label.text = reason
