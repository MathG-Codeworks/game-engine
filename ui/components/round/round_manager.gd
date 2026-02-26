extends Node

signal round_started(round_number)
signal round_finished(round_number)
signal all_rounds_finished

var current_round: int = 0
var max_rounds: int = 3
var round_duration: int = 30
var intermission_duration: int = 5
var is_running: bool = false

func _ready():
	CountdownManager.countdown_finished.connect(_on_round_time_up)
	CountdownManager.restart_countdown_finished.connect(_on_intermission_finished)

func start_game(total_rounds: int, duration: int, intermission: int = 3):
	max_rounds = total_rounds
	round_duration = duration
	intermission_duration = intermission
	is_running = true
	
	_start_next_round()

func _start_next_round():
	current_round += 1
	
	if current_round > max_rounds:
		is_running = false
		emit_signal("all_rounds_finished")
		return
	
	emit_signal("round_started", current_round)
	CountdownManager.start(round_duration)

func finish_round():
	emit_signal("round_finished", current_round)
	await get_tree().create_timer(2.0).timeout
	_start_next_round()
	
func _on_intermission_finished():
	_start_next_round()
	
func _on_round_time_up():
	emit_signal("round_finished", current_round)
	CountdownManager.start_restart_phase(intermission_duration)
