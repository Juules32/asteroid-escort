extends Control
class_name MultiplayerMainMenu

@onready var popup_container: MarginContainer = get_node("MContainer/VBox/HBox/PopupMContainer")
@onready var lobby_id_line_edit: LineEdit = get_node("MContainer/VBox/HBox/VBox/PContainer/MContainer/ButtonsVBox/LobbyIdLineEdit")
@onready var player_sprites: Node2D = get_node("MContainer/VBox/HBox/VBox/ShipPContainer/MContainer/HBox/CenterContainer/PlayerSprites")
@onready var option_button: OptionButton = get_node("MContainer/VBox/HBox/VBox/ShipPContainer/MContainer/HBox/OptionButton")

func _ready() -> void:
	initialize_color_options()
	if OS.get_name() == "Web":
		get_node("MContainer/VBox/HBox/VBox/PContainer/MContainer/ButtonsVBox/QuitButton").visible = false;
	reset_player_name_display()


func initialize_color_options() -> void:
	var option_count: int = len(player_sprites.color_presets)
	for i in range(option_count):
		option_button.add_item(str(i + 1), i)
	_on_option_button_item_selected(0)


func set_new_popup_menu(popup_menu: Node) -> void:
	for child: Node in popup_container.get_children():
		child.queue_free()
	popup_container.add_child(popup_menu)


func _on_button_pressed() -> void:
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return
	multiplayer_session_manager.create_game()
	multiplayer_session_manager.multicast_start_game()


func _on_host_button_pressed() -> void:
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return
	multiplayer_session_manager.create_game()


func _on_join_button_pressed() -> void:
	if lobby_id_line_edit.text == "":
		lobby_id_line_edit.grab_focus()
		return
	
	var multiplayer_session_manager: Node = get_tree().root.get_node_or_null("MultiplayerSessionManager")
	if multiplayer_session_manager == null:
		push_warning("No multiplayer session manager found in root, has it been added as an Autoload?")
		return
	multiplayer_session_manager.join_game(lobby_id_line_edit.text)


func _on_how_button_pressed() -> void:
	var how_to_play_menu: Node = preload("res://gui/main_menu/how_to_play_menu.tscn").instantiate()
	set_new_popup_menu(how_to_play_menu)


func _on_settings_button_pressed() -> void:
	var settings_menu: Node = preload("res://gui/main_menu/settings_menu.tscn").instantiate()
	set_new_popup_menu(settings_menu)


func _on_credits_button_pressed() -> void:
	var credits_menu: Node = preload("uid://bgniiark1tsyv").instantiate()
	set_new_popup_menu(credits_menu)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_player_name_line_edit_text_submitted(new_text: String) -> void:
	if _is_name_valid(new_text):
		MultiplayerSessionManager.player_info["name"] = new_text
	else:
		reset_player_name_display()


func _is_name_valid(player_name: String) -> bool:
	return len(player_name) > 0


func _on_player_name_line_edit_focus_exited() -> void:
	reset_player_name_display()


func reset_player_name_display() -> void:
	var player_name_line_edit: LineEdit = get_node("MContainer/VBox/HBox/VBox/PContainer/MContainer/ButtonsVBox/PlayerNameLineEdit")
	player_name_line_edit.text = MultiplayerSessionManager.player_info["name"]


func _on_option_button_item_selected(index: int) -> void:
	if is_multiplayer_authority():
		MultiplayerSessionManager.player_info["color_index"] = index
	option_button.selected = index
	player_sprites.set_color_preset(index)
	option_button.release_focus()
