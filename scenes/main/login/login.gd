extends Node

@onready var username_input: LineEdit = $Control/UsernameInput
@onready var password_input: LineEdit = $Control/PasswordInput
@onready var login_button: Button = $Control/LoginButton

@onready var error_message_container: ColorRect = $CanvasLayer/Container
@onready var error_message_panel: Panel = $CanvasLayer/Panel
@onready var error_message_label: RichTextLabel = $CanvasLayer/Panel/ErrorMessageLabel

func _on_login_button_pressed() -> void:
	login_button.disabled = true
	login_button.text = "Cargando..."
	username_input.editable = false
	password_input.editable = false
	
	AuthManager.login_success.connect(_on_login_success)
	AuthManager.login_error.connect(_on_login_error)
	AuthManager.login(username_input.text, password_input.text)
	
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_login_success() -> void:
	login_button.text = "Entrando..."
	NetworkManager.socket_connected.connect(_on_socket)
	NetworkManager.authenticate_device()
	
func _on_socket() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby/lobby.tscn")

func _on_login_error(message: String) -> void:
	error_message_label.text = message
	error_message_container.visible = true
	error_message_panel.visible = true
	login_button.disabled = false
	username_input.editable = true
	password_input.editable = true
	login_button.text = "Entrar!"
	
func _on_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		error_message_container.visible = false
		error_message_panel.visible = false
