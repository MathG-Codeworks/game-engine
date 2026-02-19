extends Node

var input_enabled := true
var character_scene : PackedScene = preload("res://scenes/character/character.tscn")

func spawn_local_player():
	var character = character_scene.instantiate()
	get_tree().current_scene.add_child(character)

	character.is_local_player = true
	#MultiplayerManager.players[NetworkManager.session.user_id] = character
