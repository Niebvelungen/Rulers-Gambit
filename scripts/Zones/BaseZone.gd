extends Node2D

class_name BaseZone

var cards: Array[Node2D] = []

func add_card(card):
	cards.append(card)
	add_child(card)

func remove_card(card):
	if card in cards:
		cards.erase(card)
		card.queue_free()
