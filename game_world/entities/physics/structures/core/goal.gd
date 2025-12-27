extends Node2D
class_name AsteroidGoal


func _on_area_2d_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	if body is Core:
		var core: Core = body
		var body_shape_owner = body.shape_find_owner(body_shape_index)
		var body_shape_node = body.shape_owner_get_owner(body_shape_owner)

		#Check if it is the core that has reached the goal (Is false if only some built structure touches the goal area)
		if core.root_block == body_shape_node:
			print("Goal reached with core")
			MusicManager.stop()
			get_tree().create_tween().tween_property(AudioServer.get_bus_effect(0,0), "cutoff_hz", 20500, 1)
			$AudioStreamPlayer.play()
			SignalBus.level_victory.emit("Victory")
