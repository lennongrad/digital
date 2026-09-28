extends MeshInstance3D

var rng = RandomNumberGenerator.new()

@export var velocity = 0.1
var velocity_change_timer = 0

func _process(delta: float) -> void:
	mesh.surface_get_material(0).uv1_offset.x -= velocity * delta
	
	#velocity_change_timer += delta
	#if velocity_change_timer > 1:
		#velocity = rng.randf_range(0.1, 0.5)
		#velocity_change_timer = rng.randf_range(0, 0.5)
