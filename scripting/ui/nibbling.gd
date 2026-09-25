extends Control

var rng = RandomNumberGenerator.new()

@export var label: Label
@export var hbox: HBoxContainer
@export var gear: TextureRect

var numbers = [1,2,3,4,5,6,7,8]
var bars = []
var timer = 0

func _ready() -> void:
	for bar in hbox.get_children():
		print(bar)
		bars.append(bar)

func _process(delta: float) -> void:
	timer += delta
	
	gear.offset_transform_rotation -= delta * 0.2
	
	if timer > 0.05:
		timer = 0
		for number_index in numbers.size():
			if rng.randf() < 0.5:
				numbers[number_index] += rng.randi_range(-1, 1)
				if numbers[number_index] < 0:
					numbers[number_index] += 10
				if numbers[number_index] >= 10:
					numbers[number_index] -= 10
			bars[number_index].value = numbers[number_index] * 10
		
		label.text = "".join(numbers)
