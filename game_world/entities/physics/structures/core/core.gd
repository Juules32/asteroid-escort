@tool
class_name Core
extends Structure

const CORE_SMALL_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://c1mqyjsdj6oeq")
const CORE_MEDIUM_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://btlxskpdaoaty")
const CORE_BIG_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://c82defbpdqh5t")


var _core_block:Block

func _ready() -> void:
	
	var core_resource_path: String = CORE_BIG_BLOCK_SPECIFICATION.resource_path
	if not Engine.is_editor_hint():
		_request_add_block(core_resource_path, Vector2.ZERO, 0, null)
		Gamedata.core = self
		
		var health_component =  root_block.find_child("HealthComponent")
		health_component.damage_taken.connect(
			func():
				if not $AudioStreamPlayer2D.playing:
					$AudioStreamPlayer2D.play()
		)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if !_core_block and $".".root_block:
		_core_block = $".".root_block
		Gamedata.core_block =  _core_block
		var health_component: HealthComponent = _core_block.find_child("HealthComponent")
		health_component.death.connect(_core_destroyed)
		$HealthbarOverlay.health_component = health_component
		
		#The core should be a bit damaged at the start of the game to indicated that it has been in an accident
		if not $"../.." is MultiplayerMainMenu:
			health_component.current_health -= health_component.max_health / 5
		
	#Tutorial Task 0: Move the core
	if self.linear_velocity.length() >= 2.0:
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.MOVE_CORE)


func _core_destroyed(_killer: Node2D) -> void:
	print("Core killed by: ", _killer.name)
	SignalBus.level_lost.emit("Level Lost:\nCore was destroyed")
