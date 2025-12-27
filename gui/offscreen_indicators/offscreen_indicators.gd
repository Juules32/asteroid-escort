extends CanvasLayer
class_name OffscreenIndicators

@export var offscreen_indicator: PackedScene
@export var radius: float = 150.0
@export var min_distance_to_hide: float = 150.0
@export var min_scale: float = 0.4
@export var max_scale: float = 1
@export var tutorial: TutorialUI = null

@onready var center: Control = $Center

var indicators: Dictionary = {}
var local_player: PlayerShip = null
var viewport_size_default_zoom_level: Vector2 = Vector2(640, 360)
var viewport_size: Vector2i = viewport_size_default_zoom_level

func _ready() -> void:
	_find_local_player()

func _process(_delta: float) -> void:
	if local_player == null or not is_instance_valid(local_player):
		_find_local_player()
		if local_player == null:
			return

	viewport_size = Gamedata.active_player.player_camera.get_viewport_rect().size / pow(1.07, Gamedata.active_player.controller.zoom_level)
	var indicated_nodes: Array = []
	var player = Gamedata.active_player
	
	if tutorial and tutorial.visible:
		match tutorial.current_task_id:
			TutorialTasks.TUTORIAL_ID.MOVE_CORE: 
				indicated_nodes = get_tree().get_nodes_in_group("tutorial_indicator_CORE")
			TutorialTasks.TUTORIAL_ID.BUILD_SIMPLE_BLOCK when player.controller.building_menu_enabled:
				var nodes = get_tree().get_nodes_in_group("tutorial_indicator_BUILD_MENU_ENTRY")
				for block_preview in nodes:
					if block_preview.texture == BlockPlacer.CUBE.texture:
						indicated_nodes.append(block_preview)
			TutorialTasks.TUTORIAL_ID.BUILD_LONGER_BLOCK when player.controller.building_menu_enabled:
				var nodes = get_tree().get_nodes_in_group("tutorial_indicator_BUILD_MENU_ENTRY")
				for block_preview in nodes:
					if block_preview.texture == BlockPlacer.LONG_CUBE.texture:
						indicated_nodes.append(block_preview)
			TutorialTasks.TUTORIAL_ID.CONSTRUCT_TURRET when player.controller.building_menu_enabled:
				var nodes = get_tree().get_nodes_in_group("tutorial_indicator_BUILD_MENU_ENTRY")
				for block_preview in nodes:
					if block_preview.texture == BlockPlacer.TURRET.texture:
						indicated_nodes.append(block_preview)
			TutorialTasks.TUTORIAL_ID.CONSTRUCT_THRUSTER when player.controller.building_menu_enabled:
				var nodes = get_tree().get_nodes_in_group("tutorial_indicator_BUILD_MENU_ENTRY")
				for block_preview in nodes:
					if block_preview.texture == BlockPlacer.THRUSTER.texture:
						indicated_nodes.append(block_preview)
			TutorialTasks.TUTORIAL_ID.CONSTRUCT_BEACON when player.controller.building_menu_enabled:
				var nodes = get_tree().get_nodes_in_group("tutorial_indicator_BUILD_MENU_ENTRY")
				for block_preview in nodes:
					if block_preview.texture == BlockPlacer.BEACON.texture:
						indicated_nodes.append(block_preview)
			TutorialTasks.TUTORIAL_ID.FIND_ASTEROID: 
				indicated_nodes = get_tree().get_nodes_in_group("tutorial_indicator_ASTEROID")
			TutorialTasks.TUTORIAL_ID.MINE_RESOURCE: 
				indicated_nodes = get_tree().get_nodes_in_group("tutorial_indicator_ORE")
			TutorialTasks.TUTORIAL_ID.ACTIVATE_THRUSTER: 
				indicated_nodes = get_tree().get_nodes_in_group("tutorial_indicator_THRUSTER")
			TutorialTasks.TUTORIAL_ID.ALIEN_ATTACK: 
				indicated_nodes = get_tree().get_nodes_in_group("tutorial_indicator_ALIEN")
			TutorialTasks.TUTORIAL_ID.ESCAPE_STAR_SYSTEM: 
				indicated_nodes = get_tree().get_nodes_in_group("tutorial_indicator_GOAL")
		indicated_nodes.append_array(get_tree().get_nodes_in_group("tutorial_indicated"))
	elif tutorial and not tutorial.visible and not tutorial.is_tutorial_complete(): #Start of the game
		indicated_nodes = []
	else:
		indicated_nodes = get_tree().get_nodes_in_group("indicated")
			
	var current_nodes := players_to_set(indicated_nodes)

	for node in indicators.keys():
		if not current_nodes.has(node) or not is_instance_valid(node):
			indicators[node].queue_free()
			indicators.erase(node)
			
	if indicated_nodes.is_empty():
		return

	for node in indicated_nodes:
		if node == local_player:
			continue
		if not indicators.has(node):
			var icon: OffscreenIcon = offscreen_indicator.instantiate()

			#Tutorial Indicators:
			if tutorial and tutorial.visible:
				icon.modulate = Color.RED
				icon.icon = OffscreenIcon.icons.GOAL
				if node is Core:
					icon.modulate = Color.YELLOW
					icon.icon = OffscreenIcon.icons.CORE
				elif node is BeaconBlock:
					if node.beacon_placed_on_core:
						icon.modulate = Color.YELLOW
						icon.icon = OffscreenIcon.icons.CORE
					else:
						icon.modulate = Color.SKY_BLUE
						icon.icon = OffscreenIcon.icons.BEACON
			else:
				if node is PlayerShip:
					icon.modulate = node.get_primary_color()
					icon.icon = OffscreenIcon.icons.PLAYER
				elif node is Core:
					icon.modulate = Color.YELLOW
					icon.icon = OffscreenIcon.icons.CORE
				elif node is AsteroidGoal:
					icon.modulate = Color.RED
					icon.icon = OffscreenIcon.icons.GOAL
				elif node is BeaconBlock:
					if node.beacon_placed_on_core:
						icon.modulate = Color.YELLOW
						icon.icon = OffscreenIcon.icons.CORE
					else:
						icon.modulate = Color.SKY_BLUE
						icon.icon = OffscreenIcon.icons.BEACON
				else:
					icon.modulate = Color.WHITE
			
			center.add_child(icon)
			indicators[node] = icon

	for node in indicated_nodes:
		if node == local_player:
			continue
		if not is_instance_valid(node):
			continue
		_update_indicator(node)


