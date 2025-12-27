@tool
extends Block
class_name BeaconBlock

var beacon_placed_on_core: bool = false

#func _physics_process(_delta: float) -> void:
#	if Engine.is_editor_hint():
#		return
