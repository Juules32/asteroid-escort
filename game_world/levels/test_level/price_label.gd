class_name PriceLabel
extends HBoxContainer

@export var inventory: Inventory
@export var ore: Ore.Type

@onready var texture_rect: TextureRect = $TextureRect
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var _specification: BlockSpecification


func _ready() -> void:
	SignalBus.changed_active_block.connect(_on_changed_active_block)
	texture_rect.texture = Ore.ore_resource[ore].texture

func _process(_delta: float) -> void:
	if _specification:
		if _specification.recipe.has(ore):
			rich_text_label.text = ""
			if inventory.get_amount(ore) < _specification.recipe.get(ore):
				rich_text_label.text += "[color=red]"
			rich_text_label.text += ": " + str(_specification.recipe.get(ore))
			show()
		else:
			hide()


func _on_changed_active_block(_direction: int, specification: BlockSpecification) -> void:
	_specification = specification
