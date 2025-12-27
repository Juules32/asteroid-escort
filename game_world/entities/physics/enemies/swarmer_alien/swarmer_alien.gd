class_name SwarmerAlien
extends Enemy

@onready var animated_sprite2d = get_node("AnimatedSprite2D")

func _ready() -> void:
	super._ready()
	
	$HealthComponent.damage_taken.connect($Damage.play)


var _last_processed_behavior_tree_result
func _physics_process(_delta: float) -> void:
	var current_speed = linear_velocity.length()

	animated_sprite2d.speed_scale = clamp(current_speed / 50.0, 0.5, 3.0)

	if current_speed > 5.0:
		if animated_sprite2d.animation != "move":
			animated_sprite2d.play("move")
	else:
		if animated_sprite2d.animation != "idle":
			animated_sprite2d.play("idle")
		animated_sprite2d.speed_scale = 1.0
	
	if $BehaviorTreeController.last_tick_result == BehaviorTreeNode.response.RUNNING and _last_processed_behavior_tree_result != BehaviorTreeNode.response.RUNNING:
		$Aggro.pitch_scale = randf_range(.9, 1.1)
		$Aggro.play()
	
	_last_processed_behavior_tree_result = $BehaviorTreeController.last_tick_result
	
	if not $Laugh.playing and _last_processed_behavior_tree_result == BehaviorTreeNode.response.RUNNING:
		if randf() < .01 and randf() < .05:
			$Laugh.pitch_scale = randf_range(.95, 1.05)
			$Laugh.play()
