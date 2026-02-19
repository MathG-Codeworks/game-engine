extends Node

@onready var button_code := $MarginContainer/ButtonCode

func _ready() -> void:
	MultiplayerManager.started.connect(_on_started)
	_on_started()

func _on_started() -> void:
	button_code.text = MultiplayerManager.match_code

func _on_button_code_pressed() -> void:
	DisplayServer.clipboard_set(button_code.text)
