extends Node

@onready var start_button: Button = $Control/Start

var client : NakamaClient
var session : NakamaSession

func _ready() -> void:
	start_button.disabled = true
	start_button.text = "Cargando..."
		
	if AuthManager.verify_tokens():
		NetworkManager.authenticated.connect(_on_auth)
		NetworkManager.socket_connected.connect(_on_socket)
		NetworkManager.authenticate_device()
	else:
		start_button.text = "Iniciar Sesión!"
		start_button.disabled = false
		
func _on_auth():
	start_button.text = "Conectando..."
	
func _on_socket():
	start_button.text = "Jugar!"
	start_button.disabled = false

func _on_start_pressed() -> void:
	if AuthManager.is_verified:
		get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main/login/login.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
