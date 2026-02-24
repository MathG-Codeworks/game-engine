extends Node

signal countdown_updated(time_left)
signal countdown_finished
signal restart_countdown_started
signal restart_countdown_finished

var time_left: int = 60
var defaul_intermission: int = 5
var is_running: bool = false
var is_restart_phase: bool = false

@onready var timer: Timer = Timer.new()

func _ready():
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = false

func start(duration: int):
	time_left = duration
	is_running = true
	is_restart_phase = false
	timer.start()
	emit_signal("countdown_updated", time_left)

func stop():
	timer.stop()
	is_running = false

func start_restart_phase(duration: int = 5):
	defaul_intermission = duration
	is_restart_phase = true
	is_running = true
	timer.start()
	emit_signal("restart_countdown_started")
	emit_signal("countdown_updated", defaul_intermission)

func _on_timer_timeout():
	if not is_running:
		return
	
	if not is_restart_phase:
		# FASE NORMAL
		time_left -= 1
		emit_signal("countdown_updated", time_left)
		
		if time_left <= 0:
			is_running = false
			emit_signal("countdown_finished")
			start_restart_phase(defaul_intermission)
	else:
		# FASE DE REINICIO
		defaul_intermission -= 1
		emit_signal("countdown_updated", defaul_intermission)
		
		if defaul_intermission <= 0:
			timer.stop()
			is_running = false
			is_restart_phase = false
			emit_signal("restart_countdown_finished")
