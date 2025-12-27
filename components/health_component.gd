class_name HealthComponent
extends Component

signal death
signal damage_taken

@export var max_health: float = 100
@export var regen_rate: float = 20
@export var regen_delay: float = 5

var current_health: float

var regen_timer: Timer
var regen_enabled: bool = true

var debug_text_current_health: Label

func _init() -> void:
	type = HealthComponent
	
	set_physics_process(false)
	
	
func _ready() -> void:
	if get_tree().debug_collisions_hint:
		debug_text_current_health = Label.new()
		debug_text_current_health.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		debug_text_current_health.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		debug_text_current_health.size = Vector2(200, 200)
		debug_text_current_health.position = Vector2(-100, -100)
		debug_text_current_health.z_index = 1
		add_child(debug_text_current_health)

func _enter_tree() -> void:
	super._enter_tree()
	
	if parent.has_method("_on_death"):
		death.connect(parent._on_death)
	
	current_health = max_health
	
	regen_timer = Timer.new()
	
	regen_timer.wait_time = regen_delay
	regen_timer.one_shot = true
	regen_timer.timeout.connect(_on_regen_timer_timeout)
	
	add_child(regen_timer)

func _physics_process(delta: float) -> void:
	if regen_enabled:
		current_health = clamp(
			current_health + delta * regen_rate,
			0,
			max_health
	)
	
	if get_tree().debug_collisions_hint:
		debug_text_current_health.text = str(int(current_health))
		debug_text_current_health.position = $"..".global_position + Vector2(-100, -100)

func damage(amount: float, damager: Node2D) -> void:
	if current_health <= 0:
		return
	
	if amount > 0:
		damage_taken.emit()
	
	current_health -= amount
	
	regen_timer.start()
	regen_enabled = false
	
	if current_health <= 0:
		death.emit(damager)

func _on_regen_timer_timeout() -> void:
	regen_enabled = true
