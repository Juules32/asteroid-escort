extends Node2D
class_name Level1

signal players_loaded

var PLAYER_SCENE_PATH: String = "res://game_world/entities/physics/player/player.tscn"
var preloaded_main_menu = preload("uid://baptqkmsj4gtb")

@onready var menu: PanelContainer = %Menu
@onready var gameover_message: Label = %GameoverMessage
@onready var timer_message: Label = %TimerMessage
@onready var speedrun_timer: SpeedrunTimer = $UserInterface/SpeedrunTimer
@onready var tutorial_gui: CanvasLayer = %TutorialGUI
@onready var offscreen_indicators: OffscreenIndicators = $OffscreenIndicators
@onready var goal: AsteroidGoal = $Goal
@onready var game_over_sfx: AudioStreamPlayer = $UserInterface/Menu/MContainer/PContainer/GameOverSFX

func _ready() -> void:
	MultiplayerSessionManager.player_loaded()
	SignalBus.level_victory.connect(_level_victory)
	SignalBus.level_lost.connect(_level_lost)
	AudioServer.set_bus_mute(2, false)

func start_game() -> void:
	players_loaded.emit()
	spawn_own_player()
	SignalBus.game_started.emit()
	if MultiplayerSessionManager.debug_session_manager.move_goal:
		goal.position = Vector2(900.0, 15.0)

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
	
	$Players.spawn_scene(PLAYER_SCENE_PATH, Vector2(0, 0), 0, data)


func _on_back_button_pressed() -> void:
	get_tree().paused = false
	menu.visible = false


func _on_restart_button_pressed() -> void:
	MultiplayerSessionManager.multicast_restart_game()

var won: bool = false
func _level_victory(message: String) -> void:
	won = true
	show_gameover_screen(message)


func _level_lost(message: String) -> void:
	won = false
	show_gameover_screen(message)


# Show the Win/Lose Screen on all clients
@rpc("any_peer", "call_local", "reliable")
func show_gameover_screen(message: String) -> void:
	if speedrun_timer.is_stopped():
		return
		
	get_tree().paused = true
	$EscapeMenu.visible = false
	
	gameover_message.text = message
	MusicManager.stop()
	get_tree().create_tween().tween_property(AudioServer.get_bus_effect(0,0), "cutoff_hz", 20500, 1)
	AudioServer.set_bus_mute(2, true)
	if not won:
		game_over_sfx.play()
	timer_message.text = "Time: " + \
		speedrun_timer.get_time()
	speedrun_timer.stop()
	menu.visible = true


func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	MultiplayerSessionManager.remove_multiplayer_peer()
	get_tree().change_scene_to_packed(preloaded_main_menu)
