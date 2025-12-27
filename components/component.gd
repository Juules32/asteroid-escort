## Base class for all components
@icon("res://addons/plenticons/icons/64x-hidpi/2d/double-chevron-up-blue.png")
@abstract
class_name Component
extends Node


## Contains the type of the component.
## INFO: Needs to be set in _init in instantiable child classes.
## eg. func _init() -> void:
##		   type = ChildComponent
var type: Variant

## The target of component functionality
var parent: Node


func _enter_tree() -> void:
	parent = get_parent()


## WARNING: Output should be stored in a variable, since method should not be repeatedly called (performance reasons)
## USAGE: get_component(node_reference, ComponentClass)
static func get_component(_parent: Node, _type: Variant) -> Component:
	for child: Node in _parent.get_children():
		if child is Component:
			if child.type == _type:
				return child
	return null


func get_parallel_component(_type: Variant) -> Component:
	return get_component(parent, _type)
