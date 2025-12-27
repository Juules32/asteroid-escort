## Instantiate scene
extends Controller
class_name PlayerController

@export var enable_controls: bool = false

var dead: bool = false
var toggled_drill: bool = false

@onready var drill_toggle_timer: Timer = $DrillToggleTimer

## Gamepad aiming state
var gamepad_aim_direction: Vector2 = Vector2.ZERO
var is_using_gamepad: bool = false
var _ignore_next_place_block_input = false

func _physics_process(_delta: float) -> void:
	if not enable_controls:
		return
	
	movement_input = Input.get_vector("left", "right", "up", "down")
	
	# Detect gamepad usage for aiming
	_handle_gamepad_aiming()
	
	if dead:
		return
	
	sprinting = Input.is_action_pressed("sprint")
	if sprinting:
		#Tutorial Task: Use the Sprint mechanic
		SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.BOOST)
	
	try_place_block = Input.is_action_just_pressed("place_block")
	
	#Fix so that when the player selects a different building in the buildmenu by clicking, 
	#it does not automatically build it at the same time
	if try_place_block and _ignore_next_place_block_input:
		try_place_block = false
		_ignore_next_place_block_input = false
	
	if Input.is_action_just_pressed("toggle_building_menu"):
		building_menu_enabled = !building_menu_enabled
		drill_enabled = false
		toggled_drill = false
		
		#Tutorial Tasks: Open/Close Building Menu
		if building_menu_enabled:
			SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.OPEN_BUILD_MENU)
		else:
			SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.CLOSE_BUILD_MENU)
	
	if not building_menu_enabled:
		drill_enabled = toggled_drill or Input.is_action_pressed("drill")
		if Input.is_action_just_pressed("drill"):
			if drill_toggle_timer.is_stopped():
				drill_toggle_timer.start()
			else:
				drill_toggle_timer.stop()
				toggled_drill = not toggled_drill
		if Input.is_action_just_pressed("interract"):
			SignalBus.interract.emit()
		
		if Input.is_action_just_pressed("zoom_in"):
			SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.ZOOM)
			zoom_level += 1
		if Input.is_action_just_pressed("zoom_out"):
			SignalBus.tutorial_task_completed.emit(TutorialTasks.TUTORIAL_ID.ZOOM)
			zoom_level -= 1
		zoom_level = clamp(zoom_level, -6, 6)



func _handle_gamepad_aiming() -> void:
	# Get right stick input for aiming
	var aim_x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	var aim_y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	var aim_vector = Vector2(aim_x, aim_y)
	
	# Check if gamepad is being used
	if aim_vector.length():
		is_using_gamepad = true
		gamepad_aim_direction = aim_vector.normalized()
	# If no gamepad input detected but mouse moved recently, switch to mouse
	elif Input.get_last_mouse_velocity().length() > 0:
		is_using_gamepad = false


func get_aim_direction() -> Vector2:
	# Returns the direction the player is aiming, accounting for gamepad or mouse input
	if is_using_gamepad:
		return gamepad_aim_direction
	else:
		# Return direction from player to mouse (will be calculated in block_placer)
		return Vector2.ZERO  # Signals to use mouse position


func disable_all() -> void:
	building_menu_enabled = false
	drill_enabled = false
	toggled_drill = false
