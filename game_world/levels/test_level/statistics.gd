extends VBoxContainer

var ping_request_start_times: Dictionary[int, int]
var ping_response_times: Array[int]
var ping_n: int = 0

@onready var speedrun_timer: SpeedrunTimer = $"../SpeedrunTimer"
@onready var speedrun_time_label: Label = $SpeedrunTimeLabel

func _ready() -> void:
	ping_response_times.resize(32)
	ping_response_times.fill(0)

func _process(_delta: float) -> void:
	if Settings.show_fps:
		$FPS.visible = true
		$FPS.text = (
			"FPS: %s" % Engine.get_frames_per_second()
		)
	else:
		$FPS.visible = false
	
	if Settings.show_speedrun_timer:
		$SpeedrunTimeLabel.visible = true
		speedrun_time_label.text = "Time: " + speedrun_timer.get_time()
	else:
		$SpeedrunTimeLabel.visible = false
