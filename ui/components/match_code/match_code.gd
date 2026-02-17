extends Node

@onready var button_code := $MarginContainer/ButtonCode
var original_text := ""

func _ready() -> void:
	MultiplayerManager.started.connect(_on_started)
	_on_started()

func _on_started() -> void:
	button_code.text = MultiplayerManager.match_id
	original_text = MultiplayerManager.match_id

func _on_button_code_pressed() -> void:
	DisplayServer.clipboard_set(button_code.text)
	button_code.text = "Copiado ✓"
	
	await get_tree().create_timer(2.0).timeout
	button_code.text = original_text
