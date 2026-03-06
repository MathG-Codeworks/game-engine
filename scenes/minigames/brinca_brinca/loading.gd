extends Control

func _ready() -> void:
	MultiplayerManager.game_loaded.connect(_on_game_loaded)
	if MinigameManager.current_minigame == MinigameManager.BRINCA_BRINCA:
		_on_game_loaded()
			
func _on_game_loaded():
	if MinigameManager.current_minigame != MinigameManager.BRINCA_BRINCA:
		return
	
	get_tree().change_scene_to_file("res://scenes/minigames/brinca_brinca/brinca_brinca.tscn")
