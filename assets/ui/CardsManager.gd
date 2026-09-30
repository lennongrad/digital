extends Node

var card_scene = preload("res://assets/ui/card.tscn")
var base_card_material = preload("res://assets/ui/solitaire.tres")

var cards: Array[Card] = []
var card_materials: Array[Array] = []

signal reload_cards()

enum ZONE { HAND, DRAW, DISCARD }
enum SUIT { SPADES = 0, HEARTS = 1, CLUBS = 2, DIAMONDS = 3 }

func get_in_zone(zone: ZONE) -> Array[Card]:
	return cards.filter(func(card): return card.zone == zone)

func move_zone(card: Card, zone: ZONE) -> void:
	card.zone = zone

func move_zone_cards(card_arr: Array[Card], zone: ZONE) -> void:
	for card in card_arr:
		move_zone(card, zone)

func draw_card(from_zone: ZONE = ZONE.DRAW, to_zone: ZONE = ZONE.HAND) -> void:
	var arr_zone = get_in_zone(from_zone)
	
	if arr_zone.size() == 0:
		return
	
	var choice = arr_zone[randi() % arr_zone.size()]
	move_zone(choice, to_zone)

enum HAND {
	FIVE_OF_A_KIND,
	FOUR_OF_A_KIND,
	THREE_OF_A_KIND,
	PAIR,
	HIGH_CARD,
	FLUSH_FIVE,
	FLUSH_HOUSE,
	FULL_HOUSE,
	TWO_PAIR,
	FLUSH,
	STRAIGHT,
	STRAIGHT_FLUSH
}

func get_possible_hands(cards: Array) -> Array:
	var hands: Array = []

	var groups := _group_by_rank(cards)
	var suits := _group_by_suit(cards)

	# Five of a Kind
	var best_five_kind := []
	for rank in groups:
		if groups[rank].size() >= 5:
			if best_five_kind.is_empty() or rank > best_five_kind[0].rank:
				best_five_kind = groups[rank].slice(0, 5)

	if not best_five_kind.is_empty():
		hands.append({
			"type": HAND.FIVE_OF_A_KIND,
			"cards": best_five_kind
		})

	# Flush Five
	var best_flush_five := []
	for suit in suits:
		if suits[suit].size() < 5:
			continue

		var flush_groups := _group_by_rank(suits[suit])

		for rank in flush_groups:
			if flush_groups[rank].size() >= 5:
				if best_flush_five.is_empty() or rank > best_flush_five[0].rank:
					best_flush_five = flush_groups[rank].slice(0, 5)

	if not best_flush_five.is_empty():
		hands.append({
			"type": HAND.FLUSH_FIVE,
			"cards": best_flush_five
		})

	# Flush House
	var best_flush_house := []
	var best_flush_house_rank := -1

	for suit in suits:
		if suits[suit].size() < 5:
			continue

		var flush_groups := _group_by_rank(suits[suit])

		var three_rank := -1
		var pair_rank := -1

		for rank in flush_groups:
			if flush_groups[rank].size() >= 3 and rank > three_rank:
				three_rank = rank

		if three_rank == -1:
			continue

		for rank in flush_groups:
			if rank != three_rank and flush_groups[rank].size() >= 2:
				if rank > pair_rank:
					pair_rank = rank

		if pair_rank == -1:
			continue

		var candidate = (
			flush_groups[three_rank].slice(0, 3)
			+ flush_groups[pair_rank].slice(0, 2)
		)

		if three_rank > best_flush_house_rank:
			best_flush_house = candidate
			best_flush_house_rank = three_rank

	if not best_flush_house.is_empty():
		hands.append({
			"type": HAND.FLUSH_HOUSE,
			"cards": best_flush_house
		})

	# Straight Flush
	var best_straight_flush := []

	for suit in suits:
		if suits[suit].size() < 5:
			continue

		var straight := _find_straight(suits[suit])

		if straight.size() >= 5:
			if best_straight_flush.is_empty():
				best_straight_flush = straight
			elif straight[-1].rank > best_straight_flush[-1].rank:
				best_straight_flush = straight

	if not best_straight_flush.is_empty():
		hands.append({
			"type": HAND.STRAIGHT_FLUSH,
			"cards": best_straight_flush
		})

	# Four of a Kind
	var best_four_kind := []

	for rank in groups:
		if groups[rank].size() >= 4:
			if best_four_kind.is_empty() or rank > best_four_kind[0].rank:
				best_four_kind = groups[rank].slice(0, 4)

	if not best_four_kind.is_empty():
		hands.append({
			"type": HAND.FOUR_OF_A_KIND,
			"cards": best_four_kind
		})

	# Full House
	var best_full_house := []
	var best_full_house_three_rank := -1

	for three_rank in groups:
		if groups[three_rank].size() < 3:
			continue

		var pair_rank := -1

		for rank in groups:
			if rank != three_rank and groups[rank].size() >= 2:
				if rank > pair_rank:
					pair_rank = rank

		if pair_rank == -1:
			continue

		if three_rank > best_full_house_three_rank:
			best_full_house = (
				groups[three_rank].slice(0, 3)
				+ groups[pair_rank].slice(0, 2)
			)
			best_full_house_three_rank = three_rank

	if not best_full_house.is_empty():
		hands.append({
			"type": HAND.FULL_HOUSE,
			"cards": best_full_house
		})

	# Flush
	var best_flush := []

	for suit in suits:
		if suits[suit].size() >= 5:
			var candidate = suits[suit].duplicate()

			candidate.sort_custom(func(a, b):
				return a.rank > b.rank
			)

			candidate = candidate.slice(0, 5)

			if best_flush.is_empty() or _compare_high_cards(candidate, best_flush) > 0:
				best_flush = candidate

	if not best_flush.is_empty():
		hands.append({
			"type": HAND.FLUSH,
			"cards": best_flush
		})

	# Straight
	var straight := _find_straight(cards)

	if not straight.is_empty():
		hands.append({
			"type": HAND.STRAIGHT,
			"cards": straight
		})

	# Three of a Kind
	var best_three_kind := []

	for rank in groups:
		if groups[rank].size() >= 3:
			if best_three_kind.is_empty() or rank > best_three_kind[0].rank:
				best_three_kind = groups[rank].slice(0, 3)

	if not best_three_kind.is_empty():
		hands.append({
			"type": HAND.THREE_OF_A_KIND,
			"cards": best_three_kind
		})

	# Two Pair
	var pair_ranks := []

	for rank in groups:
		if groups[rank].size() >= 2:
			pair_ranks.append(rank)

	pair_ranks.sort()
	pair_ranks.reverse()

	if pair_ranks.size() >= 2:
		var two_pair = (
			groups[pair_ranks[0]].slice(0, 2)
			+ groups[pair_ranks[1]].slice(0, 2)
		)

		hands.append({
			"type": HAND.TWO_PAIR,
			"cards": two_pair
		})

	# Pair
	var best_pair := []

	for rank in groups:
		if groups[rank].size() >= 2:
			if best_pair.is_empty() or rank > best_pair[0].rank:
				best_pair = groups[rank].slice(0, 2)

	if not best_pair.is_empty():
		hands.append({
			"type": HAND.PAIR,
			"cards": best_pair
		})

	# High Card
	if not cards.is_empty():
		var highest_card = cards[0]

		for card in cards:
			if card.rank > highest_card.rank:
				highest_card = card

		hands.append({
			"type": HAND.HIGH_CARD,
			"cards": [highest_card]
		})

	return hands


