## This condition node only returns success, if the timer is not running
## This can be used to create a cooldown-esque system quite easily
class_name TimeHasPassedNode
extends ConditionNode

@export var wait_time: float = 1

var timer: Timer

var running: bool = false

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func check_condition() -> bool:
	if running:
		return false
	else:
		timer.start()
		running = true
		return true

func _on_timer_timeout() -> void:
	running = false
