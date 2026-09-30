extends Control

func _init() -> void:
	CardsManager.reload_cards.connect(_reload_cards)

func _reload_cards():
	for child in get_children():
		remove_child(child)
	for card in CardsManager.cards:
		add_child(card)
		
