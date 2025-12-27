class_name HealthbarOverlay
extends PanelContainer

@export var health_component: HealthComponent

@onready var health: ColorRect = $Health
@onready var _parent: Node2D = $".."

var _initial_position: Vector2

func _ready() -> void:
	_initial_position = self.position

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	#Rotate so that the healthbar is always level
	self.position = _initial_position.rotated(-1.0 * _parent.rotation)
	self.rotation = -1.0 * _parent.rotation
	
	if health_component:
		var health_percentage: int = int(health_component.current_health * 100 / health_component.max_health)
		health.custom_minimum_size.x = health_percentage
		
		visible = health_percentage != 100
