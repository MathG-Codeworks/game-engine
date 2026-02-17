extends Node

@onready var start_button: Button = $Control/Start

var client : NakamaClient
var session : NakamaSession

func _ready() -> void:
	start_button.disabled = true
	start_button.text = "Autenticando..."
	NetworkManager.authenticated.connect(_on_auth)
	NetworkManager.socket_connected.connect(_on_socket)
	NetworkManager.authenticate_device()
	
func _on_auth():
	start_button.text = "Conectando..."
	
func _on_socket():
	start_button.text = "Jugar!"
	start_button.disabled = false

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
