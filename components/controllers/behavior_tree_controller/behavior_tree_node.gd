## Represents a node in a behavior tree
## For an explanation of behavior trees:
##		https://robohub.org/introduction-to-behavior-trees/
@abstract
class_name BehaviorTreeNode
extends Node

enum response {
	SUCCESS,
	FAILURE,
	RUNNING
}

var controller: BehaviorTreeController

func _enter_tree() -> void:
	if get_parent() is BehaviorTreeController:
		controller = get_parent()
	else:
		controller = get_parent().controller

@abstract
func tick() -> response
