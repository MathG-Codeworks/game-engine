extends Control

func _ready() -> void:
	if MinigameManager.exercises_loaded:
		_on_game_loaded()
	else:
		MultiplayerManager.game_loaded.connect(_on_game_loaded)
			
func _on_game_loaded():
	MinigameManager.exercises_loaded = false
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/minigames/brinca_brinca/brinca_brinca.tscn")
