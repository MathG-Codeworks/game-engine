extends Node2D

@onready var input: LineEdit = $Control/input

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://match_menu.tscn")	

func _on_join_pressed() -> void:
	MultiplayerManager.joined.connect(_on_joined)
	MultiplayerManager.join_match(input.text)

func _on_joined() -> void:
	get_tree().change_scene_to_file("res://gameplay.tscn")
