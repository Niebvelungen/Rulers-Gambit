class_name HandZone

extends BaseZone


@onready var cardHolder = $CardHolder

func add_card(card: Card):
	cards.append(card)
	print('adding card to hand')
	card.reparent(cardHolder)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.re_download_image()
	card.scale_card(Vector2(0.60,0.60))
	cardHolder.queue_sort()

	# Connect signal using Godot 4 style
	card.card_selected.connect(_on_card_selected)

	#arrange_cards()

func arrange_cards() -> void:
	var spacing := 150
	for i in range(cards.size()):
		cards[i].position = Vector2(i * spacing, 0)

func _on_card_selected(card: Control) -> void:
	print("Card selected:", card)
