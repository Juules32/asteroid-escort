extends Node2D

@onready var spawn_sync_node2d: Node2D = get_node("SpawnSyncNode2D")
@onready var timer: Timer = get_node("Timer")
@export var enemy_to_spawn: PackedScene = preload("uid://ds5wcjhak8447")
@export var spawn_time: float = 5
@export var spawn_cap: int = 2
@export var disabled_spawn_radius: float = 300
@export var query_shape_radius: float = 30 # Adjust based on enemy size
@export var spawn_radius: float = 30

func _ready() -> void:
	#get_node("DebugLabel").visible = false
	timer.wait_time = spawn_time
	
	await Gamedata.player_ready
	
	_initiate()


func _initiate() -> void:
	if global_position.distance_to(Gamedata.active_player.global_position) < 1600:
		for i in range(spawn_cap):
			try_spawn_enemy()
	timer.start()


func try_spawn_enemy() -> void:
	if spawn_sync_node2d.get_child_count() >= spawn_cap:
		return
	
	
	var disabling_entities: Array[Node2D] = []
	disabling_entities.append_array(get_tree().get_nodes_in_group("player"))
	disabling_entities.append_array(get_tree().get_nodes_in_group("core"))

	for e in disabling_entities:
		if e.global_position.distance_to(spawn_sync_node2d.global_position) <= disabled_spawn_radius:
			return

	var space_state := get_world_2d().direct_space_state

	for i in range(3):
		var angle = randf() * TAU
		var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
		var spawn_pos = spawn_sync_node2d.global_position + offset

		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = CircleShape2D.new()
		query.shape.radius = query_shape_radius
		query.transform = Transform2D(0, spawn_pos)
		query.collision_mask = 0xFFFFFFFF

		var result = space_state.intersect_shape(query)
		if result.is_empty():
			var enemy := enemy_to_spawn.instantiate()
			enemy.rotation = randf() * TAU
			spawn_sync_node2d.add_child(enemy, true)
			enemy.global_position = spawn_pos
			return


func _on_timer_timeout() -> void:
	try_spawn_enemy()
	timer.start()
