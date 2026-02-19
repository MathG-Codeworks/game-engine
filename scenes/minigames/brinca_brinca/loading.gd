extends Node2D

@onready var button_start = $MarginContainer/ButtonStart

func _ready() -> void:
	button_start.disabled = true
	button_start.text = "CARGANDO..."

func _on_button_start_pressed() -> void:
	pass
