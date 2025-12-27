class_name FallbackNode
extends BehaviorTreeNode

func tick() -> response:
	for node: BehaviorTreeNode in get_children():
		var r: response = node.tick()
		if not r == response.FAILURE:
			return r
	return response.SUCCESS
