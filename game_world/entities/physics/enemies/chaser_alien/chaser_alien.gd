class_name ChaserAlien
extends Enemy

func _ready() -> void:
	super._ready()
	
	$HealthComponent.damage_taken.connect($Damage.play)


var _last_processed_behavior_tree_result
func _physics_process(_delta: float) -> void:
	
	if $BehaviorTreeController.last_tick_result == BehaviorTreeNode.response.RUNNING and _last_processed_behavior_tree_result != BehaviorTreeNode.response.RUNNING:
		$Aggro.pitch_scale = randf_range(.9, 1.1)
		$Aggro.play()
	
	_last_processed_behavior_tree_result = $BehaviorTreeController.last_tick_result
	
	if not $Laugh.playing and _last_processed_behavior_tree_result == BehaviorTreeNode.response.RUNNING:
		if randf() < .01 and randf() < .05:
			$Laugh.pitch_scale = randf_range(.95, 1.05)
			$Laugh.play()
