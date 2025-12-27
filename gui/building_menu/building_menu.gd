class_name BuildingMenu
extends CanvasLayer

const SCROLL_SPEED: float = 30.0
const BLOCK_PREVIEW_WIDTH: int = 64
const BLOCK_PREVIEW_SELECTION_WIDTH: int = 100
const UNSELECTED_BUILD_MENU_MODULATE_COLOR: Color = Color("808080")
const BUILD_MENU_ENTRY = preload("uid://cddceqom3vvlj")
const PRICE_LABEL: PackedScene = preload("uid://cm6w16tq47xyg")
const ORE_LABEL: PackedScene = preload("uid://dj8vpahs2fe8y")

@onready var current_x: float = 0
@onready var target_x: int = 0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ore_label_container: VBoxContainer = $OreLabelContainer
@onready var h_box_container: HBoxContainer = %HBoxContainer
@onready var color_rect: ColorRect = %ColorRect
@onready var price_label_container: HBoxContainer = %PriceLabelContainer
@onready var free_label: Label = %FreeLabel
@onready var item_description: Label = %ItemDescription
@onready var panel_container: PanelContainer = %PanelContainer


@export var inventory: Inventory

var _player: PlayerShip
var _specification: BlockSpecification
var start_x_offset: int
var h_box_container_size: Vector2
var right_edge: int
var build_menu_entry_list: Array[BuildMenuEntry] = []
var triple_build_menu_entry_list: Array[BuildMenuEntry] = []

func _ready() -> void:	
	#Default state of build menu is off:
	panel_container.visible = false
	
	SignalBus.build_mode_changed.connect(_on_build_mode_changed)
	
	#Initialize the cost visualization for the different blocks
	SignalBus.changed_active_block.connect(_on_changed_active_block)
	for ore: Ore.Type in range(len(Ore.Type)) as Array[Ore.Type]:
		var price_label: PriceLabel = PRICE_LABEL.instantiate()
		price_label.visible = false
		price_label.inventory = inventory
		price_label.ore = ore
		price_label_container.add_child(price_label)
		
		var ore_label: OreLabel = ORE_LABEL.instantiate()
		ore_label.inventory = inventory
		ore_label.ore = ore
		ore_label_container.add_child(ore_label)
	
	#Add the different blocks to the build menu. 
	#(Add each block 3 times so that we can 'rotate' through them)
	for _i: int in range(3):
		for block_specification: BlockSpecification in BlockPlacer.BLOCK_SPECIFICATIONS:
			var build_menu_entry: BuildMenuEntry = BUILD_MENU_ENTRY.instantiate()
			build_menu_entry.block_specification = block_specification
			build_menu_entry.building_menu = $"."
			build_menu_entry.building_menu_display_index = _i
			h_box_container.add_child(build_menu_entry)
			build_menu_entry.init_block_specification()
			
			triple_build_menu_entry_list.append(build_menu_entry)
			if _i == 1 or (_i == 2 and block_specification == BlockPlacer.BLOCK_SPECIFICATIONS[0]):
				build_menu_entry_list.append(build_menu_entry)
			else:
				build_menu_entry.modulate = UNSELECTED_BUILD_MENU_MODULATE_COLOR
				build_menu_entry.z_index = 0
	
	#Initialize the position of the HBoxContainer (Which is the one that changes position when rotating through the build menu)
	right_edge = (len(BlockPlacer.BLOCK_SPECIFICATIONS)) * BLOCK_PREVIEW_WIDTH #+ (BLOCK_PREVIEW_SELECTION_WIDTH - BLOCK_PREVIEW_WIDTH)
	start_x_offset = int(len(BlockPlacer.BLOCK_SPECIFICATIONS) * BLOCK_PREVIEW_WIDTH * 0.5) - int(BLOCK_PREVIEW_WIDTH  * 0.5)

func _on_build_mode_changed(enabled: bool) -> void:
	if not enabled:
		animation_player.play("close_build_menu")
	else:
		animation_player.play("open_build_menu")


func _on_changed_active_block(_direction: int, specification: BlockSpecification) -> void:
	_specification = specification
	target_x +=  _direction * BLOCK_PREVIEW_WIDTH
	set_build_menu_description()
	set_build_menu_entry_style()


func _process(delta: float) -> void:
	if !_player:
		_player = MultiplayerSessionManager.find_current_player_node()

	#Find the current middle of the build menu container
	var h_box_middle_pos = (color_rect.size - h_box_container.size) / 2

	#print(current_x, " ", right_edge)
	#Move the HBox Conainer to visualize the rotation through the build menu
	current_x = lerpf(current_x, target_x, 1 - exp(delta * -SCROLL_SPEED))
	if current_x >= right_edge:
		current_x = 0 
		target_x = target_x % right_edge
	if current_x < 0:
		current_x = right_edge
		target_x = right_edge + (target_x % right_edge)
	h_box_container.position.x = h_box_middle_pos.x - current_x + start_x_offset


func set_build_menu_description(new_description: String = "") -> void:
	if new_description == "":
		item_description.text = _specification.build_menu_description
	else:
		item_description.text = new_description


func set_build_menu_entry_style() -> void:
	#Set all build menu entries to normal 'not selected'
	for entry in triple_build_menu_entry_list:
		if entry.current_tween:
			entry.current_tween.kill()
		entry.is_current_build_selection = false
		entry.block_preview.scale = Vector2.ONE
		entry.custom_minimum_size.x = BLOCK_PREVIEW_WIDTH
		entry.modulate = UNSELECTED_BUILD_MENU_MODULATE_COLOR
		entry.z_index = 0

	
	#Change the display of the one build menu entry that is currently selected
	for entry in build_menu_entry_list:
		if entry.block_specification == _specification:			
			entry.is_current_build_selection = true
			entry.block_preview.scale = Vector2(1.6, 1.6)
			entry.custom_minimum_size.x = BLOCK_PREVIEW_SELECTION_WIDTH
			entry.modulate = Color.WHITE
			entry.z_index = 1
	
	#The first Block of BLOCK_SPECIFICATIONS is isplayed with 2 different entry and needs to be switched between
	if _specification == BlockPlacer.BLOCK_SPECIFICATIONS[0]:
		var entry: BuildMenuEntry
		if target_x >= right_edge:
			entry = build_menu_entry_list[0]
		else:
			entry = build_menu_entry_list[-1]
		entry.is_current_build_selection = false
		entry.block_preview.scale = Vector2.ONE
		entry.custom_minimum_size.x = BLOCK_PREVIEW_WIDTH
		entry.modulate = UNSELECTED_BUILD_MENU_MODULATE_COLOR
		entry.z_index = 0
		

func switch_block_selection_to(new_block_specification: BlockSpecification, build_menu_index: int) -> void:
	var current_block_specification_index = BlockPlacer.BLOCK_SPECIFICATIONS.find(new_block_specification)
	var new_block_specification_index = BlockPlacer.BLOCK_SPECIFICATIONS.find(_specification)
	
	if new_block_specification_index >= 0:
		var index_diff = current_block_specification_index - new_block_specification_index
		
		#Depending on which side the building block is compared to the currently selected one, the movement animation needs to be a specific movement
		match build_menu_index:
			0: index_diff -= len(BlockPlacer.BLOCK_SPECIFICATIONS)
			2: index_diff += len(BlockPlacer.BLOCK_SPECIFICATIONS)
			
		#The player needs to know the change, so that the building preview can update
		if _player:
			_player.switch_block_selection_to(new_block_specification, index_diff)
