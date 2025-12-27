class_name EntitySpawner
extends MultiplayerSpawner


func _init() -> void:
	spawn_function = _spawn

func _enter_tree() -> void:
	spawn_path = get_path()


## spawns a scene with correct initial position and rotation
## INFO: allows for setting any variable on all peers with "additional_params"
func spawn_scene(scene_path: String, global_position: Vector2, rotation: float = 0, additional_params: Dictionary[String, Variant] = {}) -> Node:
	var data: Dictionary = additional_params
	data["global_position"] = global_position
	data["rotation"] = rotation
	data["scene_path"] = scene_path
	
	return spawn(data)

## Override this method in child classes to inject code into the _spawn method
func _spawn_inject(_spawn_node: Node2D, _data: Dictionary) -> void:
	pass

func _spawn(data: Dictionary) -> Node:
	var s: PlayerShip = load(data.scene_path).instantiate()
	
	s.get_node("PlayerSprites").set_color_preset(data["color_index"])
	
	_spawn_inject(s, data)
	
	for property_name in data.keys():
		if property_name in s:
			s.set(property_name, data[property_name])
	
	return s
