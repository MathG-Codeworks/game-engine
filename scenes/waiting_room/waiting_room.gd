extends Node3D

@onready var label_countdown := $LabelCountDown

func _ready() -> void:
	CharacterManager.spawn_local_player()
	MultiplayerManager.spawned.connect(CharacterManager.spawn_pending_players)
	MultiplayerManager.countdown_updated.connect(_on_countdown_updated)
	MultiplayerManager.game_started.connect(_on_game_started)
	CharacterManager.spawn_pending_players()

func _on_countdown_updated():
	if label_countdown.visible == (MultiplayerManager.countdown == null):
		label_countdown.visible = MultiplayerManager.countdown != null
		
	label_countdown.text = str(int(MultiplayerManager.countdown)) if MultiplayerManager.countdown != null else "5"

func _on_game_started():
	get_tree().paused = true
	
	var root = get_tree().root
	for child in root.get_children():
		if child != get_tree().current_scene and child.name != "loading":
			if not child.is_in_group("persistent"):
				child.queue_free()
	
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/minigames/brinca_brinca/loading.tscn")
