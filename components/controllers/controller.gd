## Class which processes and synchronizes input

## NOTE: All subclasses of Controller need to be instanced as scenes.
## This is because all Controllers rely on MultiplayerSynchronizer functionality
## which is very difficult to get working through a script.
## This can be done easily with CTRL+SHIFT+A
@abstract
class_name Controller
extends Component

@export_category("Sync These")
## INFO: This property should be changed in child classes
## to indicate the movement input given by the controller
@export var movement_input: Vector2
@export var try_place_block: bool
@export var placement_angle: float
@export var drill_enabled: bool = false
@export var building_menu_enabled: bool = false:
	set(value):
		building_menu_enabled = value
		SignalBus.build_mode_changed.emit(value)
@export var sprinting: bool = false
var zoom_level: int = 0

func _init() -> void:
	type = Controller
