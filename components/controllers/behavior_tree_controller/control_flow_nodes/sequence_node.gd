class_name SequenceNode
extends BehaviorTreeNode

func tick() -> response:
	for node: BehaviorTreeNode in get_children():
		var r: response = node.tick()
		if not r == response.SUCCESS:
			return r
	return response.SUCCESS
