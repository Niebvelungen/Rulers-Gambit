extends BaseZone
class_name DeckZone

func shuffle():
	cards.shuffle()

func add_to_top(card: Card):
	if card == null:
		return
	if card in cards:
		cards.erase(card)
	if card.get_parent() != self:
		card.reparent(self)
	cards.push_front(card)

func get_top_card():
	if cards.is_empty():
		return null
	var card: Card = cards.pop_back()
	remove_child(card)
	return card

