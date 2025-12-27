class_name Ore
extends Node

enum Type {
	IRON,
	GOLD,
	TITANIUM,
}

const ore_resource: Dictionary[Ore.Type, Resource] = {
	Type.IRON: preload("uid://cuuhgyl2swbsf"),
	Type.GOLD: preload("uid://igjpsbrv31ms"),
	Type.TITANIUM: preload("uid://ipm86suvjce6"),
}
