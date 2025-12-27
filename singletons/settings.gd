extends Node

var show_fps: bool = false
var show_speedrun_timer: bool = false

var fps_cap: int = 60
var master_volume_linear: float = 0.5 # value between 0-1, above 1 becomes boosted
enum ControlScemes {Rotate, Direct}
var control_scheme: ControlScemes = ControlScemes.Rotate


func _ready() -> void:
	var db: float = linear_to_db(master_volume_linear)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
