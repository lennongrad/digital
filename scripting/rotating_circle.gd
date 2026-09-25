extends MeshInstance3D

var rng = RandomNumberGenerator.new()

var timer = 0

@export var bring_in_x: float = 1
@export var bring_in_y: float = 1
var rotation_speed: float = 1
var parent_size: Vector2

func _ready() -> void:
	var parent_mesh: QuadMesh = get_parent().mesh
	parent_size = parent_mesh.size
	rotation_speed = rng.randf_range(0.5, 1.5)

func _process(delta: float) -> void:
	timer += delta * rotation_speed
	position.x = cos(timer) * parent_size.x / 2 * bring_in_x
	position.y = sin(timer) * parent_size.y / 2 * bring_in_y
