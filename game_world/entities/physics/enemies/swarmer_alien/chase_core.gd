extends ActionNode

@onready var base_entity: MovementEntity = owner
@onready var base_controller: BehaviorTreeController = owner.get_node("BehaviorTreeController")


func tick() -> response:
	var area_2d: Area2D = base_entity.get_node("Area2D")

	var bodies = area_2d.get_overlapping_bodies()
	
	## update MusicManager
	if not bodies:
		if self in MusicManager.aggrod_enemies:
			MusicManager.aggrod_enemies.erase(self)

	for body in bodies:
		if body is Core:
			if not self in MusicManager.aggrod_enemies:
				MusicManager.aggrod_enemies.append(self)
			
			var direction = (body.global_position - base_entity.global_position).normalized()

			base_controller.movement_input = direction
			return response.RUNNING

	base_controller.movement_input = Vector2.ZERO
	return response.FAILURE
