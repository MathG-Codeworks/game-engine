extends Control

func _on_input_code_focus_entered() -> void:
	CharacterManager.input_enabled = false
	
func _on_input_code_focus_exited() -> void:
	CharacterManager.input_enabled = true

func _on_center_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		$CenterContainer/Panel/MarginContainer/HBoxContainer/InputCode.release_focus()

func _on_button_create_pressed() -> void:
	MultiplayerManager.start_match()
	get_tree().change_scene_to_file("res://scenes/waiting_room/waiting_room.tscn")
