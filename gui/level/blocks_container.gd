extends HBoxContainer

const SCROLL_SPEED: float = 30.0
const BLOCK_PREVIEW_WIDTH: int = 64
const BLOCK_PREVIEW: Resource = preload("uid://upe3jbi3k54l")

@onready var current_x: float = 0
@onready var target_x: int = 0
@onready var block_placement_ui: ColorRect = $".."

var start_x: int
var right_edge: int

func _ready() -> void:
	SignalBus.changed_active_block.connect(_on_changed_active_block)

	for _i: int in range(3):
		for block_specification: BlockSpecification in BlockPlacer.BLOCK_SPECIFICATIONS:
			var block_preview: TextureRect = BLOCK_PREVIEW.instantiate()
			block_preview.texture = block_specification.texture
			add_child(block_preview)
	
	right_edge = (len(BlockPlacer.BLOCK_SPECIFICATIONS)) * BLOCK_PREVIEW_WIDTH
	start_x = int((block_placement_ui.size.x - BLOCK_PREVIEW_WIDTH) / 2) - len(BlockPlacer.BLOCK_SPECIFICATIONS) * BLOCK_PREVIEW_WIDTH

func _on_changed_active_block(direction: int, _specification: BlockSpecification) -> void:
	target_x += direction * BLOCK_PREVIEW_WIDTH

func _process(delta: float) -> void:
	current_x = lerpf(current_x, target_x, 1 - exp(delta * -SCROLL_SPEED))
	if current_x > right_edge:
		current_x = 0
		target_x = target_x % right_edge
	if current_x < 0:
		current_x = right_edge
		target_x = right_edge + (target_x % right_edge)
	position.x = start_x - current_x
