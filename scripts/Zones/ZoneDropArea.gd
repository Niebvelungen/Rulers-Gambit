extends Control

@onready var zone: BaseZone = get_parent()

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS

func can_drop_data(at_position: Vector2, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "card" and data.has("card") and data["card"] is Card

func drop_data(at_position: Vector2, data) -> void:
	if not can_drop_data(at_position, data):
		return
	var card: Card = data["card"]
	var from_zone := _find_zone_of(card)
	if from_zone and from_zone != zone:
		from_zone.remove_card(card)
	if zone:
		zone.add_card(card)

func _find_zone_of(node: Node) -> BaseZone:
	var cur: Node = node
	while cur:
		if cur is BaseZone:
			return cur
		cur = cur.get_parent()
	return null
