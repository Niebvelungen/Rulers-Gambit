extends Node

@export var card_scene: PackedScene

var player_scenes: Array[Node] = []

func _ready():
	if multiplayer.is_server():
		_init_players()
		_start_game()

func _init_players():
	for child in get_tree().get_current_scene().get_children():
		if child.name.begins_with("Player"):
			player_scenes.append(child)
			child.set_multiplayer_authority(child.get_multiplayer_authority())

func _start_game():
	for player in player_scenes:
		draw_starting_hand.rpc_id(player.get_multiplayer_authority(), 5)

@rpc
func draw_starting_hand(count: int):
	# Only executed on clients
	for i in range(count):
		var hand = 0
