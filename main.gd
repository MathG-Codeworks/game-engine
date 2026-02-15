extends Node3D

@onready var start_button: Button = $"Main Menu/Control/start"

var client : NakamaClient
var session : NakamaSession

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.disabled = true
	start_button.text = "Autenticando..."
	NetworkManager.authenticated.connect(_on_auth)
	NetworkManager.socket_connected.connect(_on_socket)
	NetworkManager.authenticate_device()
	
func _on_auth():
	start_button.text = "Conectando..."
	print("Usuario autenticado!")
	
func _on_socket():
	start_button.text = "Jugar!"
	start_button.disabled = false
	print('Usuario conectado!');

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
