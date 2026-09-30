class_name Card
extends TextureRect

var zone: CardsManager.ZONE = CardsManager.ZONE.HAND
var suit: CardsManager.SUIT = CardsManager.SUIT.SPADES
var rank: int = 1
var shrink: bool = false

var target_position: Vector2
var speed: float

var selected: bool = false
var base_size: Vector2 = get_rect().size

func _ready() -> void:
	position = Vector2(-10000, -10000)

func set_target_position(new_target: Vector2) -> void:
	if new_target == target_position:
		return
	
	speed = (randf() + 1) * 400
	target_position = new_target

func _process(delta: float) -> void:
	if zone != CardsManager.ZONE.HAND:
		selected = false
	
	var effective_target: Vector2 = target_position - base_size / 2
	if selected:
		effective_target -= Vector2(0, 1) * 12
	
	var shrink_speed = 5
		
	if shrink:
		if (position - effective_target).length() > 10:
			shrink_speed = 1
		if scale.x > 0:
			scale.x -= delta * shrink_speed
		else:
			visible = false
	else:
		visible = true
		if scale.x < 1:
			scale.x += delta * shrink_speed
		else:
			scale.x = 1
	scale.y = scale.x
	
	if (position - effective_target).length() > 5000:
		position = effective_target
	elif (position - effective_target).length() > 50:
		position += (effective_target - position).normalized() * speed * delta
	else:
		position += (effective_target - position) * 0.1

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			selected = !selected
