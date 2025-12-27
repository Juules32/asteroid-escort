class_name SpeedrunTimer
extends Timer

const SPEEDRUN_WAIT_TIME: float = 1_000_000.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start(SPEEDRUN_WAIT_TIME)

func get_time() -> String:
	return "%1.2fs" % (SPEEDRUN_WAIT_TIME - time_left)
