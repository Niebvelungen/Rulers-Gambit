extends Node2D

signal card_selected(card: Node)

@onready var texture_rect: TextureRect = $CardSprite
@onready var http_request = $ImageRequest
var image_url: String = ""
var owner_id: int
var controller_id: int

func _ready() -> void:
	# Add HTTPRequest node at runtime
	http_request = HTTPRequest.new()
	add_child(http_request)

	# Connect signal the Godot 4 way
	http_request.request_completed.connect(_on_request_completed)

	# Optionally start download if URL already set
	if image_url != "":
		download_image(image_url)

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

	var texture := ImageTexture.create_from_image(image)
	texture_rect.texture = texture
