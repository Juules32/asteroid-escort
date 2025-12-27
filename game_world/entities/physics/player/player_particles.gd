extends Node2D

@export var drill_area: Area2D
@export var player_sprites: Node2D

var thrusters_emitting: bool = false:
	set(value):
		thrusters_emitting = value
		$RightThruster.emitting = thrusters_emitting
		$LeftThruster.emitting = thrusters_emitting
		
		if $RightThrusterSFX.playing != thrusters_emitting:
			$RightThrusterSFX.playing = thrusters_emitting
		if $LeftThrusterSFX.playing != thrusters_emitting:
			$LeftThrusterSFX.playing = thrusters_emitting

@onready var controller: Controller = \
	Component.get_component(get_parent(), Controller)

@onready var base_movement_speed: float = get_parent().movement_speed

@onready var player_controller: Controller = $"../PlayerController"

func _ready() -> void:
	$LeftThruster.modulate = player_sprites.colors[3]
	$RightThruster.modulate = player_sprites.colors[3]

func _process(_delta: float) -> void:
	_process_thruster_particles()
	_process_drill_particles()
	_process_drill_sfx()


func _process_thruster_particles() -> void:
	if not controller.movement_input:
		thrusters_emitting = false
		return
	
	var process_material: ParticleProcessMaterial = $LeftThruster.process_material
	
	if player_controller.sprinting and not player_controller.dead:
		process_material.scale_min = 5.0
		process_material.scale_max = 9.0
		process_material.spread = 20
		process_material.initial_velocity_max = 50
		process_material.initial_velocity_min = 25
		$LeftThruster.amount_ratio = 1.4
		$RightThruster.amount_ratio = 1.4
		$LeftThrusterSFX.volume_db = -10
		$RightThrusterSFX.volume_db = -10
		$LeftThrusterSFX.pitch_scale = 2
		$RightThrusterSFX.pitch_scale = 2
	else:

		process_material.scale_min = 3.0
		process_material.scale_max = 6.5
		process_material.spread = 10
		process_material.initial_velocity_max = 10
		process_material.initial_velocity_min = 5
		$LeftThruster.amount_ratio = .4
		$RightThruster.amount_ratio = .4
		$LeftThrusterSFX.volume_db = -20
		$RightThrusterSFX.volume_db = -20
		$LeftThrusterSFX.pitch_scale = 1
		$RightThrusterSFX.pitch_scale = 1
		
	var angle_diff = angle_difference(
		controller.movement_input.angle(),
		get_parent().rotation
	)
	
	if abs(angle_diff) < 0.2 * PI:
		thrusters_emitting = true
		get_parent().movement_speed = base_movement_speed
		return
	elif angle_diff < 0:
		$LeftThruster.emitting = true
		if not $LeftThrusterSFX.playing:
			$LeftThrusterSFX.playing = true
		$RightThruster.emitting = false
		if $RightThrusterSFX.playing:
			$RightThrusterSFX.playing = false
	elif angle_diff > 0:
		$LeftThruster.emitting = false
		if $LeftThrusterSFX.playing:
			$LeftThrusterSFX.playing = false
		$RightThruster.emitting = true
		if not $RightThrusterSFX.playing:
			$RightThrusterSFX.playing = true

	
	## Make player slower when thrusters are not aligned
	get_parent().movement_speed = base_movement_speed / 2

var _last_drill_enabled: bool = false
func _process_drill_sfx() -> void:
	if controller.drill_enabled and not _last_drill_enabled:
		$DrillSFX.play()
	elif not controller.drill_enabled and _last_drill_enabled:
		$DrillSFX.get_stream_playback().switch_to_clip(2)
	_last_drill_enabled = controller.drill_enabled

func _process_drill_particles() -> void:
	if controller.drill_enabled and drill_area.monitoring:
		if len(drill_area.get_overlapping_bodies()) > 0:
			$Drill.emitting = true
			if not $MiningSFX.playing:
				$MiningSFX.play()
			return
	$MiningSFX.stop()
	$Drill.emitting = false
