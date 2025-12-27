extends Node

signal player_ready

var active_player: PlayerShip:
	set(value):
		active_player = value
		
		if value != null:
			player_ready.emit()
var core: Core
var core_block: Block = null
var tutorial_tasks: TutorialTasks
var total_resource_count: Array[int] = [0,0,0]
