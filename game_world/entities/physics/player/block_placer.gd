class_name BlockPlacer
extends Node

const PLACEMENT_COLLISION_SHAPE_RADIUS: float = 5.0
const MOVING_STRUCTURE_COEFFICIENT: float = 0.0415
const PLACEMENT_SEPARATION: float = 1.0 # To make placement legality check easier
const PLACEMENT_RANGE: float = 120
const LEGAL_BASE_COLOR: Vector4 = Vector4(0.3058, 0.835, 0.960, 1.)
const LEGAL_LINES_COLOR: Vector4 = Vector4(0.633232, 0.910156, 0.555693, 1.)
const ILLEGAL_BASE_COLOR: Vector4 = Vector4(1.0, 0.1, 0.1, 1.0)
const ILLEGAL_LINES_COLOR: Vector4 = Vector4(1.0, 0.5, 0.5, 1.0)

const CUBE: BlockSpecification = preload("uid://b8bh472xa0p2m")
const LONG_CUBE: BlockSpecification = preload("uid://cqpo5kx1y0qim")
const TURRET: BlockSpecification = preload("uid://bi21bqwxct8go")
const THRUSTER: BlockSpecification = preload("uid://bk4u5pjeleghw")
const BEACON: BlockSpecification = preload("uid://b4mu8dem5fdfg")

const BLOCK_SPECIFICATIONS: Array[BlockSpecification] = [
	CUBE,
	LONG_CUBE,
	THRUSTER,
	TURRET,
	BEACON
	#TURRET_BASE,
]

var active_specification_index: int = 0
var active_specification: BlockSpecification:
	get():
		return BLOCK_SPECIFICATIONS[active_specification_index]

var active_anchor_index: int = 0
var active_anchor: Anchor:
	get():
		return active_specification.anchors[active_anchor_index]

@export var player: MovementEntity

# To detect structures
@onready var placement_ray_cast: RayCast2D = $PlacementRayCast

# To help rotate from the active block anchor
@onready var anchor_marker: Marker2D = $AnchorMarker

# To check and preview block placement
@onready var placement_area: Area2D = $AnchorMarker/PlacementArea
@onready var placement_collision_shape: CollisionShape2D = $AnchorMarker/PlacementArea/PlacementCollisionShape
@onready var placement_sprite: Sprite2D = $AnchorMarker/PlacementArea/PlacementCollisionShape/PlacementSprite

# Hologram to indicate placement legality
@onready var placement_sprite_shader_material: ShaderMaterial = placement_sprite.material as ShaderMaterial
@onready var block_placement_area_indicator: Sprite2D = $BlockPlacementAreaIndicator
@onready var placement_particles: GPUParticles2D = $PlacementParticles

@onready var placement_cooldown: Timer = $PlacementCooldown

var collider: Object
var block: Block
var structure: Structure


func _ready() -> void:
	placement_ray_cast.target_position.x = PLACEMENT_RANGE
	SignalBus.changed_active_block.emit(0, active_specification)
	if is_multiplayer_authority():
		SignalBus.craft_block_confirm.connect(_on_craft_block_confirm)

func _input(event: InputEvent) -> void:
	#Do nothing if building menu is disabled
	if !player.controller.building_menu_enabled:
		placement_sprite.hide()
		block_placement_area_indicator.hide()
		placement_particles.hide()
		placement_particles.emitting = false
		return
		
	if is_multiplayer_authority():
		block_placement_area_indicator.show()
		placement_sprite.show()
		placement_particles.show()
		placement_particles.emitting = true
	
	if event.is_action_pressed("block_specification_right"):
		active_specification_index += 1
		active_anchor_index = 0
	elif event.is_action_pressed("block_specification_left"):
		active_specification_index -= 1
		active_anchor_index = 0
	elif event.is_action_pressed("change_block_specification_anchor"):
		active_anchor_index += 1
	active_specification_index = active_specification_index % BLOCK_SPECIFICATIONS.size()
	active_anchor_index = active_anchor_index % active_specification.anchors.size()

	if event.is_action_pressed("block_specification_right"):
		if is_multiplayer_authority():
			SignalBus.changed_active_block.emit(1, active_specification)
	if event.is_action_pressed("block_specification_left"):
		if is_multiplayer_authority():
			SignalBus.changed_active_block.emit(-1, active_specification)


func switch_block_selection_to(new_block_specification: BlockSpecification, index_diff: int) -> void:
	#Do nothing if building menu is disabled
	if !player.controller.building_menu_enabled:
		return
	
	var new_index = BLOCK_SPECIFICATIONS.find(new_block_specification)
	active_specification_index = new_index
	active_anchor_index = 0
	SignalBus.changed_active_block.emit(index_diff, active_specification)


