extends Node2D
class_name Player

@export var player_id: int
@export var is_local: bool
@export var auto_draw_starting_hand: bool = false

@onready var http = $DeckRequest
@onready var hand_zone = $HandZone
@onready var field_zone = $FieldZone
@onready var graveyard_zone = $GraveyardZone
@onready var removed_zone = $RemovedZone
@onready var sideboard_zone = $SideboardZone
@onready var ruler_zone = $RulerZone
@onready var deck_zone = $DeckZone
@onready var magic_stone_deck_zone = $MagicStoneDeckZone
@onready var ui_layer: CanvasLayer = $UI

func _ready():
	_setup_ui()

func _setup_ui():
	var root := Control.new()
	root.name = "PlayerControls"
	root.anchor_left = 0.0
	root.anchor_top = 0.0
	root.anchor_right = 0.0
	root.anchor_bottom = 0.0
	root.position = Vector2(20, 20)
	ui_layer.add_child(root)

	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	root.add_child(hb)

	var btn_draw1 := Button.new()
	btn_draw1.text = "Draw 1"
	btn_draw1.pressed.connect(func(): draw(1))
	hb.add_child(btn_draw1)

	var btn_draw5 := Button.new()
	btn_draw5.text = "Draw 5"
	btn_draw5.pressed.connect(func(): draw(5))
	hb.add_child(btn_draw5)

	var btn_draw7 := Button.new()
	btn_draw7.text = "Draw 7"
	btn_draw7.pressed.connect(func(): draw(7))
	hb.add_child(btn_draw7)

	var btn_shuffle := Button.new()
	btn_shuffle.text = "Shuffle"
	btn_shuffle.pressed.connect(func(): deck_zone.shuffle())
	hb.add_child(btn_shuffle)


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
				if player_id == 1:
					card.set_is_owner(true)
				else:
					card.set_is_owner(false)
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
					elif (zoneToPut == 'Side Deck'):
						sideboard_zone.add_card(card)
					else:
						push_error("Zone not found to put card into: %s" % zoneToPut)



		
		if auto_draw_starting_hand:
			draw(5)
	else:
		push_error("JSON Parse Error: %s" % error)

func draw(count: int = 1):
	for i in range(count):
		var card = deck_zone.get_top_card()
		if card:
			hand_zone.add_card(card)
		else:
			push_warning("Deck empty, cannot draw")

