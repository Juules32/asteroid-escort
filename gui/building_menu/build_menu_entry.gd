@tool
class_name BuildMenuEntry
extends PanelContainer

@onready var block_preview: TextureRect = %BlockPreview

@export var block_specification: BlockSpecification
@export var building_menu: BuildingMenu
@export var building_menu_display_index: int
@export var is_current_build_selection: bool = false
@onready var gun_barrel_sprite_2d: Sprite2D = $MarginContainer2/MarginContainer2/ColorRect/BlockPreview/GunBarrelSprite2D

var current_tween: Tween = null

func _ready() -> void:
	if block_specification:
		init_block_specification()

func init_block_specification() -> void:
	if block_preview:
		block_preview.texture = block_specification.texture
	gun_barrel_sprite_2d.visible = block_specification == BlockPlacer.TURRET


func build_menu_entry_activated() -> void:	
	if not is_current_build_selection:
		if current_tween:
			current_tween.kill() # Abort the previous animation.
		#print("tween active ", block_specification.texture.resource_path.split("/")[-1])
		current_tween = create_tween()
		current_tween.tween_property(block_preview, "scale", Vector2(1.2, 1.2), 0.2)
	

func build_menu_entry_deactivated() -> void:	
	if not is_current_build_selection:
		if current_tween:
			current_tween.kill() # Abort the previous animation.
		#print("tween deactive ", block_specification.texture.resource_path.split("/")[-1])
		current_tween = create_tween()
		current_tween.tween_property(block_preview, "scale", Vector2(1.0, 1.0), 0.2)


func _on_color_rect_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("interract"):
		var player_controller: PlayerController = Gamedata.active_player.controller
		player_controller._ignore_next_place_block_input = true
		building_menu.switch_block_selection_to(block_specification, building_menu_display_index)


func _on_color_rect_mouse_entered() -> void:
	build_menu_entry_activated()


func _on_color_rect_mouse_exited() -> void:
	build_menu_entry_deactivated()
