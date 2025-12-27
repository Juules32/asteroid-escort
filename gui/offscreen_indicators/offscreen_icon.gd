extends Node2D
class_name OffscreenIcon

enum icons {
	PLAYER,
	CORE,
	BEACON,
	GOAL
}

var icon : icons = icons.PLAYER

@onready var sprite: Sprite2D = $ArrowSprite2D

func set_color(c: Color) -> void:
	if sprite:
		sprite.modulate = c

func _ready():
	$IconSprite2D.region_rect.position.x = 16 * icon
