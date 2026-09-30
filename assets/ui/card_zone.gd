extends Control

var file_filled_texture = preload("res://assets/ui/folder_opened.png")
var file_empty_texture = preload("res://assets/ui/folder_unopened.png")

@export var shrink: bool = false
@export var zone: CardsManager.ZONE = CardsManager.ZONE.HAND
@export var texture_rect: TextureRect

var cards: Array[Card] = []

func _ready() -> void:
	connect("gui_input", _on_gui_input)

func _process(delta: float) -> void:
	cards = CardsManager.get_in_zone(zone)
	
	var card_displacement = 20
	var center_position = get_global_rect().get_center()
	
	if not shrink:
		center_position -= Vector2(card_displacement * cards.size() / 2, 0)
	else:
		texture_rect.texture = file_filled_texture if cards.size() > 0 else file_empty_texture
	
	for card_index in cards.size():
		var card = cards[card_index]
		var target_position = center_position
		card.shrink = shrink
		if not shrink:
			target_position += Vector2(card_index * card_displacement, 0)
		card.set_target_position(target_position)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			if shrink:
				CardsManager.draw_card(zone)
			else:
				print(CardsManager.get_possible_hands(CardsManager.get_in_zone(zone).filter(func(card): return card.selected)))
