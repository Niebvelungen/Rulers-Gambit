class_name BaseZone

extends Node2D

var cards: Array[Card] = []

func add_card(card: Card):
	if card and card not in cards:
		cards.append(card)
		add_child(card)

func remove_card(card: Card):
	if card in cards:
		cards.erase(card)
		remove_child(card)

func get_card_count() -> int:
	return cards.size()

func clear_all_cards():
	for card in cards:
		remove_child(card)
		card.queue_free()
	cards.clear()

func get_top_card():
	var card = cards.pop_front()
	if(card == null):
		return card
	remove_card(card)
	return card
