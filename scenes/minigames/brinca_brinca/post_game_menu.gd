extends CanvasLayer

func _ready() -> void:
	visible = false
	$Background/Container/HBoxContainer/BotonRejugar.pressed.connect(_on_play_again)
	$Background/Container/HBoxContainer/BotonWaitingRoom.pressed.connect(_on_waiting_room)

func show_menu() -> void:
	visible = true

func _on_play_again() -> void:
	MinigameManager.reset()
	RoundManager.reset()
	await MultiplayerManager.leave_match()
	MultiplayerManager.auto_start = true
	get_tree().change_scene_to_file("res://scenes/waiting_room/waiting_room.tscn")

func _on_waiting_room() -> void:
	MinigameManager.reset()
	RoundManager.reset()
	await MultiplayerManager.leave_match()
	MultiplayerManager.auto_start = true
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
