@tool
class_name AbstractAsteroid
extends Structure

const ASTEROID_SMALL_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://bh8q3lgb0f36e")
const ASTEROID_MIDDLE_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://behg7t4qic1as")
const ASTEROID_BIG_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://c4hg74vbvt7ri")
const ASTEROID_BIGGER_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://cetffubeo48a3")
const ASTEROID_BIGGEST_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://4t2afdvxg3kn")
const ASTEROID_GINORMOUS_BLOCK_SPECIFICATION: BlockSpecification = preload("uid://cn3qfvxpfiev3")



enum ASTEROID_TYPE {
	RANDOM,
	SMALL,
	MIDDLE,
	BIG,
	BIGGER,
	BIGGEST,
	GINORMOUS,
}

const RANDOM_ASTEROIDS: Array[BlockSpecification] = [
	ASTEROID_SMALL_BLOCK_SPECIFICATION,
	ASTEROID_MIDDLE_BLOCK_SPECIFICATION,
	ASTEROID_BIG_BLOCK_SPECIFICATION,
]

const ORE_IRON: BlockSpecification = preload("uid://cuuhgyl2swbsf")
const ORE_GOLD: BlockSpecification = preload("uid://igjpsbrv31ms")
const ORE_PLATINUM: BlockSpecification = preload("uid://dsvg8g1rkhpou")
const ORE_TITANIUM: BlockSpecification = preload("uid://ipm86suvjce6")

const ORES: Array[BlockSpecification] = [
	ORE_IRON,
	ORE_GOLD,
	ORE_TITANIUM,
]

const ORE_DISTANCE_THRESHOLD: float = 20.0

@export var max_ores: int = 3
@export var highly_valuable_asteroid: bool = false
@export var asteroid_type: ASTEROID_TYPE = ASTEROID_TYPE.RANDOM
@export var predefined_ores: Dictionary[Ore.Type, int] = {}

var _root_asteroid_block:Block

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	var random_asteroid_specification: BlockSpecification 
	match asteroid_type:
		ASTEROID_TYPE.RANDOM: random_asteroid_specification = RANDOM_ASTEROIDS[randi() % RANDOM_ASTEROIDS.size()]
		ASTEROID_TYPE.SMALL: random_asteroid_specification = ASTEROID_SMALL_BLOCK_SPECIFICATION
		ASTEROID_TYPE.MIDDLE: random_asteroid_specification = ASTEROID_MIDDLE_BLOCK_SPECIFICATION
		ASTEROID_TYPE.BIG: random_asteroid_specification = ASTEROID_BIG_BLOCK_SPECIFICATION
		ASTEROID_TYPE.BIGGER: random_asteroid_specification = ASTEROID_BIGGER_BLOCK_SPECIFICATION
		ASTEROID_TYPE.BIGGEST: random_asteroid_specification = ASTEROID_BIGGEST_BLOCK_SPECIFICATION
		ASTEROID_TYPE.GINORMOUS: random_asteroid_specification = ASTEROID_GINORMOUS_BLOCK_SPECIFICATION
	
	var random_asteroid_resource_path = random_asteroid_specification.resource_path
	_request_add_block(random_asteroid_resource_path, Vector2.ZERO, 0, null)

	if is_multiplayer_authority():
		if predefined_ores.size() > 0:
			_add_predefined_ores(random_asteroid_specification)
		elif highly_valuable_asteroid:
			_add_highly_valuable_ores(random_asteroid_specification)
		else:
			_add_random_ores(random_asteroid_specification)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if !_root_asteroid_block and $".".root_block:
		_root_asteroid_block = $".".root_block
		var health_component = _root_asteroid_block.find_child("HealthComponent")
		$HealthbarOverlay.health_component = health_component
		$HealthbarOverlay._initial_position.y =  - 20 -  int(_root_asteroid_block.shape.radius)


func _add_random_ores(asteroid_specification: BlockSpecification) -> void:
	var asteroid_block: Block = get_child(-1)
	var random_ore_index = (randi() % (ORES.size() + 1)) % ORES.size()
	var random_ore: BlockSpecification = ORES[random_ore_index]
	var num_ores: int = randi() % (max_ores + 1)
	var previous_positions: Array[Vector2] = []
	for _i: int in range(num_ores):
		var first_achor: Anchor = random_ore.anchors.get(0)
		var radius: float = (asteroid_specification.shape as CircleShape2D).radius + first_achor.point.y
		var random_rotation: float = randf_range(0, TAU)
		var ore_position: Vector2 = \
			Vector2(cos(random_rotation), sin(random_rotation)) * radius
		var skip_ore: bool = false
		for previous_position: Vector2 in previous_positions:
			if previous_position.distance_to(ore_position) <= ORE_DISTANCE_THRESHOLD:
				skip_ore = true
		if skip_ore:
			continue
		previous_positions.append(ore_position)
		#Gamedata.total_resource_count[random_ore_index] += 1
		_request_add_block(
			random_ore.resource_path,
			ore_position,
			random_rotation - first_achor.normal,
			asteroid_block
		)

func _add_predefined_ores(asteroid_specification: BlockSpecification) -> void:
	var asteroid_block: Block = get_child(-1)
	var previous_positions: Array[Vector2] = []
	for ore_type in predefined_ores.keys():
		var ore_amount = predefined_ores[ore_type]
		var random_ore: BlockSpecification = ORES[ore_type]
		var ore_amount_placed = 0
		while ore_amount_placed < ore_amount:
			var first_achor: Anchor = random_ore.anchors.get(0)
			var radius: float = (asteroid_specification.shape as CircleShape2D).radius + first_achor.point.y
			var random_rotation: float = randf_range(0, TAU)
			var ore_position: Vector2 = \
				Vector2(cos(random_rotation), sin(random_rotation)) * radius
			var skip_ore: bool = false
			for previous_position: Vector2 in previous_positions:
				if previous_position.distance_to(ore_position) <= ORE_DISTANCE_THRESHOLD:
					skip_ore = true
			if skip_ore:
				continue
			previous_positions.append(ore_position)
			ore_amount_placed += 1
			#Gamedata.total_resource_count[ore_type] += 1
			_request_add_block(
				random_ore.resource_path,
				ore_position,
				random_rotation - first_achor.normal,
				asteroid_block
			)
	for ores in asteroid_block.block_children:
		ores.add_to_group("tutorial_indicator_ORE")



func _add_highly_valuable_ores(asteroid_specification: BlockSpecification) -> void:
	var asteroid_block: Block = get_child(-1)
	var num_ores: int = max_ores
	if highly_valuable_asteroid:
		num_ores = max_ores
	var previous_positions: Array[Vector2] = []
	var random_rotation: float = 0
	for _i: int in range(num_ores):
		var random_ore_index = randi() % ORES.size()
		var random_ore: BlockSpecification = ORES[random_ore_index]
		var first_achor: Anchor = random_ore.anchors.get(0)
		var radius: float = (asteroid_specification.shape as CircleShape2D).radius + first_achor.point.y
		random_rotation += TAU / max_ores - randf_range(-0.2, 0.2)
		var ore_position: Vector2 = \
			Vector2(cos(random_rotation), sin(random_rotation)) * radius
		previous_positions.append(ore_position)
		#Gamedata.total_resource_count[random_ore_index] += 1
		_request_add_block(
			random_ore.resource_path,
			ore_position,
			random_rotation - first_achor.normal,
			asteroid_block
		)


func get_block() -> Block:
	return get_node("Block")
	
