extends Camera3D

@export var camera: Camera3D

func _process(delta: float) -> void:
	if camera:
		# Match the full global transform (position and rotation)
		global_transform = camera.global_transform
		fov = camera.fov
		near = camera.near
		far = camera.far
