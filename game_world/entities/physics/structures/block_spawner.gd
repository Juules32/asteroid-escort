## Only made to exist in the Structure scene
@tool
class_name BlockSpawner
extends MultiplayerSpawner


func _init() -> void:
	spawn_function = _spawn


## INFO: Both position and rotation need to be local to the Structure
func spawn_block(block_spec_path: String, position: Vector2, rotation: float) -> Block:
	var data: Dictionary = {
		"block_spec_path": block_spec_path,
		"position": position,
		"rotation": rotation
	}
	
	return spawn(data)

func _spawn(data: Dictionary) -> Node:
	var block_spec: BlockSpecification = ResourceLoader.load(data.block_spec_path)
	var block: Block = block_spec.get_instance()
	
	block.position = data.position
	block.rotation = data.rotation
	
	return block
