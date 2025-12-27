extends Node2D

signal players_loaded

var PLAYER_SCENE_PATH: String = "res://game_world/entities/physics/player/player.tscn"
@onready var menu: PanelContainer = $UserInterface/Menu
@onready var gameover_message: Label = $UserInterface/Menu/PContainer/MContainer/HBox/VBoxContainer/GameoverMessage
@onready var timer_message: Label = $UserInterface/Menu/PContainer/MContainer/HBox/VBoxContainer/TimerMessage
@onready var speedrun_timer: SpeedrunTimer = $UserInterface/SpeedrunTimer

func _ready() -> void:
	MultiplayerSessionManager.player_loaded()
	SignalBus.level_victory.connect(_level_victory)
	SignalBus.level_lost.connect(_level_lost)

func start_game() -> void:
	players_loaded.emit()
	spawn_own_player()
	SignalBus.game_started.emit()

@rpc("reliable", "call_local")
func spawn_own_player():
	if is_multiplayer_authority():
		_spawn_player(1, MultiplayerSessionManager.player_info["color_index"])
	else:
		_spawn_player(get_tree().get_multiplayer().get_unique_id(), MultiplayerSessionManager.player_info["color_index"])
		

@rpc("any_peer", "reliable", "call_remote")
func _spawn_player(id: int, color_index: int) -> void:
	var data: Dictionary[String, Variant] = {
		"owner_id": id,
		"color_index": color_index
	}
	
	$Players.spawn_scene(PLAYER_SCENE_PATH, Vector2(100, 100), 0, data)


func _on_back_button_pressed() -> void:
	menu.visible = false


func _on_restart_button_pressed() -> void:
	MultiplayerSessionManager.multicast_restart_game()


func _level_victory(message: String) -> void:
	show_gameover_screen(message)


func _level_lost(message: String) -> void:
	show_gameover_screen(message)
	
	
# Show the Win/Lose Screen on all clients
@rpc("any_peer", "call_local", "reliable")
func show_gameover_screen(message: String) -> void:
	gameover_message.text = message
	timer_message.text = "Time: " + \
		speedrun_timer.get_time()
	menu.visible = true
