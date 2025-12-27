class_name OreLabel
extends HBoxContainer

const GREEN: String = "#84eab3"
const RED: String = "#ffb8b8"

@export var inventory: Inventory
@export var ore: Ore.Type

var modified_text: String
var recent_modified_amount: int = 0

@onready var texture_rect: TextureRect = $TextureRect
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var modified_ore_timer: Timer = $ModifiedOreTimer

func _ready() -> void:
	texture_rect.texture = Ore.ore_resource[ore].texture
	SignalBus.modified_inventory.connect(_on_modified_inventory)

func _process(_delta: float) -> void:
	rich_text_label.text = ": " + str(inventory.get_amount(ore))
	if modified_text and not modified_ore_timer.is_stopped():
		rich_text_label.text += modified_text

func _on_modified_inventory(modified_ore: Ore.Type, change: int) -> void:
	if modified_ore == ore:
		if modified_ore_timer.is_stopped():
			recent_modified_amount = change
		else:
			recent_modified_amount += change
		
		var color: String = GREEN if change >= 0 else RED
		modified_text = " [color=%s]%+d[/color]" % [color, recent_modified_amount]
		modified_ore_timer.start()
