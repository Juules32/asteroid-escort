class_name Inventory
extends Node

var _starting_items: Dictionary[Ore.Type, int] = {
	Ore.Type.IRON: 0,
	Ore.Type.GOLD: 0,
	Ore.Type.TITANIUM: 0,
}

var _op_items: Dictionary[Ore.Type, int] = {
	Ore.Type.IRON: 1000,
	Ore.Type.GOLD: 1000,
	Ore.Type.TITANIUM: 1000,
}

var items: Dictionary[Ore.Type, int] = \
	_op_items if OS.get_cmdline_args().find("--op-items") != -1 else _starting_items

func _ready() -> void:
	SignalBus.block_destroyed.connect(_on_block_destroyed)
	SignalBus.craft_block_request.connect(_on_craft_block_request)
	SignalBus.player_death.connect(_on_player_death)


func can_craft(recipe: Dictionary[Ore.Type, int]) -> bool:
	for ore: Ore.Type in recipe:
		if recipe[ore] > get_amount(ore):
			return false
	return true


func get_amount(ore: Ore.Type) -> int:
	return items.get(ore, 0)


func _modify(ore: Ore.Type, amount: int) -> void:
	_modify_server(ore, amount)


@rpc("any_peer", "call_local", "reliable")
func _modify_server(ore: Ore.Type, amount: int) -> void:
	var existing_amount: int = items.get_or_add(ore, 0)
	items[ore] = existing_amount + amount
	replicate_update(ore, existing_amount + amount, existing_amount)


@rpc("any_peer", "call_local", "reliable")
func replicate_update(ore: Ore.Type, updated_amount: int, existing_amount: int) -> void:
	items[ore] = updated_amount
	SignalBus.modified_inventory.emit(ore, updated_amount - existing_amount)


func _subtract_recipe(recipe: Dictionary[Ore.Type, int]) -> void:
	for ore: Ore.Type in recipe:
		subtract(ore, recipe[ore])


func add(ore: Ore.Type, amount: int) -> void:
	if amount < 0:
		push_error("Should never add negative amount!")
	_modify(ore, amount)


func subtract(ore: Ore.Type, amount: int) -> void:
	if amount < 0:
		push_error("Should never subtract negative amount!")

	_modify(ore, -amount)
	
	if items[ore] < 0:
		push_error("Item subtraction resulted in negative amount!")


## Destroyer represents what destroyed the block
func _on_block_destroyed(block: Block, destroyer: Node2D) -> void:
	if destroyer is PlayerShip or destroyer is TurretBlock:
		for ore: Ore.Type in block.specification.ores:
			var amount: int = block.specification.ores[ore]
			add(ore, amount)
			#Tutorial Task 4: Mine Asteroid
			SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.MINE_RESOURCE)


func _on_craft_block_request(specification: BlockSpecification) -> void:
	if can_craft(specification.recipe):
		_subtract_recipe(specification.recipe)
		SignalBus.craft_block_confirm.emit()
	else:
		$AudioStreamPlayer.play()


func _on_player_death() -> void:
	if not is_multiplayer_authority():
		return
	
	var amt: int = 8
	subtract(
		Ore.Type.IRON, 
		clamp(amt, 0, items[Ore.Type.IRON])
	)
	subtract(
		Ore.Type.GOLD,
		clamp(amt, 0, items[Ore.Type.GOLD])
	)
