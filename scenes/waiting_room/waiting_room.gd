extends Node3D

func _ready() -> void:
	CharacterManager.spawn_local_player()
	MultiplayerManager.spawned.connect(CharacterManager.spawn_pending_players)
	CharacterManager.spawn_pending_players()
