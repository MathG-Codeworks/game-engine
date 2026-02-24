extends Control

@onready var label: Label = $Label

func _ready():
	CountdownManager.countdown_updated.connect(_on_time_changed)
	#CountdownManager.countdown_finished.connect(_on_finished)

func _on_time_changed(time_left: int):
	if CountdownManager.is_restart_phase:
		label.text = "Reinicia en %d" % time_left
	else:
		label.text = "%02d" % time_left

func _on_finished():
	label.text = "00:00"

func format_time(time: int) -> String:
	var minutes = time / 60
	var seconds = time % 60
	return "%02d:%02d" % [minutes, seconds]
