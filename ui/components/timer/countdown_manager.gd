extends Node

signal countdown_updated(time_left)
signal countdown_finished

var time_left: int = 60
var is_running: bool = false

@onready var timer: Timer = Timer.new()

func _ready():
	add_child(timer)
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	timer.one_shot = false

func start(duration: int):
	time_left = duration
	is_running = true
	timer.start()
	emit_signal("countdown_updated", time_left)

func stop():
	timer.stop()
	is_running = false

func _on_timer_timeout():
	if not is_running:
		return
	
	time_left -= 1
	emit_signal("countdown_updated", time_left)
	
	if time_left <= 0:
		timer.stop()
		is_running = false
		emit_signal("countdown_finished")
