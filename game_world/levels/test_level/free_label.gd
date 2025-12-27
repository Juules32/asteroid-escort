extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.changed_active_block.connect(_on_changed_active_block)

func _on_changed_active_block(_direction: int, specification: BlockSpecification) -> void:
	visible = specification.recipe.is_empty()
