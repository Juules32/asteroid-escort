extends PanelContainer

var pages_tab_container: Node = null
var forward_button: Node = null
var backward_button: Node = null
var index_label: Node = null


func _ready() -> void:
	pages_tab_container = get_node("MContainer/VBox/HBox/TabContainer")
	forward_button = get_node("MContainer/VBox/HBox/ForwardButton")
	backward_button = get_node("MContainer/VBox/HBox/BackButton")
	index_label = get_node("MContainer/VBox/IndexLabel")
	manage_page_state()


func _on_back_button_pressed() -> void:
	pages_tab_container.current_tab -= 1
	manage_page_state()


func _on_forward_button_pressed() -> void:
	pages_tab_container.current_tab += 1
	manage_page_state()


func manage_page_state() -> void:
	var tab_index: int = pages_tab_container.current_tab
	var tabs_count: int = pages_tab_container.get_child_count()
	index_label.text = str(tab_index + 1) + "/" + str(tabs_count)
	if tabs_count == 1 or tab_index == -1:
		backward_button.disabled = true
		forward_button.disabled = true
	elif tab_index == 0:
		backward_button.disabled = true
		forward_button.disabled = false
	elif tabs_count - 1 == tab_index:
		backward_button.disabled = false
		forward_button.disabled = true
	else:
		backward_button.disabled = false
		forward_button.disabled = false


func _on_exit_button_pressed() -> void:
	queue_free()
