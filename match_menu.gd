extends Node

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_create_pressed() -> void:
	MultiplayerManager.start_match()
	get_tree().change_scene_to_file("res://gameplay.tscn")

func _on_join_pressed() -> void:
	get_tree().change_scene_to_file("res://join_menu.tscn")
