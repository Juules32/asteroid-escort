class_name Enemy
extends MovementEntity

@export var tutorial_enemy: bool = false

func _ready() -> void:
	
	$HealthComponent.death.connect(die)
	super._ready()

func die(_killer: Node2D) -> void:
	if tutorial_enemy:
		#Tutorial Task 6: Kill the tutorial enemies
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.ALIEN_ATTACK)
	
	_die()

func _process(_delta: float) -> void:
	if tutorial_enemy:
		return
	
	if global_position.distance_to(Gamedata.active_player.global_position) > 2600:
		die(self)

@rpc("authority", "call_local", "reliable")
func _die() -> void:
	if get_node_or_null("Death") != null:
		get_node("Death").play()
		process_mode = Node.PROCESS_MODE_DISABLED
		visible = false
		
		await get_node("Death").finished
		
		queue_free()
	else:
		queue_free()
