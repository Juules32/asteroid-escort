extends Node

const _SERVER_COLOR: String = "lime_green"
const _CLIENT_COLOR: String = "blue"


func _format_message(message: Variant, enable_bbcode: bool, args: Array) -> String:
	var prefix: String = "[" + get_window().title + "]: "
	if enable_bbcode:
		var color: String = _SERVER_COLOR if multiplayer.is_server() else _CLIENT_COLOR
		prefix = "[color=%s]" % color + prefix + "[/color]"
	return prefix + str(message) + "".join(args.map(str))


func print(message: Variant = "", ...args: Array) -> void:
	print_rich(_format_message(message, true, args))


func printerr(message: Variant = "", ...args: Array) -> void:
	printerr(_format_message(message, false, args))


func print_debug(message: Variant = "", ...args: Array) -> void:
	print_debug(_format_message(message, false, args))


func push_error(message: Variant = "", ...args: Array) -> void:
	push_error(_format_message(message, false, args))


func push_warning(message: Variant = "", ...args: Array) -> void:
	push_warning(_format_message(message, false, args))
