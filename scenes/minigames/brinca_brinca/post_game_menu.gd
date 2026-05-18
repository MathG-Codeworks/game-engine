extends CanvasLayer

var replay := true

@onready var BotonRejugar = $Background/Container/HBoxContainer/BotonRejugar

func _ready() -> void:
	visible = false
	_update_rejugar()
	MultiplayerManager.ranking_updated.connect(_update_rejugar)
	$Background/Container/HBoxContainer/BotonRejugar.pressed.connect(_on_play_again)
	$Background/Container/HBoxContainer/BotonWaitingRoom.pressed.connect(_on_waiting_room)

func show_menu() -> void:
	visible = true

func _on_play_again() -> void:
	MultiplayerManager.mark_player_replay(replay)
	replay = !replay

func _on_waiting_room() -> void:
	MinigameManager.reset()
	RoundManager.reset()
	await MultiplayerManager.leave_match()
	MultiplayerManager.auto_start = true
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
	
func _update_rejugar() -> void:
	var total_players = MultiplayerManager.ranking_players.size()
	var replay_players = MultiplayerManager.ranking_players.filter(func(p): return p.replay == true).size()
	BotonRejugar.text = "Volver a Jugar (" + str(replay_players) + "/" + str(total_players) + ")"
	
	if total_players == replay_players:
		await get_tree().create_timer(1.0).timeout
		MinigameManager.reset()
		RoundManager.reset()
		MultiplayerManager.pending_players = MultiplayerManager.ranking_players
		get_tree().change_scene_to_file("res://scenes/waiting_room/waiting_room.tscn")