func _group_by_rank(cards: Array) -> Dictionary:
	var groups := {}

	for card in cards:
		if not groups.has(card.rank):
			groups[card.rank] = []

		groups[card.rank].append(card)

	return groups


func _group_by_suit(cards: Array) -> Dictionary:
	var groups := {}

	for card in cards:
		if not groups.has(card.suit):
			groups[card.suit] = []

		groups[card.suit].append(card)

	return groups


func _find_straight(cards: Array) -> Array:
	var by_rank := {}

	for card in cards:
		by_rank[card.rank] = card

	var ranks := by_rank.keys()
	ranks.sort()

	# Ace can be low.
	# Assumes Ace = 14.
	if by_rank.has(14):
		ranks.push_front(1)

	var best := []
	var current := []

	for rank in ranks:
		if current.is_empty() or rank == current[-1] + 1:
			current.append(rank)
		else:
			current = [rank]

		if current.size() >= 5:
			best = current.slice(current.size() - 5)

	if best.size() < 5:
		return []

	var result := []

	for rank in best:
		var actual_rank = 14 if rank == 1 else rank
		result.append(by_rank[actual_rank])

	return result


func _compare_high_cards(a: Array, b: Array) -> int:
	var a_sorted := a.duplicate()
	var b_sorted := b.duplicate()

	a_sorted.sort_custom(func(x, y):
		return x.rank > y.rank
	)

	b_sorted.sort_custom(func(x, y):
		return x.rank > y.rank
	)

	for i in range(min(a_sorted.size(), b_sorted.size())):
		if a_sorted[i].rank > b_sorted[i].rank:
			return 1
		if a_sorted[i].rank < b_sorted[i].rank:
			return -1

	return 0

func play_hand() -> void:
	move_zone_cards(get_in_zone(ZONE.HAND).filter(func(card: Card): return card.selected), ZONE.DISCARD)

func _ready() -> void:
	for suit in range(4):
		var suit_array = []
		card_materials.append(suit_array)
		
		for rank in range(13):
			var new_material = base_card_material.duplicate()
			new_material.region.position = Vector2(71 * rank, 96 * suit)
			suit_array.append(new_material)
	
	for e in range(4):
		for i in range(13):
			var test_card: Card = card_scene.instantiate()
			test_card.suit = e
			test_card.rank = i
			test_card.texture = card_materials[test_card.suit][test_card.rank]
			test_card.zone = ZONE.DRAW
			cards.append(test_card)
	reload_cards.emit()
