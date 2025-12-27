extends PanelContainer

var show_fps_check_box: CheckBox = null
var show_speedrun_timer: CheckBox = null
var control_scheme_option_button: OptionButton = null

var fullscreen_check_box: CheckBox = null
var vsync_check_box: CheckBox = null
var fps_cap_check_button: CheckButton = null
var fps_cap_label: Label = null
var fps_cap_line_edit: LineEdit = null
var master_volume_slider: HSlider = null
var music_volume_slider: HSlider = null
var sfx_volume_slider: HSlider = null
var valid_fps_cap_text := "60"


func _ready() -> void:
	show_fps_check_box = get_node("MContainer/VBox/TabContainer/Main/VBox/ShowFPSCheckBox")
	show_speedrun_timer = get_node("MContainer/VBox/TabContainer/Main/VBox/ShowSpeedrunTimerCheckBox")
	control_scheme_option_button = get_node("MContainer/VBox/TabContainer/Main/VBox/HBox/ControlSchemeOptionButton")
	
	fullscreen_check_box = get_node("MContainer/VBox/TabContainer/Graphics/VBox/FullscreenCheckBox")
	vsync_check_box = get_node("MContainer/VBox/TabContainer/Graphics/VBox/VSyncCheckBox")
	fps_cap_check_button = get_node("MContainer/VBox/TabContainer/Graphics/VBox/HBox/FPSCapCheckButton")
	fps_cap_label = get_node("MContainer/VBox/TabContainer/Graphics/VBox/HBox/FPSCapLabel")
	fps_cap_line_edit = get_node("MContainer/VBox/TabContainer/Graphics/VBox/HBox/FPSCapLineEdit")
	fps_cap_line_edit.text_changed.connect(_on_fps_cap_text_changed)
	fps_cap_line_edit.text_submitted.connect(_on_fps_cap_entered)
	fps_cap_line_edit.focus_exited.connect(_on_fps_cap_focus_exited)
	master_volume_slider = get_node("MContainer/VBox/TabContainer/Audio/VBox/MasterVolumeHSlider")
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	music_volume_slider = get_node("MContainer/VBox/TabContainer/Audio/VBox/MusicVolumeHSlider")
	music_volume_slider.value_changed.connect(_on_music_volume_changed)
	sfx_volume_slider = get_node("MContainer/VBox/TabContainer/Audio/VBox/SFXVolumeHSlider")
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
	initialize_settings_ui()


func _on_master_volume_changed(value: float) -> void:
	var db: float = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)

func _on_music_volume_changed(value: float) -> void:
	var db: float = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)

func _on_sfx_volume_changed(value: float) -> void:
	var db: float = linear_to_db(value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Diegetic SFX"), db)

func initialize_settings_ui() -> void:
	show_fps_check_box.button_pressed = Settings.show_fps
	show_speedrun_timer.button_pressed = Settings.show_speedrun_timer
	
	for control_scheme in Settings.ControlScemes.keys():
		control_scheme_option_button.add_item(str(control_scheme))
	control_scheme_option_button.selected = Settings.control_scheme
	
	toggle_fps_cap(Engine.max_fps != 0)
	
	master_volume_slider.max_value = 1.0 # above this becomes boosted volume
	var current_volume: float = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	master_volume_slider.value = current_volume
	
	music_volume_slider.max_value = 1.0
	current_volume = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	music_volume_slider.value = current_volume
	
	sfx_volume_slider.max_value = 1.0
	current_volume = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Diegetic SFX")))
	sfx_volume_slider.value = current_volume
	
	var window_mode := DisplayServer.window_get_mode()
	var is_fullscreen: bool = window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_check_box.button_pressed = is_fullscreen
	
	var vsync_on: bool = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	vsync_check_box.button_pressed = vsync_on


func _on_fps_cap_focus_exited() -> void:
	clamp_fps_cap()


func _on_fps_cap_entered(_new_text: String) -> void:
	clamp_fps_cap()


func clamp_fps_cap() -> void:
	var fps_cap_value: int = int(valid_fps_cap_text)
	fps_cap_value = clamp(fps_cap_value, 1, 999)
	fps_cap_line_edit.text = str(fps_cap_value)
	Engine.max_fps = fps_cap_value


func _on_fps_cap_text_changed(text: String) -> void: 
	if text.is_empty() or text.is_valid_int(): 
		valid_fps_cap_text = text
	else: 
		fps_cap_line_edit.text = valid_fps_cap_text


func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_accept_button_pressed() -> void:
	push_warning("Accepting new settings has no implementation to actually update settings")
	queue_free()


func _on_cancel_button_pressed() -> void:
	push_warning("Cancelling new settings has no implementation to actually revert settings")
	queue_free()


func _on_exit_button_pressed() -> void:
	queue_free()


func toggle_fps_cap(toggled_on: bool) -> void:
	if toggled_on:
		var fps_cap: int = 60
		if Engine.max_fps != 0:
			fps_cap = Engine.max_fps
		else:
			Engine.max_fps = fps_cap
		valid_fps_cap_text = str(fps_cap)
		fps_cap_line_edit.text = valid_fps_cap_text
		fps_cap_check_button.button_pressed = true
		fps_cap_label.visible = true
		fps_cap_line_edit.visible = true
	else:
		Engine.max_fps = 0
		fps_cap_label.visible = false
		fps_cap_line_edit.visible = false


func _on_fps_cap_check_button_toggled(toggled_on: bool) -> void:
	toggle_fps_cap(toggled_on)


func _on_v_sync_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_show_fps_check_box_toggled(toggled_on: bool) -> void:
	Settings.show_fps = toggled_on


func _on_show_speedrun_timer_check_box_toggled(toggled_on: bool) -> void:
	Settings.show_speedrun_timer = toggled_on


func _on_control_scheme_option_button_item_selected(index: int) -> void:
	Settings.control_scheme = Settings.ControlScemes.keys()[index]
