extends Node2D
class_name BaseZone

var cards: Array[Node2D] = []

func add_card(card: Node2D):
	if card and card not in cards:
		cards.append(card)
		add_child(card)

func remove_card(card: Node2D):
	if card in cards:
		cards.erase(card)
		remove_child(card)
		card.queue_free()

func get_card_count() -> int:
	return cards.size()

func clear_all_cards():
	for card in cards:
		remove_child(card)
		card.queue_free()
	cards.clear()