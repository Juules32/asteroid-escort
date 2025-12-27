extends Node

var _window_y_offset: int = 30
var _primary_screen_id: int = DisplayServer.get_primary_screen()
var _primary_screen_usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(_primary_screen_id)
var _primary_screen_size: Vector2i = _primary_screen_usable_rect.size
var _primary_screen_position: Vector2i = \
	_primary_screen_usable_rect.position + Vector2i(0, _window_y_offset)
var _primary_screen_half_size: Vector2i = \
	Vector2i(int(_primary_screen_size.x / 2.0), _primary_screen_size.y - _window_y_offset)
var _window_size: Vector2i = \
	Vector2i(int(_primary_screen_size.x * 0.5), int(_primary_screen_size.x * 0.5 * 0.5625))

var move_goal: bool = false

func _ready() -> void:
	if not OS.is_debug_build():
		return
	
	for arg in OS.get_cmdline_args():
		match arg:
			"--debug-play":
				_initiate_debug.call_deferred()
			"--debug-host":
				_position_window_left()
				_initiate_debug_host.call_deferred()
				get_window().title = "Server"
			"--debug-join":
				_position_window_right()
				_initiate_debug_client.call_deferred()
				get_window().title = "Client"
			"--move-goal":
				move_goal = true


func _initiate_debug() -> void:
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return
	
	multiplayer_session_manager.use_iroh = false
	multiplayer_session_manager.create_game()
	multiplayer_session_manager.multicast_start_game()


func _initiate_debug_host() -> void:
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return
	
	multiplayer_session_manager.use_iroh = false
	multiplayer_session_manager.create_game()
	multiplayer_session_manager.player_connected.connect(_handle_player_connected)


func _initiate_debug_client() -> void:
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return
	
	multiplayer_session_manager.use_iroh = false
	multiplayer_session_manager.join_game("local")


func _handle_player_connected(_peer_id: int, _player_info: Dictionary) -> void:
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return
	
	multiplayer_session_manager.multicast_start_game()


func _position_window_left() -> void:
	DisplayServer.window_set_position(_primary_screen_position)
	DisplayServer.window_set_size(_window_size)


func _position_window_right() -> void:
	DisplayServer.window_set_position(
		_primary_screen_position + Vector2i(_primary_screen_half_size.x, 0)
	)
	DisplayServer.window_set_size(_window_size)
