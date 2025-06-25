extends BaseZone

class_name HandZone

func add_card(card: Control) -> void:
	cards.append(card)
	add_child(card)

	# Connect signal using Godot 4 style
	card.card_selected.connect(_on_card_selected)

	arrange_cards()

func arrange_cards() -> void:
	var spacing := 150
	for i in range(cards.size()):
		cards[i].position = Vector2(i * spacing, 0)

func _on_card_selected(card: Control) -> void:
	print("Card selected:", card)
