@tool
extends CanvasLayer
class_name TutorialUI


const SWARMER_ALIEN = preload("uid://ds5wcjhak8447")


@onready var tutorial_gui: CanvasLayer = $"."
@onready var task_number: Label = %TaskNumber
@onready var task_number_count: Label = %TaskNumberCount
@onready var task_description: Label = %TaskDescription
@onready var task_hint: Label = %TaskHint
@onready var timer_close_tutorial: Timer = %TimerCloseTutorial
@onready var success_timer: Timer = %SuccessTimer
@onready var panel_container: PanelContainer = %PanelContainer
@onready var skip_button: Button = %SkipButton

@export var level: Level1 = null


var NORMAL_BACKGROUND_COLOR: Color = Color("3c5e8b")
var SUCCESS_BACKGROUND_COLOR: Color = Color("22be33")

var resources_mined: int = 0
var aliens_killed: int = 0
var turret_position: Vector2
var turret_rotation: float
var tutorial_closes_seconds: int = 12

var tutorial_tasks: TutorialTasks = TutorialTasks.new(level)
var current_task_id: TutorialTasks.TUTORIAL_ID:
	get():
		return tutorial_tasks.current_task
var current_task: TutorialTask:
	get():
		return tutorial_tasks.tasks[current_task_id]


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if OS.get_cmdline_args().find("--skip-tutorial") != -1:
		_tutorial_completed()
		return

	
	set_task_texts()
	SignalBus.tutorial_task_completed.connect(_tutorial_task_completed)
	SignalBus.show_tutorial.connect(_on_show_tutorial)
	
	SignalBus.level_lost.connect(_hide)
	SignalBus.level_victory.connect(_hide)

func _hide(_message) -> void:
	hide()

func _on_show_tutorial() -> void:
	show()

func set_task_texts():
	task_description.text = current_task.task_description
	task_hint.text = current_task.task_hint
	if current_task_id == tutorial_tasks.TUTORIAL_ID.MINE_RESOURCE:
		task_hint.text = task_hint.text + "\n" + str(resources_mined)  + " out of 24"
	task_number.text = "TASK " + str(current_task.task_number)
	task_number_count.text = "out of " + str(tutorial_tasks.total_task_count())
	
	var style_box: StyleBoxFlat = panel_container.get_theme_stylebox("panel")
	style_box.bg_color = NORMAL_BACKGROUND_COLOR
	

func _tutorial_task_completed(_task_id: TutorialTasks.TUTORIAL_ID, _turret_position: Vector2 = Vector2.ZERO, _turret_rotation: float = 0.0) -> void:
	
	if _task_id == tutorial_tasks.TUTORIAL_ID.MINE_RESOURCE:
		resources_mined += 1
		set_task_texts()
		if resources_mined < 24:
			return
	
	if _task_id == tutorial_tasks.TUTORIAL_ID.ALIEN_ATTACK:
		aliens_killed += 1
		if aliens_killed < 4:
			return
	
	if _task_id == current_task_id and success_timer.is_stopped():
		turret_position = _turret_position
		turret_rotation = _turret_rotation
		success_timer.start()
		
		#Set Green Background color
		var style_box: StyleBoxFlat = panel_container.get_theme_stylebox("panel")
		style_box.bg_color = SUCCESS_BACKGROUND_COLOR
		
		#If all tasks completed
		if current_task.task_number == tutorial_tasks.total_task_count():
			_tutorial_completed()
		else:
			$AudioStreamPlayer.play()


func is_tutorial_complete() -> bool:
	return tutorial_tasks.is_tutorial_complete()


func _on_timer_close_tutorial_timeout() -> void:
	tutorial_closes_seconds -= 1
	skip_button.text = "Tutorial closes automatically in " + str(tutorial_closes_seconds) + " seconds."
	
	if tutorial_closes_seconds <= 0:
		#Tutorial Task 7: Push the core towards the goal
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.ESCAPE_STAR_SYSTEM)


func _on_success_timer_timeout() -> void:
	_load_next_task()
	

func _on_button_pressed() -> void:
	#_tutorial_completed()
	
	#If all tasks completed
	if current_task.task_number == tutorial_tasks.total_task_count():
		_tutorial_completed()
	else:
		_load_next_task()
	

func _tutorial_completed() -> void:
	tutorial_gui.hide()
	tutorial_tasks.tutorial_complete = true

func _load_next_task() -> void:
	tutorial_tasks.set_next_task()
	set_task_texts()
	
	#After constructing the turret: Spawn some enemies to kill
	if current_task_id == TutorialTasks.TUTORIAL_ID.ALIEN_ATTACK:
		#var player = MultiplayerSessionManager.find_current_player_node()
		#level.tutorial_swarmer_alien_1.global_position = turret_position + Vector2(-250, 0).rotated(turret_rotation)
		#level.tutorial_swarmer_alien_2.global_position = Gamedata.active_player.global_position + Vector2(-300, 0).rotated(turret_rotation)
		
		for i in range(0):
			var swarmer: SwarmerAlien = SWARMER_ALIEN.instantiate()
			swarmer.global_position = turret_position + Vector2(500, 0).rotated(TAU * i/ 10.0)
			swarmer.tutorial_enemy = true
			swarmer.add_to_group("tutorial_indicator_ALIEN")
			level.find_child("Enemies").add_child(swarmer)
		

	#The last tutorial Task is to push the core towards the goal. Close the tutorial GUI after some time
	if current_task_id == TutorialTasks.TUTORIAL_ID.ESCAPE_STAR_SYSTEM:
		timer_close_tutorial.start()
	
