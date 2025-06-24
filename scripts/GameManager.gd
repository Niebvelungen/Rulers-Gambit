extends Node

@export var card_scene: PackedScene

var player_scenes: Array[Node] = []
var main_id = 1
var player_scene = preload("res://scenes/Player.tscn")

func _ready():
	if multiplayer.is_server():
		_init_players()
		_start_game()

func _init_players():
	var players_count = 0
	print(get_tree().get_current_scene().get_children().size())
	for i in [1, 2]:
		var player = player_scene.instantiate()
		players_count += 1
		player.player_id = players_count
		if players_count <= 1:
			player.set_multiplayer_authority(main_id)
		add_child(player)
		player.load_deck("https://www.forceofwind.online/api/deck/66148/1a9be95b2c17463187071f44788c20a8")


func _start_game():
	for player in player_scenes:
		draw_starting_hand.rpc_id(player.get_multiplayer_authority(), main_id)

@rpc
func draw_starting_hand(count: int):
	# Only executed on clients	
	for i in range(count):
		var hand = 0
