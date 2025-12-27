## Resource storing the information needed to create different block types
class_name BlockSpecification
extends Resource

@export var texture: Texture2D
@export var shape: Shape2D
@export var mass: float = 1
@export var health: float = 100
@export var instance_scene: PackedScene = preload("res://game_world/entities/physics/structures/blocks/block.tscn")
@export var anchors: Array[Anchor]
@export var ores: Dictionary[Ore.Type, int]
@export var recipe: Dictionary[Ore.Type, int]
@export var build_menu_description: String = ""
@export var stackable: bool = true


func get_instance() -> Block:
	var b: Block = instance_scene.instantiate()
	
	b.ready.connect(func() -> void:
		b.specification = self
		#b.sprite_2d.texture = texture
		#b.area_collision_shape.shape = shape
		#b.shape = shape
		#b.mass = mass
	)
	
	return b
