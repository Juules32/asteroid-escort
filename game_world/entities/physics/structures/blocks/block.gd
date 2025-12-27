## Represents a segment of a structure
## Blocks can be both buildable by the player or not

## WARNING: Note that (currently) any new scenes inheriting from Block would
## most likely need to be manually added to the autospawn list on the block_spawner 
## in the structure scene to be synchronized
@tool
class_name Block
extends CollisionShape2D

const DEATH_PARTICLES = preload("res://game_world/fx/block_break_particles.tscn")

@export var mass: float = 1
@export var specification: BlockSpecification:
	set(value):
		if not value:
			return
		specification = value
		mass = specification.mass
		shape = specification.shape
		$"Sprite2D".texture = specification.texture
		$CollisionArea/AreaCollisionShape.shape = shape
		$HealthComponent.max_health = specification.health
		$HealthComponent.current_health = specification.health

#Reference to the blocks that are going to be placed onto this block
@export var block_children: Array[Block] = []

#Reference to the parent block. The block where this block is placed on.
#If the block is the root block then the value is null
@export var block_parent: Block = null

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_collision_shape: CollisionShape2D = $CollisionArea/AreaCollisionShape
@onready var collision_area: Area2D = $CollisionArea

var parent_structure: Structure

func _ready() -> void:
	## Make sure parameters are synced with resource
	if specification:
		specification = specification
	
	if Engine.is_editor_hint():
		return
	
	parent_structure = $".."


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		_emit_death_particles()


func recursively_remove_blocks(destroyer: Node2D = null) -> void:
	if not multiplayer.is_server():
		return
	
	for child in self.block_children:
		child.recursively_remove_blocks(destroyer)
	
	SignalBus.block_destroyed.emit(self, destroyer)
	queue_free()

func recursively_get_all_block_children() -> Array[Block]:
	var res: Array[Block]
	
	res.append_array(block_children)
	
	for block: Block in block_children:
		if is_instance_valid(block):
			res.append_array(block.recursively_get_all_block_children())
	
	return res


func _emit_death_particles() -> void:
	var p: GPUParticles2D = DEATH_PARTICLES.instantiate()
	p.match_collision_shape(self)
	p.global_position = global_position
	p.rotation = rotation
	
	get_tree().get_current_scene().add_child.call_deferred(p)


func _on_death(killer: Node2D) -> void:
	var struct: Structure = get_parent()
	
	if struct.root_block == self:
		if not struct is Core:
			struct.queue_free()
	else:
		disabled = true
	
	struct.request_remove_block(self, killer)


func get_root_parent() -> Block:
	var current: Block = self
	while current.block_parent != null and is_instance_valid(current.block_parent):
		current = current.block_parent
	return current
