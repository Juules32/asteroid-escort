extends Node
class_name TutorialTasks


enum TUTORIAL_ID {
	MOVE_CORE,
	BOOST,
	OPEN_BUILD_MENU,
	BUILD_SIMPLE_BLOCK,
	BUILD_LONGER_BLOCK,
	CLOSE_BUILD_MENU,
	FIND_ASTEROID,
	MINE_RESOURCE,
	CONSTRUCT_TURRET,
	CONSTRUCT_THRUSTER,
	ACTIVATE_THRUSTER,
	CONSTRUCT_BEACON,
	ALIEN_ATTACK_COUNTDOWN,
	ZOOM,
	ALIEN_ATTACK,
	ESCAPE_STAR_SYSTEM,
}

var current_task: TUTORIAL_ID = TUTORIAL_ID.MOVE_CORE
var tasks: Dictionary[TUTORIAL_ID, TutorialTask] = {}
var level: Node2D = null
var tutorial_complete = false

func _init(_level: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	
	level = _level
	
	tasks[TUTORIAL_ID.MOVE_CORE] = TutorialTask.new(1, "The Core", "This is your core. You lose if the core is destroyed.\nMove into it to push it. Use WASD to move")
	tasks[TUTORIAL_ID.BOOST] = TutorialTask.new(2, "Boosting", "Fly faster by using the booster.\nPress 'Shift' to boost.")
	tasks[TUTORIAL_ID.ZOOM] = TutorialTask.new(3, "Zoom", "Use can use the mouse wheel to zoom in or out.")
	tasks[TUTORIAL_ID.FIND_ASTEROID] = TutorialTask.new(4, "Resources", "When you have used all your resources,\nfind an asteroid to get more.")
	tasks[TUTORIAL_ID.MINE_RESOURCE] = TutorialTask.new(5, "Mining", "Use your drill to mine resources.\nPress 'Right Mouse Button' to use the drill.")
	tasks[TUTORIAL_ID.OPEN_BUILD_MENU] = TutorialTask.new(6, "Open Build Menu", "You can improve the core by building on it.\nPress 'Ctrl' to open the build menu.")
	tasks[TUTORIAL_ID.BUILD_SIMPLE_BLOCK] = TutorialTask.new(7, "Build a Simple Block", "Build a simple building block on the core.\nOnly the building blocks can directly be placed onto the core.\nPress 'Left Mouse Button' to place a building.")
	tasks[TUTORIAL_ID.BUILD_LONGER_BLOCK] = TutorialTask.new(8, "Build a longer Building Block", "Building Blocks are needed as a foundation for other buildings,\nsince they can be placed on top of each other.")
	tasks[TUTORIAL_ID.CONSTRUCT_BEACON] = TutorialTask.new(9, "Constructing a Beacon", "To make sure you don't lose track of your core, build a beacon.\nThe beacon placed on the core has a unique indicator.")
	tasks[TUTORIAL_ID.CONSTRUCT_THRUSTER] = TutorialTask.new(10, "Constructing a Thruster", "To push objects, build a thruster.\nPress 'Right Mouse Button' to rotate them in any orientation.")
	tasks[TUTORIAL_ID.CLOSE_BUILD_MENU] = TutorialTask.new(11, "Close Build Menu", "In order to use some functionality, the build menu needs to be closed.\nPress 'Ctrl' again to close the build menu.")
	tasks[TUTORIAL_ID.ACTIVATE_THRUSTER] = TutorialTask.new(12, "Activate a Thruster", "Active thrusters run for 5 seconds.\nTo activate them, press 'Left Mouse Button' while you are adjacent.")
	tasks[TUTORIAL_ID.CONSTRUCT_TURRET] = TutorialTask.new(13, "Constructing a Turret", "To defend the core, build a turret.\nYou might need more resources.")
	#tasks[TUTORIAL_ID.ALIEN_ATTACK_COUNTDOWN] = TutorialTask.new(8, "WARNING: Aliens", "They are lurking everywhere, ready to attack.\nYou lose if they destroy the core.")
	tasks[TUTORIAL_ID.ALIEN_ATTACK] = TutorialTask.new(14, "WARNING: Aliens", "Aliens are lurking everywhere, ready to attack your core.\nYou lose if they destroy the core.\nKill the indicated aliens by luring them towards a turret.")
	tasks[TUTORIAL_ID.ESCAPE_STAR_SYSTEM] = TutorialTask.new(15, "Escape This Star System", "To escape, you must reach the wormhole with the core.\nPush the core there to win.")

	Gamedata.tutorial_tasks = self

func get_task(tutorial_id: TUTORIAL_ID) -> TutorialTask:
	return tasks[tutorial_id]


func total_task_count() -> int:
	return tasks.size()

func is_tutorial_complete() -> bool:
	return tutorial_complete

func set_next_task() -> void:
	if get_task(current_task).task_number == total_task_count():
		tutorial_complete = true
	
	var current_task_number = get_task(current_task).task_number
	
	for task in tasks.keys():
		if tasks[task].task_number == current_task_number + 1:
			current_task = task
