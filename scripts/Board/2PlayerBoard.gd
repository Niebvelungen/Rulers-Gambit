extends Control

@onready var player_areas = {
	0: $VBoxContainer/Player0,
	1: $VBoxContainer/Player1
}

func get_player_area(player_id: int) -> VBoxContainer:
	return player_areas.get(player_id)
