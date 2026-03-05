extends Node

var input_enabled := true
var character_scene : PackedScene = preload("res://scenes/character/character.tscn")

func _ready() -> void:
	MultiplayerManager.ranking_updated.connect(_on_ranking_updated)

func _on_ranking_updated():
	for ranking_player in MultiplayerManager.ranking_players:
		if MultiplayerManager.players.has(ranking_player.userId):
			var character = MultiplayerManager.players[ranking_player.userId]
			
			if character:
				character.set_underline(ranking_player.color)

func spawn_local_player():
	var character = character_scene.instantiate()
	get_tree().current_scene.add_child(character)

	character.is_local_player = true
	#character.set_label(NetworkManager.session.username)
	#MultiplayerManager.players[NetworkManager.session.user_id] = character

func spawn_pending_players():
	for player in MultiplayerManager.pending_players:
		spawn_player(player)
	
	MultiplayerManager.pending_players.clear()

func spawn_player(player):
	if MultiplayerManager.players.has(player.user_id):
		return
		
	var character = character_scene.instantiate()
	add_child(character)
	
	character.is_local_player = player.user_id == NetworkManager.session.user_id
	character.label_user_name.text = player.username
	MultiplayerManager.players[player.user_id] = character
	_on_ranking_updated()
