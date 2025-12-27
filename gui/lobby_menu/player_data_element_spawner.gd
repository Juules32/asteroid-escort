extends MultiplayerSpawner

func _ready() -> void:
	spawn_function = _spawn_custom

func _spawn_custom(data: Variant) -> Node:
	var node: PlayerDataElement = preload("uid://uu3ojm63ewpq").instantiate()

	if data.has("peer_id"):
		node.set_multiplayer_authority(data["peer_id"])

	if data.has("name"):
		node.player_name = data["name"]
	
	if data.has("color_index"):
		node.player_color_index = data["color_index"]
	return node
