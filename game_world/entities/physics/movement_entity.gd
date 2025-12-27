## Represents any object that can move based on a controller
class_name MovementEntity
extends SynchronizedRigidbody2D

@export var movement_speed: float = 50

## Multiplier applied to velocity to deaccelerate
@export_range(0, 1, 0.02) var movement_deaccel_mult = 1.0


## Speed at which object rotates to face movement direction (radians per second)
@export var rotation_speed: float = 10.0

## Multiplier applied to rotation to deaccelerate
@export_range(0, 1, 0.02) var rotation_deaccel_mult = 0.0


@onready var controller: Controller = \
		Component.get_component(self, Controller)

var movement_speed_mult: float = 1.0

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	super._integrate_forces(state)
	
	state.linear_velocity += movement_speed * movement_speed_mult * controller.movement_input
	
	state.linear_velocity *= movement_deaccel_mult
	
	
	# If there is movement input, rotate object to face movement direction.
	if controller.movement_input.length() > 0.1:
		var target_angle = controller.movement_input.angle()
		var current_angle = state.transform.get_rotation()
		var angle_diff = angle_difference(current_angle, target_angle)
		state.angular_velocity = angle_diff * rotation_speed
	else:
		state.angular_velocity *= rotation_deaccel_mult
