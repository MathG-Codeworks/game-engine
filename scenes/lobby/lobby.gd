extends Node3D

var character_scene : PackedScene = preload("res://scenes/character/character.tscn")

func _ready() -> void:
	CharacterManager.spawn_local_player()
	$Multiplayer_options/MatchModal.visible = false

func _on_multiplayer_options_body_entered(body: Node3D) -> void:
	if body is Character:
		$Multiplayer_options/MatchModal.visible = true

func _on_multiplayer_options_body_exited(body: Node3D) -> void:
	if body is Character:
		$Multiplayer_options/MatchModal.visible = false
