class_name BaseZone

extends Node2D

signal card_selected(card: Card)

var cards: Array[Card] = []

func add_card(card: Card):
	if card and card not in cards:
		cards.append(card)
		add_child(card)
		if not card.card_selected.is_connected(_on_card_selected):
			card.card_selected.connect(_on_card_selected)

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
	if cards.is_empty():
		return null
	var card: Card = cards[0]
	remove_card(card)
	return card

func _on_card_selected(card: Card) -> void:
	card_selected.emit(card)
