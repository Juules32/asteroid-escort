@tool
extends Block
class_name TurretBlock

@export var damage: float = 5
@export var attack_cooldown: float = 0.2
@export var target_block_specs: Array[BlockSpecification] = []

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var laser_timer: Timer = get_node("LaserTimer")
@onready var attack_area2d: Area2D = get_node("AttackArea2D")
@onready var gun_barrel_sprite2d: Sprite2D = get_node("GunBarrelSprite2D")
@onready var laser_spawn_point: Node2D = get_node("LaserSpawnPoint")
@onready var collision_area2d: Area2D = get_node("CollisionArea")

var attack_ready: bool = true
var laser_line: Line2D
var current_target_global_hit_pos: Vector2 = Vector2(0, 0)
var laser_active: bool = false


func _ready() -> void:
	attack_timer.wait_time = attack_cooldown
	laser_timer.wait_time = attack_cooldown / 2
	laser_line = Line2D.new()
	laser_line.width = 2
	laser_line.default_color = Color.RED
	get_tree().root.add_child(laser_line)


func _exit_tree() -> void:
	laser_line.clear_points()


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if laser_active and current_target_global_hit_pos:
		look_at(current_target_global_hit_pos)
		rotation -= deg_to_rad(180)
		_update_laser()
	
	#if not multiplayer.is_server():
	#	return
	
	var sorted_targets: Array[Node2D] = get_targets()
	
	if sorted_targets.is_empty():
		return
	
	var space := get_world_2d().direct_space_state
	var target: Node2D = null

	for e in sorted_targets:
		var query := PhysicsRayQueryParameters2D.create(global_position, e.global_position)
		query.exclude = [self]
		var result = space.intersect_ray(query)

		if result:
			var collider = result.collider
			
			if collider is AbstractAsteroid:
				collider = collider.get_block()
			
			if collider == e:
				target = e
				break


	if target == null:
		return

	look_at(target.global_position)
	rotation += deg_to_rad(180)

	if attack_ready:
		rpc_start_laser()
		var hc: HealthComponent = Component.get_component(target, HealthComponent)
		hc.damage(damage, self)
		attack_ready = false
		attack_timer.start()
		
		$AudioStreamPlayer2D.pitch_scale = randf_range(.9, .1)
		$AudioStreamPlayer2D.play()
		


func get_targets() -> Array[Node2D]:
	var bodies = attack_area2d.get_overlapping_bodies()
	var enemies: Array[Enemy] = []
	var asteroids: Array[Block] = []
	
	for body in bodies:
		if body is Enemy:
			enemies.append(body)
		elif body is AbstractAsteroid:
			if target_block_specs.size() == 0:
				continue
			var asteroid_block = body.get_block()
			if not asteroid_block:
				continue
			if asteroid_block == get_root_parent():
				continue
			for block_spec in target_block_specs:
				if asteroid_block.specification == block_spec:
					asteroids.append(asteroid_block)
	
	enemies.sort_custom(func(a, b):
		return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position)
	)
	
	asteroids.sort_custom(func(a, b):
		return a.global_position.distance_to(global_position) < b.global_position.distance_to(global_position)
	)
	
	var sorted_targets: Array[Node2D] = []
	sorted_targets.append_array(enemies)
	sorted_targets.append_array(asteroids)
	
	return sorted_targets


@rpc("call_local")
func rpc_start_laser() -> void:
	var sorted_targets: Array[Node2D] = get_targets()

	if sorted_targets.is_empty():
		return

	var space := get_world_2d().direct_space_state
	var target: Node2D = null
	var raycast_result = null
	
	for e in sorted_targets:
		var query := PhysicsRayQueryParameters2D.create(global_position, e.global_position)
		query.exclude = [self]
		raycast_result = space.intersect_ray(query)

		if raycast_result:
			var collider = raycast_result.collider
			
			if collider is AbstractAsteroid:
				collider = collider.get_block()
			
			if collider == e:
				target = e
				break

	if target == null:
		current_target_global_hit_pos = Vector2(0, 0)
		laser_active = false
		laser_line.clear_points()
		return
	
	if raycast_result and raycast_result.collider != target:
		current_target_global_hit_pos = raycast_result.position
	else:
		current_target_global_hit_pos = target.global_position
	laser_active = true
	laser_timer.start()


func _update_laser() -> void:
	if not current_target_global_hit_pos:
		laser_line.clear_points()
		return

	laser_line.clear_points()
	laser_line.add_point(laser_spawn_point.global_position)
	laser_line.add_point(current_target_global_hit_pos)


func _on_attack_timer_timeout() -> void:
	attack_ready = true
	current_target_global_hit_pos = Vector2(0, 0)
	laser_line.clear_points()


func _on_laser_timer_timeout() -> void:
	laser_active = false
	current_target_global_hit_pos = Vector2(0, 0)
	laser_line.clear_points()
