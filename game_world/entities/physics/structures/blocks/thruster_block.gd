@tool
class_name ThrusterBlock
extends Block

const THRUSTER_STRENGTH: float = 400.0
const RADIANS_OFFSET: float = PI * 0.5

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var thrusting_timer: Timer = $ThrustingTimer


var player_in_interract_range: bool = false:
	set(value):
		player_in_interract_range = value
		if not Gamedata.active_player.controller.building_menu_enabled:
			if not is_thrusting:
				can_interract = player_in_interract_range
			else:
				can_interract = false

var can_interract: bool = false:
	set(value):
		can_interract = value
		$Sprite2D2.visible = value

var is_thrusting: bool:
	get():
		return not thrusting_timer.is_stopped()
	set(value):
		gpu_particles_2d.emitting = value
		if value:
			thrusting_timer.start()
			#Tutorial Task: Activate the thruster
			SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.ACTIVATE_THRUSTER)
		
		player_in_interract_range = player_in_interract_range


func _ready() -> void:
	super._ready()
	
	if Engine.is_editor_hint():
		return
	
	SignalBus.interract.connect(_on_interract)
	SignalBus.build_mode_changed.connect(_on_build_mode_changed)


func _physics_process(_delta: float) -> void:
	if is_thrusting:
		_thrust()

	
func _thrust() -> void:
	var force_direction: Vector2 = Vector2(
		cos(global_rotation + RADIANS_OFFSET),
		sin(global_rotation + RADIANS_OFFSET)
	)
	var force: Vector2 = force_direction * THRUSTER_STRENGTH
	var force_position: Vector2 = \
		Vector2(global_position - parent_structure.global_position)
	parent_structure.apply_force(force, force_position)

func _on_interract() -> void:
	if can_interract:
		begin_thrust()

@rpc("any_peer", "call_local", "reliable")
func begin_thrust() -> void:
	is_thrusting = true
	$AudioStreamPlayer2D.play()


func _on_thrusting_timer_timeout() -> void:
	is_thrusting = false
	$AudioStreamPlayer2D.stop()


func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is PlayerShip:
		#if body.owner_id == multiplayer.get_unique_id():
			player_in_interract_range = true


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is PlayerShip:
		#if body.owner_id == multiplayer.get_unique_id():
			player_in_interract_range = false

func _on_build_mode_changed(_enabled: bool) -> void:
	player_in_interract_range = player_in_interract_range
