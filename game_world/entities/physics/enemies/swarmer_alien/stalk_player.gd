extends ActionNode

@export var desired_distance := 130.0        # Ideal stalking distance
@export var tolerance := 30.0              # +/- tolerance allowed

@onready var base_entity: MovementEntity = owner
@onready var base_controller: BehaviorTreeController = owner.get_node("BehaviorTreeController")


func tick() -> response:
	var area_2d: Area2D = base_entity.get_node("StalkArea")
	var bodies = area_2d.get_overlapping_bodies()
	
	if bodies.is_empty():
		MusicManager.aggrod_enemies.erase(self)
		base_controller.movement_input = Vector2.ZERO
		return response.FAILURE

	var nearest_player: PlayerShip = null
	var nearest_dist: float = INF

	for body in bodies:
		if body is PlayerShip:
			var d = base_entity.global_position.distance_to(body.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest_player = body

	if nearest_player == null:
		base_controller.movement_input = Vector2.ZERO
		return response.FAILURE

	if self not in MusicManager.aggrod_enemies:
		MusicManager.aggrod_enemies.append(self)
	
	var dist = base_entity.global_position.distance_to(nearest_player.global_position)
	var dir = (nearest_player.global_position - base_entity.global_position).normalized()
	
	if dist > desired_distance + tolerance:
		base_controller.movement_input = dir
		return response.RUNNING
	
	elif dist < desired_distance - tolerance:
		base_controller.movement_input = -dir
		return response.RUNNING
	
	else:
		base_controller.movement_input = Vector2.ZERO
		return response.RUNNING
