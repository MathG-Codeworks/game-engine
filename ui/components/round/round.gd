extends Control

@onready var round_label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RoundManager.round_started.connect(_on_round_changed)
	
func _on_round_changed(current_round: int):
	round_label.text = "Ronda %d / %d" % [current_round, RoundManager.max_rounds]

func _on_round_time_up():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	pass
