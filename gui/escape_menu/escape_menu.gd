extends CanvasLayer

var preloaded_settings_menu = preload("uid://d4d6plpwkqsrn")
var preloaded_how_menu = preload("uid://clacrkcllp1rb")
var preloaded_main_menu = preload("uid://baptqkmsj4gtb")
var popup_container: MarginContainer = null


func _ready() -> void:
	popup_container = get_node("PopupContainer")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # Escape is usually mapped to ui_cancel
		if popup_container.get_child_count() <= 0:
			visible = !visible
			set_new_popup_menu(null)
		else:
			set_new_popup_menu(null)


func _on_resume_button_pressed() -> void:
	visible = !visible


func _on_restart_button_pressed() -> void:
	MultiplayerSessionManager.multicast_restart_game()


func _on_how_button_pressed() -> void:
	set_new_popup_menu(preloaded_how_menu.instantiate())


func _on_settings_button_pressed() -> void:
	set_new_popup_menu(preloaded_settings_menu.instantiate())


func set_new_popup_menu(popup_menu: Node) -> void:
	for child in popup_container.get_children():
		child.queue_free()
	if popup_menu:
		popup_container.add_child(popup_menu)


func _on_quit_button_pressed() -> void:
	MultiplayerSessionManager.remove_multiplayer_peer()
	get_tree().change_scene_to_packed(preloaded_main_menu)