func _physics_process(_delta: float) -> void:
	# Always running this method prevents a visual glitch
	_update_visualization_pos()
	
	#Do nothing if building menu is disabled
	if !player.controller.building_menu_enabled:
		return
		
	var placement_angle: float = 0.0
	if is_multiplayer_authority():
		# Check if using gamepad or mouse for aiming
		var aim_direction = player.controller.get_aim_direction()
		if aim_direction != Vector2.ZERO:
			# Using gamepad - aim in the global direction of right stick
			placement_angle = aim_direction.angle()
		else:
			# Using mouse - aim towards mouse cursor in global space
			var mouse_global = player.get_global_mouse_position()
			var direction_to_mouse = mouse_global - player.global_position
			placement_angle = direction_to_mouse.angle()
	
	
	_update_specification()
	_update_raycast(placement_angle)
	
	collider = placement_ray_cast.get_collider()
	_update_placement_particles(placement_angle)
	
	if collider:
		block = collider.get_parent()
		structure = block.get_parent()
		
		# Offset position to rotate around anchor point
		placement_area.position = -active_anchor.point
		
		_update_anchor_marker()
		
		var is_legal: bool = _is_legal_placement()
		var obeys_stacking_rules: bool = \
			block.specification.stackable or active_specification.stackable
		
		_set_hologram_color(is_legal and obeys_stacking_rules)
		if is_legal and obeys_stacking_rules and player.controller.try_place_block:
			if is_multiplayer_authority() and placement_cooldown.is_stopped():
				SignalBus.craft_block_request.emit(active_specification)
		elif player.controller.try_place_block:
			$AnchorMarker/PlacementArea/Fail.play()
	else:
		#If the raycast is not colliding the show the placement_sprite at the end of the ray
		anchor_marker.position = player.global_position + Vector2.RIGHT.rotated(placement_angle) * PLACEMENT_RANGE
		# Offset position to rotate around anchor point
		placement_area.position = -active_anchor.point
		anchor_marker.rotation = placement_angle + active_anchor.normal
		_set_hologram_color(false)



func _update_specification() -> void:
	placement_collision_shape.shape = active_specification.shape
	placement_sprite.texture = active_specification.texture


func _update_raycast(placement_angle: float = 0.0) -> void:
	player.controller.placement_angle = placement_angle
	placement_ray_cast.rotation = player.controller.placement_angle

func _update_visualization_pos() -> void:
	block_placement_area_indicator.global_position = player.global_position
	placement_ray_cast.global_position = player.global_position
	placement_particles.global_position = player.global_position
	anchor_marker.position = placement_ray_cast.get_collision_point()



func _update_placement_particles(placement_angle: float = 0.0) -> void:
	placement_particles.rotation = placement_angle

	var collision_length = PLACEMENT_RANGE / 2
	if collider:
		collision_length = ((placement_ray_cast.get_collision_point() - placement_ray_cast.global_position).length()) / 2.0
	collision_length = max(collision_length, 0) - 8
	
	var material: ParticleProcessMaterial = placement_particles.process_material
	if material:
		material.emission_shape_offset.x = collision_length
		material.emission_box_extents.x = collision_length

func _update_anchor_marker() -> void:
	var normal = placement_ray_cast.get_collision_normal()
	anchor_marker.position += normal * PLACEMENT_SEPARATION
	anchor_marker.rotation = normal.angle() + active_anchor.normal + PI
	
	# Predictive offset for moving structures
	# NOTE: Offset amount is NOT framerate-dependent
	anchor_marker.position += structure.linear_velocity * MOVING_STRUCTURE_COEFFICIENT


func _is_legal_placement() -> bool:
	if placement_area.has_overlapping_bodies():
		return false
	
	#During the tutorial, allow the player only to place the specific type of building
	#if Gamedata.tutorial_tasks:
		#match Gamedata.tutorial_tasks.current_task:
			#TutorialTasks.TUTORIAL_ID.BUILD_SIMPLE_BLOCK:
				#return active_specification == CUBE
			#TutorialTasks.TUTORIAL_ID.BUILD_LONGER_BLOCK:
				#return active_specification == LONG_CUBE
			#TutorialTasks.TUTORIAL_ID.CONSTRUCT_TURRET:
				#return active_specification == TURRET
			#TutorialTasks.TUTORIAL_ID.CONSTRUCT_THRUSTER:
				#return active_specification == THRUSTER
			#TutorialTasks.TUTORIAL_ID.CONSTRUCT_BEACON:
				#return active_specification == BEACON
			#_:
				#return true
	
	return true


func _on_craft_block_confirm() -> void:
	placement_cooldown.start()
	
	#Tutorial Task: Build a Cube
	if active_specification == CUBE:
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.BUILD_SIMPLE_BLOCK)
	#Tutorial Task: Build a Long Block
	if active_specification == LONG_CUBE:
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.BUILD_LONGER_BLOCK)
	#Tutorial Task: Build a Beacon
	if active_specification == BEACON:
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.CONSTRUCT_BEACON)
	#Tutorial Task: Build a Thruster
	if active_specification == THRUSTER:
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.CONSTRUCT_THRUSTER)
	#Tutorial Task: Build a Turret
	if active_specification == TURRET:
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.CONSTRUCT_TURRET, placement_area.global_position, placement_area.global_rotation)
		
	_place_block(
		active_specification.resource_path,
		structure.to_local(placement_area.global_position),
		placement_area.global_rotation
	)


@rpc("authority", "call_local", "reliable")
func _place_block(block_path: String, placement_position: Vector2, placement_global_rotation: float) -> void:
	## Got an error where collider was null so just do nothing in that case i guess
	if not collider:
		Console.push_error("block placement failed: block existance out of sync")
		return
	
	structure._request_add_block(
		block_path,
		placement_position,
		placement_global_rotation - structure.global_rotation,
		block
	)
	
	$AnchorMarker/PlacementArea/Success.play()

func _set_hologram_color(is_legal: bool) -> void:
	if is_legal:
		placement_sprite_shader_material.set_shader_parameter("baseColor", LEGAL_BASE_COLOR)
		placement_sprite_shader_material.set_shader_parameter("linesColor", LEGAL_LINES_COLOR)
	else:
		placement_sprite_shader_material.set_shader_parameter("baseColor", ILLEGAL_BASE_COLOR)
		placement_sprite_shader_material.set_shader_parameter("linesColor", ILLEGAL_LINES_COLOR)
