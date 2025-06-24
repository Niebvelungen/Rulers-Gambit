extends Node
class_name Player

@export var player_id: int
@export var is_local: bool

@onready var http = $DeckRequest
@onready var hand_zone = $HandZone
@onready var field_zone = $FieldZone
@onready var graveyard_zone = $GraveyardZone
@onready var removed_zone = $RemovedZone
@onready var sideboard_zone = $SideboardZone
@onready var ruler_zone = $RulerZone
@onready var deck_zone = $DeckZone
@onready var magic_stone_deck_zone = $MagicStoneDeckZone

func get_zone(zone_name: String) -> Node:
	match zone_name.to_lower():
		"hand": return hand_zone
		"field": return field_zone
		"graveyard": return graveyard_zone
		"deck": return deck_zone
		"removed": return removed_zone
		"ruler": return ruler_zone
		_: return null

func load_deck(url: String):
	http.request_completed.connect(_on_deck_response)
	# Replace with your actual API endpoint
	http.request(url)
	
	
func _on_deck_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var body_text := body.get_string_from_utf8()
	var json = JSON.new()
	var error = json.parse(body_text)

	if error == OK:
		var result_data = json.get_data()
		for card_entry in result_data["cards"]:
			for i in range(card_entry["quantity"]):
				var card_scene = preload("res://scenes/Card.tscn")
				var card = card_scene.instantiate()
				card.owner_id = player_id
				card.controller_id = player_id
				
				card.set_image_url(card_entry['img'])
				var zoneToPut = card_entry['zone']
				if typeof(zoneToPut) == TYPE_STRING:
					if (zoneToPut.contains('Main Deck')):
						deck_zone.add_card(card)
					elif (zoneToPut == 'Ruler'):
						ruler_zone.add_card(card)
					elif (zoneToPut == 'Magic Stone Deck'):
						magic_stone_deck_zone.add_card(card)
					elif (zoneToPut == 'Sideboard Deck'):
						sideboard_zone.add_card(card)
					else:
						push_error("Zone not found to put card into: %s" % zoneToPut)
	else:
		push_error("JSON Parse Error: %s" % error)
