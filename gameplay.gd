extends Node3D

var character_scene : PackedScene = preload("res://character.tscn")

func _ready() -> void:
	MultiplayerManager.spawned.connect(spawn_pending_players)
	spawn_pending_players()
	spawn_local_player()
	
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
	MultiplayerManager.players[player.user_id] = character
	
func spawn_local_player():
	var character = character_scene.instantiate()
	get_tree().current_scene.add_child(character)

	character.is_local_player = true
	MultiplayerManager.players[NetworkManager.session.user_id] = character
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
