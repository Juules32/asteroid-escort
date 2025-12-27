## Controller class utilizing a behaviour tree AI system
## The behaviour tree should be contructed utilizing various BehaviourTreeNodes 
## in the scenetree as children to an instance of this class
class_name BehaviorTreeController
extends Controller

@export var tick_speed: float = 0.1

var tree_root: BehaviorTreeNode
var last_tick_result : BehaviorTreeNode.response

func _ready() -> void:
	## Commenting out this code makes AI be calculated on all peers.
	## This means enemy movement becomes more fluid
	## But it also means action nodes need to take into account that they may be called from a client
	#if not is_multiplayer_authority():
		#return
	
	## Find and assign root
	for child in get_children():
		if child is BehaviorTreeNode:
			tree_root = child
	
	_initialize_tick_timer()


func _initialize_tick_timer()-> void:
	var t = Timer.new()
	t.wait_time = tick_speed
	t.autostart = true
	
	t.timeout.connect(_tick_behaviour_tree)
	
	add_child(t)


func _tick_behaviour_tree() -> void:
	movement_input = Vector2.ZERO
	
	last_tick_result = tree_root.tick()
