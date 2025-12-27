extends Node
# Script taken from Godot docs and expanded on
# Autoload named MultiplayerSessionManager

@export var lobby_menu_uid: String = "uid://s83k00doh1bm"
@export var use_iroh: bool = true
#@export var game_scene_uid: String = "uid://bgru7ribg64w0" #Test_level
@export var game_scene_uid: String = "uid://b2tsepvy3qgpj" #Level_1

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT: int = 7000
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players: Dictionary = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info: Dictionary = {}

var players_loaded: int = 0

var lobby_id: String

@onready var debug_session_manager: Node = $DebugSessionManager

func _ready() -> void:
	player_info.get_or_add("name", generate_guest_name())
	player_info.get_or_add("color_index", 0)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	if lobby_menu_uid == "":
		push_warning("No lobby menu uid for the multiplayer session manager")


func generate_guest_name() -> String:
	var random_number = randi() % 100000
	return "Guest_%05d" % random_number


func random_color() -> Color:
	return Color(randf(), randf(), randf())


func join_game(address: String = "") -> Error:
	#if use_iroh:
		#var iroh_node: Node = get_node("GodotIrohManager")
		#iroh_node.join_server(address)
	#else:
		#address = DEFAULT_SERVER_IP
		#var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
		#var error: Error = peer.create_client(address, PORT)
		#if error:
			#return error
		#multiplayer.multiplayer_peer = peer		
	
	lobby_id = address
	get_tree().change_scene_to_file(lobby_menu_uid)
	return Error.OK


func create_game() -> Error:
	#if use_iroh:
		#var iroh_node: Node = get_node("GodotIrohManager")
		#lobby_id = iroh_node.host_game() 
	#else:
		#var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
		#var error: Error = peer.create_server(PORT, MAX_CONNECTIONS)
		#if error:
			#return error
		#multiplayer.multiplayer_peer = peer
		#lobby_id = "local"
	
	get_tree().change_scene_to_file(lobby_menu_uid)
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	return Error.OK


func remove_multiplayer_peer() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("any_peer", "call_local", "reliable")
func multicast_start_game() -> void:
	if game_scene_uid == "":
		push_warning("multiplayer_session_manager has no game_scene_uid")
		return
	get_tree().change_scene_to_file(game_scene_uid)
	get_tree().paused = false


# Restart the game by loading the scene again
@rpc("any_peer", "call_local", "reliable")
func multicast_restart_game() -> void:
	if game_scene_uid == "":
		push_warning("multiplayer_session_manager has no game_scene_uid")
		return
	get_tree().change_scene_to_file(game_scene_uid)
	get_tree().paused = false


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded() -> void:
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			get_tree().current_scene.start_game()
			players_loaded = 0


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id: int) -> void:
	_register_player(player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary) -> void:
	var new_player_id: int = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id: int) -> void:
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok() -> void:
	var peer_id: int = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail() -> void:
	remove_multiplayer_peer()


func _on_server_disconnected() -> void:
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()


func find_current_player_node() -> PlayerShip:
	for player: PlayerShip in get_tree().get_nodes_in_group("player"):
		if player.owner_id == multiplayer.get_unique_id():
			return player
	return null


func find_current_player_controller() -> Controller:
	var player = MultiplayerSessionManager.find_current_player_node()
	if player:
		return player.controller	
	return null
