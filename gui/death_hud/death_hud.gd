extends CanvasLayer

var local_player: PlayerShip = null
@onready var countdown_label: Label = get_node("PContainer/MarginContainer/VBox/CountdownLabel")

func _ready() -> void:
	visible = false
	_find_local_player()


func _process(_delta: float) -> void:
	if local_player == null or not is_instance_valid(local_player):
		_find_local_player()
		if local_player == null:
			return
	
	if not local_player.get_node("PlayerController").dead:
		visible = false
		return
	
	visible = true
	var external_timer: Timer = local_player.get_node("RepairStateTimer")
	var timer: Timer = get_node("RepairStateTimer")
	if timer.is_stopped():
		timer.wait_time = external_timer.wait_time
		timer.start()
	countdown_label.text = "T- " + str("%0.2f" % timer.time_left)

func _find_local_player() -> void:
	for p in get_tree().get_nodes_in_group("player"):
		if p is PlayerShip and p.owner_id == multiplayer.get_unique_id():
				local_player = p
				return
