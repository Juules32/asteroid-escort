extends CanvasLayer

var local_player: PlayerShip = null
var current_blockspecification: BlockSpecification = null

@export var lmb_main_image: CompressedTexture2D = null
@export var rmb_main_image: CompressedTexture2D = null
@export var lmb_build_image: CompressedTexture2D = null
@export var rmb_build_image: CompressedTexture2D = null
@export var action_icons: SpriteFrames = null
@export var inventory: Inventory = null

func _ready() -> void:
	_find_local_player()
	SignalBus.changed_active_block.connect(_on_changed_active_block)
	
	if not inventory:
		push_warning("Action control UI must have inventory variable set")
	
	if lmb_main_image:
		var first_action: TextureRect = get_node("MContainer/PContainer/MContainer/VBox/HBoxU/FirstAction")
		first_action.texture = ImageTexture.create_from_image(lmb_main_image.get_image())
	if rmb_main_image:
		var second_action: TextureRect = get_node("MContainer/PContainer/MContainer/VBox/HBoxU/SecondAction")
		second_action.texture = ImageTexture.create_from_image(rmb_main_image.get_image())
	
	if action_icons:
		var pause_icon: TextureRect = get_node("MContainer2/PContainer/MContainer/VBox/HBoxU/Pause")
		pause_icon.texture = action_icons.get_frame_texture("Settings B", 0)


func _process(_delta: float) -> void:
	if local_player == null or not is_instance_valid(local_player):
		_find_local_player()
		if local_player == null:
			return
	
	var player_controller: Controller = local_player.get_node("PlayerController")
	var panel_container: PanelContainer =  get_node("MContainer/PContainer")
	if not player_controller.building_menu_enabled:
		var sb := panel_container.get_theme_stylebox("panel")
		var sb_flat := sb.duplicate() as StyleBoxFlat
		panel_container.add_theme_stylebox_override("panel", sb_flat)
		sb_flat.bg_color = Color("#3c5e8b")
		
		if lmb_main_image:
			var first_action: TextureRect = get_node("MContainer/PContainer/MContainer/VBox/HBoxU/FirstAction")
			first_action.texture = ImageTexture.create_from_image(lmb_main_image.get_image())
			first_action.modulate = Color.WHITE
		if rmb_main_image:
			var second_action: TextureRect = get_node("MContainer/PContainer/MContainer/VBox/HBoxU/SecondAction")
			second_action.texture = ImageTexture.create_from_image(rmb_main_image.get_image())
			if player_controller.drill_enabled:
				second_action.modulate = Color.GREEN_YELLOW
			else:
				second_action.modulate = Color.WHITE
	else:
		var sb := panel_container.get_theme_stylebox("panel")
		var sb_flat := sb.duplicate() as StyleBoxFlat
		panel_container.add_theme_stylebox_override("panel", sb_flat)
		sb_flat.bg_color = Color("#253a5e")
		if lmb_build_image:
			var first_action: TextureRect = get_node("MContainer/PContainer/MContainer/VBox/HBoxU/FirstAction")
			first_action.texture = ImageTexture.create_from_image(lmb_build_image.get_image())
			if current_blockspecification and inventory.can_craft(current_blockspecification.recipe):
				first_action.modulate = Color.WHITE
			else:
				first_action.modulate = Color.RED
		if rmb_build_image:
			var second_action: TextureRect = get_node("MContainer/PContainer/MContainer/VBox/HBoxU/SecondAction")
			second_action.texture = ImageTexture.create_from_image(rmb_build_image.get_image())
			if current_blockspecification and current_blockspecification.anchors.size() > 1:
				second_action.modulate = Color.WHITE
			else:
				second_action.modulate = Color.DIM_GRAY


func _on_changed_active_block(_direction: int, _specification: BlockSpecification) -> void:
	current_blockspecification = _specification.duplicate()


func _find_local_player() -> void:
	for p in get_tree().get_nodes_in_group("player"):
		if p is PlayerShip and p.owner_id == multiplayer.get_unique_id():
				local_player = p
				return
