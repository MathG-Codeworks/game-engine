extends Control

const GAME_SCENE_PATH := "res://scenes/minigames/brinca_brinca/brinca_brinca.tscn"

@onready var button_start = $MarginContainer/ButtonStart

var load_status := 0
var progress := []
var packed_scene : PackedScene

func _ready() -> void:
	ResourceLoader.load_threaded_request(GAME_SCENE_PATH)
	MultiplayerManager.game_loaded.connect(_on_game_loaded)
	
func _process(_delta: float) -> void:

	load_status = ResourceLoader.load_threaded_get_status(
		GAME_SCENE_PATH,
		progress
	)
	
	match load_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			button_start.text = "Progreso: " + str(progress[0] * 100) + "%"
			
		ResourceLoader.THREAD_LOAD_LOADED:
			button_start.text = "Esperando a los demás"
			packed_scene = ResourceLoader.load_threaded_get(GAME_SCENE_PATH)
			MultiplayerManager.send_minigame_loaded(MinigameManager.BRINCA_BRINCA)
			set_process(false)
			
		ResourceLoader.THREAD_LOAD_FAILED:
			button_start.text = "Error cargando :("
			set_process(false)
			
func _on_game_loaded(minigame: int):
	if minigame != MinigameManager.BRINCA_BRINCA:
		return
		
	if not packed_scene:
		return
	
	get_tree().change_scene_to_packed(packed_scene)
