extends GPUParticles2D

const AMT_AREA_RATIO: float = .15


func _ready() -> void:
	emitting = true
	$AudioStreamPlayer2D.pitch_scale = randf_range(.95, 1.05)
	
	await finished
	
	queue_free()

func match_collision_shape(collision_shape: CollisionShape2D):
	var shape: Shape2D = collision_shape.shape
	var ppm: ParticleProcessMaterial = process_material.duplicate()
	
	if shape is CircleShape2D:
		ppm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
		ppm.emission_ring_radius = shape.radius
		
		amount = (shape.radius ** 2) * PI * AMT_AREA_RATIO
	elif shape is RectangleShape2D:
		ppm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		ppm.emission_box_extents = Vector3(
			shape.size.x / 2,
			shape.size.y / 2,
			0
		)
		
		amount = shape.size.x * shape.size.y * AMT_AREA_RATIO
	else:
		push_warning("Unhandled shape type used")
	
	process_material = ppm
