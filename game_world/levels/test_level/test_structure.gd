## INFO: Temporary script, only for testing basics about structures and blocks
@tool
extends Structure



## Tests manually adding a block as a child of a Structure.
## When this is properly implemented this should be done through methods in the Structure class
## NOTE: From testing this class i learned that Godot requires all collision shapes
## to be a direct child of the collision object it is part of
func _on_test_level_players_loaded() -> void:
	_request_add_block(TEST_BLOCK_SPEC_PATH, Vector2.ZERO, 0, null)
	_request_add_block(TEST_BLOCK_SPEC_PATH, Vector2(0, 16), 0, null)
	_request_add_block(TEST_BLOCK_SPEC_PATH, Vector2(16, 0), 0, null)
