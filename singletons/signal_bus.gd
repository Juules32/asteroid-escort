extends Node

@warning_ignore_start("unused_signal")
signal block_destroyed(block: Block)
signal changed_active_block(direction: int, specification: BlockSpecification)
signal craft_block_request(specification: BlockSpecification)
signal craft_block_confirm
signal build_mode_changed(enabled: bool)
signal player_death
signal player_repair
signal interract
signal level_victory(message: String)
signal level_lost(message: String)
signal game_started
signal tutorial_task_completed(_task_id: int, _turret_position: Vector2, turret_rotation: float)
signal show_tutorial
signal modified_inventory(ore: Ore.Type, change: int)
