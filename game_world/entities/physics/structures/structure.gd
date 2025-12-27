## This class represents any physics object in the world that can be built on
## Structures comprise of one or multiple Blocks.
class_name Structure
extends SynchronizedRigidbody2D

const TEST_BLOCK_SPEC_PATH: String = "res://game_world/entities/physics/structures/blocks/block_specifications/test_block_specification.tres"
const BEACON_SPEC_PATH: String = "res://game_world/entities/physics/structures/blocks/block_specifications/beacon.tres"

## If EntitySpawner is not suitable, create a new type of spawner that is
@export var block_spawner: MultiplayerSpawner

#The root block of the structure. Any other blocks are placed onto this block
@export var root_block: Block

func request_add_block(block_spec_path: String, block_position: Vector2, block_rotation: float) -> void:
	if is_multiplayer_authority():
		request_add_block(block_spec_path, block_position, block_rotation)
	else:
		request_add_block(block_spec_path, block_position, block_rotation)

@rpc("any_peer", "call_remote", "reliable")
func _request_add_block(block_spec_path: String, block_position: Vector2, block_rotation: float, block_parent: Block) -> void:
	if not is_multiplayer_authority():
		return
	
	_add_block(block_spec_path, block_position, block_rotation, block_parent)

func _add_block(block_spec_path: String, block_position: Vector2, block_rotation: float, block_parent: Block) -> void:
	_update_mass_distribution_with_block(block_spec_path, block_position)
	
	var spawned_block = block_spawner.spawn_block(block_spec_path, block_position, block_rotation)
	
	if block_parent:
		spawned_block.block_parent = block_parent
		block_parent.block_children.append(spawned_block)
	else:
		root_block = spawned_block

	#Check if the beacon was placed on the core
	if block_spec_path == BEACON_SPEC_PATH and root_block.get_parent() is Core:
		spawned_block.beacon_placed_on_core = true

func _update_mass_distribution_with_block(block_spec_path: String, block_position: Vector2) -> void:
	var block_spec: BlockSpecification = ResourceLoader.load(block_spec_path)
	
	_add_block_to_mass(block_spec.mass, block_position)


@rpc("authority", "call_local", "reliable")
func _add_block_to_mass(block_spec_mass: float, block_position: Vector2) -> void:
	center_of_mass = (
		mass * center_of_mass +
		block_spec_mass * block_position
	) / (
		mass + block_spec_mass
	)
	mass += block_spec_mass


@rpc("any_peer", "call_remote", "reliable")
func request_remove_block(block_to_be_removed: Block, destroyer: Node2D = null) -> void:
	if not is_multiplayer_authority():
		return
		
	#Do not allow to remove the root block of the core
	if self is Core and block_to_be_removed == root_block:
		return
	
	if block_to_be_removed.block_parent:
		block_to_be_removed.block_parent.block_children.erase(block_to_be_removed)
		
	block_to_be_removed.recursively_remove_blocks(destroyer)
	
	recalculate_mass()

func recalculate_mass() -> void:
	var weighted_center: Vector2 = root_block.position * root_block.mass
	var _mass = root_block.mass
	
	var blocks: Array[Block] = root_block.recursively_get_all_block_children()
	
	for block: Block in blocks:
		weighted_center += block.position * block.mass
		_mass += block.mass
	
	_update_mass(_mass, weighted_center / _mass)

@rpc("authority", "call_local", "reliable")
func _update_mass(_mass: float, _center_of_mass: Vector2) -> void:
	mass = _mass
	center_of_mass = _center_of_mass
