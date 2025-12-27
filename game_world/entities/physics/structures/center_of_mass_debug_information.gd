extends Node2D

@export var structure: Structure

var center_of_mass_indicator: Line2D
var mass_indicator_text: Label

func _ready() -> void:
	## If debug collisions are disabled, then remove itself
	if not get_tree().debug_collisions_hint:
		self.queue_free()
	
	if structure == null:
		Console.print_debug("Property 'Structure' has not been set in this center_of_mass_debug_information", self)
		self.queue_free()
	
	## Show center of mass if debug collisions is enabled
	center_of_mass_indicator = Line2D.new()
	center_of_mass_indicator.points = [Vector2.ZERO, Vector2(0, 0.001)]
	center_of_mass_indicator.width = 4
	center_of_mass_indicator.modulate = Color.RED
	center_of_mass_indicator.z_index = 1
	center_of_mass_indicator.begin_cap_mode = Line2D.LINE_CAP_BOX
	center_of_mass_indicator.end_cap_mode = Line2D.LINE_CAP_BOX
	add_child(center_of_mass_indicator)
	
	mass_indicator_text = Label.new()
	mass_indicator_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mass_indicator_text.size = Vector2(100, 23)
	mass_indicator_text.z_index = 1
	#add_child(mass_indicator_text)


func _physics_process(_delta: float) -> void:
	center_of_mass_indicator.position = structure.center_of_mass
	mass_indicator_text.rotation = -1.0 * structure.rotation
	mass_indicator_text.position = structure.center_of_mass - Vector2(50, 0).rotated(-structure.rotation)
	mass_indicator_text.text = str(structure.mass).pad_decimals(2) + " kg"
