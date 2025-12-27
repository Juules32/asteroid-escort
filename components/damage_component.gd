class_name DamageComponent
extends Component

enum DamageType {
	Gradual,
	Instant
}

@export var ignored_blocks: Array[BlockSpecification] = []
@export var damage_type: DamageType = DamageType.Gradual
## If damage type is gradual this is applied each second
@export var damage_amount: float = 100

var bodies: Array[Node2D] = []
var shapes: Array[CollisionShape2D] = [] 

var check_next_frames = 0

func _init() -> void:
	type = DamageComponent
	
	set_process(damage_type == DamageType.Gradual)

func _enter_tree() -> void:
	super._enter_tree()
	
	## Parent of damage component should be an Area2D
	var parent_area: Area2D = get_parent()
	
	parent_area.body_entered.connect(_on_parent_body_entered)
	parent_area.body_exited.connect(_on_parent_body_exited)
	parent_area.body_shape_entered.connect(_on_parent_body_shape_entered)
	parent_area.body_shape_exited.connect(_on_parent_body_shape_exited)

func _process(delta: float) -> void:
	var body_remove_indexes: Array[int] = []
	var i: int = 0
	for body: Node2D in bodies:
		if is_instance_valid(body):
			deal_damage_to(body, damage_amount * delta)
		else:
			body_remove_indexes.append(i)
		i += 1
	
	var shape_remove_indexes: Array[int] = []
	i = 0
	for shape: Node2D in shapes:
		if is_instance_valid(shape):
			deal_damage_to(shape, damage_amount * delta)
		else:
			shape_remove_indexes.append(i)
		i += 1
	
	body_remove_indexes.sort_custom(_sort_descending)
	for index: int in body_remove_indexes:
		bodies.remove_at(index)
	
	shape_remove_indexes.sort_custom(_sort_descending)
	for index: int in shape_remove_indexes:
		shapes.remove_at(index)

func deal_damage_to(target: Node2D, amount: float) -> void:
	if target is Block and ignored_blocks.size() != 0:
		for block_spec in ignored_blocks:
			if target.specification == block_spec:
				return

	var hc: HealthComponent = Component.get_component(target, HealthComponent)

	if hc:
		hc.damage(amount, parent.get_parent())



func _on_parent_body_entered(body: Node2D) -> void:
	if body not in bodies:
		bodies.append(body)
		
		if damage_type == DamageType.Instant:
			deal_damage_to(body, damage_amount)

func _on_parent_body_exited(body: Node2D) -> void:
	if body in bodies:
		bodies.erase(body)

func _on_parent_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	var body_shape_owner = body.shape_find_owner(body_shape_index)
	var body_shape_node: CollisionShape2D = body.shape_owner_get_owner(body_shape_owner)
	
	if body_shape_node not in shapes:
		shapes.append(body_shape_node)
	
		if damage_type == DamageType.Instant:
			deal_damage_to(body_shape_node, damage_amount)


func _on_parent_body_shape_exited(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	if not body:
		return
	
	if _get_shape_count(body) > body_shape_index:
		var body_shape_owner = body.shape_find_owner(body_shape_index)
		var body_shape_node: CollisionShape2D = body.shape_owner_get_owner(body_shape_owner)
		
		if body_shape_node in shapes:
			shapes.erase(body_shape_node)


func _get_shape_count(body: Node2D) -> int:
	var num: int = 0
	for child in body.get_children():
		if child is CollisionShape2D:
			num += 1
	
	return num

func _sort_descending(a, b):
	if a > b:
		return true
	return false
