extends Control

@export var player_data_element: PackedScene
@export var main_menu: PackedScene

@onready var player_vbox: VBoxContainer = get_node("MContainer/HBox/PlayersVBox")
@onready var id_lineedit: LineEdit = get_node("MContainer/HBox/ButtonsVBox/IdLineEdit")


func _ready() -> void:
	print("lobby menu _ready")
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return

	multiplayer_session_manager.player_connected.connect(_handle_player_connected)
	multiplayer_session_manager.player_disconnected.connect(_handle_player_disconnected)
	multiplayer_session_manager.server_disconnected.connect(_handle_server_disconnected)
	
	if (multiplayer.is_server()):
		_handle_player_connected(1, multiplayer_session_manager.player_info)
	else:
		var start_button: Button = get_node("MContainer/HBox/ButtonsVBox/StartButton")
		start_button.disabled = true
	
	id_lineedit.text = multiplayer_session_manager.lobby_id


func _handle_player_connected(peer_id: int, player_info: Dictionary) -> void:
	if multiplayer and multiplayer.is_server():
		var data = {
			"peer_id": peer_id,
			"name": player_info["name"],
			"color_index": player_info["color_index"]
		}
		var spawner: MultiplayerSpawner = get_node("PlayerDataElementSpawner")
		spawner.spawn(data)
		for child: Control in player_vbox.get_children():
			if child.get_multiplayer_authority() != get_tree().get_multiplayer().get_unique_id():
				pass #child.rpc_id(child.get_multiplayer_authority(), "resend_replication")


func _handle_player_disconnected(peer_id: int) -> void:
	for child: Control in player_vbox.get_children():
		if child.get_multiplayer_authority() == peer_id:
			child.queue_free()
			break


func _handle_server_disconnected() -> void:
	get_tree().change_scene_to_packed(main_menu)


func _on_start_button_pressed() -> void:
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return
	
	#rpc("initate_start_game")
	multiplayer_session_manager.multicast_start_game()


@rpc("any_peer", "call_local", "reliable")
func initate_start_game() -> void:
	# TODO: Properly stop sync on / delete these before transition into game
	var spawner: MultiplayerSpawner = get_node("PlayerDataElementSpawner")
	spawner.clear_spawnable_scenes()


func _on_leave_button_pressed() -> void:
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
	else:
		multiplayer_session_manager.remove_multiplayer_peer()
	get_tree().change_scene_to_packed(main_menu)


func _on_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(id_lineedit.text)
