@tool
extends Node2D

## Should be in order from darkest to lightest
@export var colors: Array[Color] = [
		Color("#241527"),
		Color("#402751"),
		Color("#7a367b"),
		Color("#c65197"),
		Color("#df84a5")
] :
	set(value):
		colors = value
		if Engine.is_editor_hint():
			update_shader_colors()

var color_presets: Array[Array] = [
	[
		Color("#253a5e"),
		Color("#3c5e8b"),
		Color("#4f8fba"),
		Color("#73bed3"),
		Color("#a4dddb"),
	],
	[
		Color("#19332d"),
		Color("#25562e"),
		Color("#468232"),
		Color("#a8ca58"),
		Color("#d0da91"),
	],
	[
		Color("#341c27"),
		Color("#4d2b32"),
		Color("#7a4841"),
		Color("#c09473"),
		Color("#d7b594"),
	],
	[
		Color("#411d31"),
		Color("#752438"),
		Color("#a53030"),
		Color("#cf573c"),
		Color("#da863e"),
	],
	[
		Color("#241527"),
		Color("#402751"),
		Color("#7a367b"),
		Color("#c65197"),
		Color("#df84a5")
	]
]

func set_color_preset(index: int) -> bool:
	if index >= color_presets.size():
		return false
	else:
		var preset = color_presets[index]
		var new_colors: Array[Color] = []
		for c in preset:
			new_colors.append(c)
		colors = new_colors
		update_shader_colors()
		return true


var alpha: float = 1 :
	set(value):
		alpha = value
		update_shader_colors()

func _ready() -> void:
	$Body.material = $Body.material.duplicate()
	$Drill.material = $Body.material
	
	update_shader_colors()

func update_shader_colors() -> void:
	var shader: Material = $Body.material
	
	var i: int = 0
	for color: Color in colors:
		color.a = alpha
		shader.set_shader_parameter("color%s_replacement" % (i + 1), color)
		i += 1
