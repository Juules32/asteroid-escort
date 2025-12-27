extends PanelContainer
class_name PlayerDataElement

@onready var ping_label: Label = get_node("MContainer/HBoxContainer/PingLabel")
var player_name: String = ""
@export var player_color_index = 0

var ping_request_start_times: Dictionary[int, int]
var ping_response_times: Array[int]
var ping_n: int = 0


func _ready() -> void:
	initialize_color_options()
	set_color(player_color_index)
	ping_response_times.resize(32)
	ping_response_times.fill(0)
	
	if not is_multiplayer_authority():
		get_node("MContainer/HBoxContainer/HBox/OptionButton").disabled = true
		#get_node("Timer").queue_free()
		return
	
	var player_name_label: Label = get_node("MContainer/HBoxContainer/PlayerNameLabel")
	player_name_label.text = player_name
	
	var peer_id_label: Label = get_node("MContainer/HBoxContainer/PeerIdLabel")
	peer_id_label.text = "Peer ID: " + str(get_multiplayer_authority())


func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	# Potential data to be shown as well
	# var waiting_packets: String = (
	# 	"Waiting packets: %s" % len(ping_request_start_times.keys())
	# )
	
	ping_label.text = (
		"Ping: %s ms  " % (get_average_ping()
		)
	)


@rpc("any_peer", "call_remote", "reliable")
func resend_replication() -> void:
	set_color(player_color_index)


func initialize_color_options() -> void:
	var option_count: int = len(get_node("MContainer/HBoxContainer/HBox/CenterContainer/PlayerSprites").color_presets)
	var option_button: OptionButton = get_node("MContainer/HBoxContainer/HBox/OptionButton")
	for i in range(option_count):
		option_button.add_item(str(i + 1), i)


@rpc("authority", "call_local", "reliable")
func set_color(index):
	if is_multiplayer_authority():
		MultiplayerSessionManager.player_info["color_index"] = index
	player_color_index = index
	var option_button: OptionButton = get_node("MContainer/HBoxContainer/HBox/OptionButton")
	option_button.selected = index
	var player_sprites: Node2D = get_node("MContainer/HBoxContainer/HBox/CenterContainer/PlayerSprites")
	player_sprites.set_color_preset(index)


func get_average_ping() -> int:
	if ping_n < 32:
		return 0
	
	var sum: int = 0
	
	for time in ping_response_times:
		sum += time
	
	return int(sum / 32.0)


@rpc("any_peer", "reliable")
func ping_request(_id: int, num: int) -> void:
	ping_response(num)


@rpc("any_peer", "reliable")
func ping_response(num: int) -> void:
	ping_response_times[num % 32] = Time.get_ticks_msec() - ping_request_start_times[num]
	ping_request_start_times.erase(num)


func _on_timer_timeout() -> void:
	if multiplayer.is_server(): return
	
	ping_request(get_tree().get_multiplayer().get_unique_id(), ping_n)
	ping_request_start_times[ping_n] = Time.get_ticks_msec()
	ping_n += 1


func _on_option_button_item_selected(index: int) -> void:
	set_color(index)
