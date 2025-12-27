extends Node
class_name TutorialTask

var task_number: int = 0
var task_description: String = ""
var task_hint: String = ""


func _init(_task_number: int, _task_description: String, _task_hint: String):
	self.task_number = _task_number
	self.task_description = _task_description
	self.task_hint = _task_hint
