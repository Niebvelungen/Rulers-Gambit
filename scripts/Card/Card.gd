class_name Card

extends Control

enum Visibility {
	OWNER_ONLY,
	ALL_PLAYERS,
	SPECIFIC_PLAYERS
}

signal card_selected(card)

@onready var front_side: TextureRect = $CardSprite
@onready var back_side: TextureRect = $CardBack
@onready var http_request = $ImageRequest

var image_url: String = ""
var owner_id: int
var controller_id: int
var is_owner: bool
var front_side_clone: TextureRect

var visibility_mode: Visibility = Visibility.OWNER_ONLY
var visible_to_ids: Array[int] = []

func _ready() -> void:
	var texture = load("res://assets/card/back_side.png") as Texture2D
	if texture:
		back_side.texture = texture

	back_side.visible = false
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

func set_is_owner(is_owner: bool):
	self.is_owner = is_owner
	
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
	back_side.visible = true

func show_card_front():
	front_side.visible = true
	back_side.visible = false

func is_front_visible():
	return front_side.visible

func is_back_visible():
	return back_side.visible

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

func re_download_image() -> void:
	var error = http_request.request(image_url)
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
	var texture := ImageTexture.create_from_image(image)
	front_side.texture = texture

func scale_card(vector: Vector2):
	if self.is_front_visible() and front_side and front_side is TextureRect:
		front_side.scale = vector
	elif self.is_back_visible() and back_side and back_side is TextureRect:
		back_side.scale = vector

func _on_mouse_entered():
	if self.is_front_visible() and front_side and front_side is TextureRect:
		# Duplicate front_side safely
		var clone = front_side.duplicate() as TextureRect
		if clone:
			front_side_clone = clone
			front_side_clone.name = "front_side_clone"

			# Add clone to the scene tree
			get_parent().add_child(front_side_clone)
			front_side_clone.global_position = Vector2(0, -300)
			front_side_clone.scale = Vector2(2, 2)

			if not self.is_owner:
				front_side_clone.rotation_degrees = 180

			print("entered")

func _on_mouse_exited():
	if front_side_clone and front_side_clone.is_inside_tree():
		front_side_clone.queue_free()
		front_side_clone = null
		print("exited")