func _update_indicator(node: Node) -> void:
	var icon: OffscreenIcon = indicators[node]
	if not is_instance_valid(icon):
		return

	var dir: Vector2 = node.global_position - local_player.global_position
	var dist: float = dir.length()
	var camera_pos: Vector2 = local_player.get_node("PlayerCamera").get_screen_center_position()
	icon.visible = true
	
	
	#Tutorial Indicators:
	if tutorial and not tutorial.is_tutorial_complete() and not node is BeaconBlock:
		if node is AsteroidGoal and tutorial.current_task_id != TutorialTasks.TUTORIAL_ID.ESCAPE_STAR_SYSTEM:
			icon.visible = false
			return
		
		if node is TextureRect:
			var panelContainer: PanelContainer = $"../BuildingMenu/PanelContainer"
			icon.global_position = node.global_position + Vector2(0, -30)
			icon.get_node("ArrowSprite2D").rotation = 0
			if icon.global_position.x <= panelContainer.position.x or icon.global_position.x >= panelContainer.position.x + panelContainer.size.x:
				icon.visible = false
			return
		if is_within_viewport(node.global_position):
			icon.global_position = (node.global_position - camera_pos).clamp(-Vector2(viewport_size) / 2.4, Vector2(viewport_size) / 2.4) + Vector2(viewport_size) / 2
			icon.global_position *= pow(1.07, Gamedata.active_player.controller.zoom_level)
			icon.get_node("ArrowSprite2D").rotation = 0
			return

	if is_within_viewport(node.global_position):
		icon.visible = false
		return
		
		
	
	#Angle calculated based on the direction from the player position towards the target position
	var angle: float = dir.angle() - PI / 2.0
	

	icon.global_position = viewport_size_default_zoom_level / 2#(node.global_position * pow(1.07, Gamedata.active_player.controller.zoom_level) - camera_pos).clamp(-Vector2(viewport_size) / 2.4, Vector2(viewport_size) / 2.4) + Vector2(viewport_size) / 2
	var vector_player_towards_node: Vector2 = ((node.global_position - camera_pos) + viewport_size_default_zoom_level / 2) - icon.global_position
	vector_player_towards_node *= pow(1.07, Gamedata.active_player.controller.zoom_level)
	icon.global_position += (vector_player_towards_node).clamp(-viewport_size_default_zoom_level / 2.4, viewport_size_default_zoom_level / 2.4)
	
	#Angle calculated based on the direction from the icon position towards the target position
	angle = (vector_player_towards_node).angle() - PI / 2
	icon.get_node("ArrowSprite2D").rotation = angle

	var t: float = clamp(dist / (radius * 5.0), 0.0, 1.0)
	var scale_factor: float = lerp(max_scale, min_scale, t)
	icon.scale = Vector2.ONE * scale_factor


func is_within_viewport(pos: Vector2) -> bool:
	var camera_pos: Vector2 = local_player.get_node("PlayerCamera").get_screen_center_position()
	
	return (
		pos.x < camera_pos.x + viewport_size.x / 2.0 and
		pos.x > camera_pos.x - viewport_size.x / 2.0 and
		pos.y < camera_pos.y + viewport_size.y / 2.0 and
		pos.y > camera_pos.y - viewport_size.y / 2.0
	)


func is_within_viewport_border(pos: Vector2) -> bool:
	var camera_pos: Vector2 = local_player.get_node("PlayerCamera").get_screen_center_position()
	
	return (
		pos.x < camera_pos.x + viewport_size.x / 2.4 and
		pos.x > camera_pos.x - viewport_size.x / 2.4 and
		pos.y < camera_pos.y + viewport_size.y / 2.4 and
		pos.y > camera_pos.y - viewport_size.y / 2.4
	)

func _find_local_player() -> void:
	for p in get_tree().get_nodes_in_group("player"):
		if p is PlayerShip and p.owner_id == multiplayer.get_unique_id():
				local_player = p
				return


func players_to_set(players: Array) -> Dictionary:
	var result := {}
	for p in players:
		result[p] = true
	return result
