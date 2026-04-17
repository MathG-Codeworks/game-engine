extends Node

var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket
var session_id : int

signal authenticated
signal socket_connected

const SERVER_KEY = "defaultkey"
const HOST = "localhost"
const PORT = 7350
const SCHEME = "http"
const PREFIX_USER_ID = "user_"

func _ready():
	_create_client()

func _create_client():
	client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)

func authenticate_with_nakama(id: int, username: String):
	var nakama_auth = await client.authenticate_custom_async(PREFIX_USER_ID + str(id));
	if nakama_auth.is_exception():
		return false
		
	session = nakama_auth
	await client.update_account_async(
		session,
		username,
		username
	)
	session.username = username
	
	if await _create_session() == false:
		return false
	
	authenticated.emit()
	await _connect_socket()
	
func _create_session() -> bool:
	var rpc_result = await client.rpc_async(
		session,
		"create_session",
		JSON.stringify({
			"device_id": OS.get_unique_id().replace("{", "").replace("}", ""),
			"access_token": TokenManager.access_token,
			"refresh_token": TokenManager.refresh_token
		})
	)
	
	if rpc_result.is_exception():
		return false
	
	var response_data = JSON.parse_string(rpc_result.payload)
	
	if response_data.ok && response_data.body.id:
		session_id = response_data.body.id
		return true
	else:
		return false

func _connect_socket():
	socket = Nakama.create_socket_from(client)
	await socket.connect_async(session)
	socket_connected.emit()
