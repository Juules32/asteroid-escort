## Represents any RigidBody2D which should be synchronized
## INFO: Does not work as a standalone class
## Should be inhereted from and instanced as a scene
class_name SynchronizedRigidbody2D
extends RigidBody2D

@export var colliding_replication_interval: float = 0.15
@export var replication_interval: float = 0.20

## All these fields should be synchronized by the MultiplayerSynchronizer
@export_category("Sync These")
@export var sync_frame: int = 0
@export var sync_origin: Vector2
@export var sync_rotation: float
@export var sync_linear_velocity: Vector2
@export var sync_angular_velocity: float

@export_category("Setup")
@export var _synchronizer: MultiplayerSynchronizer

var _rotation: float

@onready var sleeping_replication_interval: float = randf_range(3.0, 6.0)

func _ready() -> void:
	_synchronizer.replication_interval = sleeping_replication_interval
	
	$RigidBody2DSynchronizer.synchronized.connect(_on_synchronized)
	sleeping_state_changed.connect(_on_sleeping_state_changed)


## INFO: When overwriting this method make sure to call super._integrate_forces(state)
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#if is_multiplayer_authority():
		sync_frame += 1
		sync_origin = state.transform.origin
		sync_rotation = state.transform.get_rotation()
		sync_linear_velocity = state.linear_velocity
		sync_angular_velocity = state.angular_velocity
	#else:
		#if sync_frame <= _last_processed_frame: return
		#_last_processed_frame = sync_frame
		#
		#state.linear_velocity = sync_linear_velocity
		#state.angular_velocity = sync_angular_velocity
		#
		#_rotation = state.transform.get_rotation()
		#
		#if _last_processed_frame > 0:
			#_smoothen_movement(state)
		#
		#state.transform = state.transform.rotated(-_rotation)
		#state.transform = state.transform.rotated(sync_rotation)
		#state.transform.origin = sync_origin


func _smoothen_movement(state: PhysicsDirectBodyState2D) -> void:
	var position_diff: Vector2 = state.transform.origin - sync_origin
	
	## Smoothen position
	if position_diff.length() < 200:
		sync_origin = state.transform.origin.lerp(
			sync_origin,
			.05
		)
	
	## Smoothen rotation
	if abs(_rotation - sync_rotation) <= PI/4:
		sync_rotation = lerp_angle(
			_rotation,
			sync_rotation,
			.05
			)


func _on_synchronized() -> void:
	if get_contact_count() == 0:
		_synchronizer.replication_interval = replication_interval
	else:
		_synchronizer.replication_interval = colliding_replication_interval
	
	if sleeping:
		_synchronizer.replication_interval = sleeping_replication_interval


func _on_sleeping_state_changed() -> void:
	if not sleeping:
		_synchronizer.replication_interval = replication_interval
