@abstract
class_name ConditionNode
extends BehaviorTreeNode

@abstract 
func check_condition() -> bool

func tick() -> response:
	if check_condition():
		return response.SUCCESS
	else:
		return response.FAILURE
