class_name PlayerShip
extends MovementEntity

const DEFAULT_SPEED_MULT: float = 0.7
const SPRINT_SPEED_MULT: float = 1.3
const REPAIR_SPEED_MULT: float = 0.3

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var black_hole: TextureRect = $BlackHole
@onready var player_camera: Camera2D = $PlayerCamera

var owner_id: int = 1:
	set(value):
		owner_id = value
		$PlayerController.set_multiplayer_authority(owner_id)
		
		await ready
		
		if owner_id == multiplayer.get_unique_id():
			Gamedata.active_player = self

func _ready() -> void:
	#Disabled since it caused errors when restarting the level
	#Performance.add_custom_monitor("game/player_%s/linear_velocity" % self.owner_id, self.get_player_linear_velocity)
	
	movement_speed_mult = DEFAULT_SPEED_MULT

	if owner_id == multiplayer.get_unique_id():
		animation_player.play(&"spawn_animation")
		black_hole.show()
		$PlayerCamera.enabled = true
	else:
		black_hole.hide()

func _physics_process(_delta: float) -> void:
	$PlayerSprites/Drill.animation = "on" if controller.drill_enabled else "off"
	$DrillArea.monitoring = controller.drill_enabled
	call_deferred("set_tipshape_property_deferred", controller.drill_enabled)
	player_camera.zoom = Vector2.ONE * pow(1.07, controller.zoom_level)

	if $PlayerController.dead:
		movement_speed_mult = REPAIR_SPEED_MULT
	elif $PlayerController.sprinting:
		movement_speed_mult = SPRINT_SPEED_MULT
	else:
		movement_speed_mult = DEFAULT_SPEED_MULT

func set_tipshape_property_deferred(disabled: bool) -> void:
	$TipShape.disabled = disabled

func push_on_spawn() -> void:
	apply_force(Vector2(15000.0, 0.0))

func get_player_linear_velocity() -> float:
	return $".".linear_velocity.length()

@rpc("authority", "call_local", "reliable")
func _enter_repair_state() -> void:
	modulate.a = 0.5
	$PlayerSprites.alpha = 0.2
	$PlayerController.dead = true
	$PlayerController.disable_all()
	set_collision_mask_value(5, false)
	set_collision_layer_value(2, false)
	$PlayerFX/Death.play()


@rpc("authority", "call_local", "reliable")
func _exit_repair_state() -> void:
	modulate.a = 1
	$PlayerSprites.alpha = 1
	$PlayerController.dead = false
	set_collision_mask_value(5, true)
	set_collision_layer_value(2, true)
	$PlayerFX/Repair.play()

func _on_death(_killer: Node2D) -> void:
	SignalBus.player_death.emit()
	_enter_repair_state()
	$RepairStateTimer.start()

func _on_repair_state_timer_timeout() -> void:
	_exit_repair_state()
	SignalBus.player_repair.emit()
	
func switch_block_selection_to(new_block_specification: BlockSpecification, index_diff: int) -> void:
	$PlayerController/BlockPlacer.switch_block_selection_to(new_block_specification, index_diff)

func get_primary_color() -> Color:
	return $PlayerSprites.colors[3]

func _on_area_2d_asteroid_checker_body_entered(body: Node2D) -> void:
	#Tutorial Task: Find Asteroid:
	if body is AbstractAsteroid:
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.FIND_ASTEROID)
