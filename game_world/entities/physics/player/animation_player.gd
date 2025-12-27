extends AnimationPlayer

@onready var player_controller: MultiplayerSynchronizer = $"../PlayerController"

func enable_movement() -> void:
	SignalBus.show_tutorial.emit()
	player_controller.enable_controls = true
