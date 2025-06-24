extends Node2D

enum Visibility {
	OWNER_ONLY,
	ALL_PLAYERS,
	SPECIFIC_PLAYERS
}

signal card_selected(card)

@onready var front_side: TextureRect = $CardSprite
@onready var card_back: TextureRect = $CardBack
@onready var http_request = $ImageRequest

var image_url: String = ""
var owner_id: int
var controller_id: int

var visibility_mode: Visibility = Visibility.OWNER_ONLY
var visible_to_ids: Array[int] = []

func _ready() -> void:
	var texture = load("res://assets/card/card_back.png") as Texture2D
	if texture:
		card_back.texture = texture

	card_back.visible = false
	# Add HTTPRequest node at runtime
	http_request = HTTPRequest.new()
	add_child(http_request)

	# Connect signal the Godot 4 way
	http_request.request_completed.connect(_on_request_completed)

	# Optionally start download if URL already set
	if image_url != "":
		download_image(image_url)
		
func set_owner_id(id: int):
	owner_id = id
	
func set_controller_id(id: int):
	controller_id = id
	
@rpc("call_local")
func reveal_to_owner():
	show_card_front()

@rpc("call_local")
func hide_from_others():
	show_card_back()
	
func show_card_back():
	front_side.visible = false
	card_back.visible = true

func show_card_front():
	front_side.visible = true
	card_back.visible = false

func update_visibility_for(local_player_id: int):
	match visibility_mode:
		Visibility.OWNER_ONLY:
			if (local_player_id == owner_id):
				show_card_front()
			else:
				show_card_back()
		Visibility.ALL_PLAYERS:
			show_card_front()
		Visibility.SPECIFIC_PLAYERS:
			if (visible_to_ids.has(local_player_id)):
				show_card_front()
			else:
				show_card_back()

func set_visibility_owner_only():
	visibility_mode = Visibility.OWNER_ONLY
	visible_to_ids.clear()
	_update_all_players_visibility()

func set_visibility_all():
	visibility_mode = Visibility.ALL_PLAYERS
	visible_to_ids.clear()
	_update_all_players_visibility()

func set_visibility_specific(player_ids: Array[int]):
	visibility_mode = Visibility.SPECIFIC_PLAYERS
	visible_to_ids = player_ids.duplicate()
	_update_all_players_visibility()

@rpc("any_peer")
func rpc_update_visibility(for_player_id: int):
	update_visibility_for(for_player_id)

func _update_all_players_visibility():
	var x = ""
	# for peer_id in GameManager.get_all_player_ids():
	# 	rpc_id(peer_id, "rpc_update_visibility", peer_id)


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		card_selected.emit(self)

func set_image_url(url: String) -> void:
	image_url = url
	if is_inside_tree():
		download_image(image_url)

func download_image(url: String) -> void:
	var error = http_request.request(url)
	if error != OK:
		push_error("Failed to start image request: %s" % error)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Image download failed")
		return

	var image := Image.new()
	var err = image.load_jpg_from_buffer(body)
	if err != OK:
		push_error("Failed to load image from buffer")
		return
	image.resize(100, 140)
	var texture := ImageTexture.create_from_image(image)
	front_side.texture = texture
