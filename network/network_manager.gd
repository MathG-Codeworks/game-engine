extends Node

var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket

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
		return
		
	session = nakama_auth
	await client.update_account_async(
		session,
		username,
		username
	)
	session.username = username
	
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
		return
	
	authenticated.emit()
	await _connect_socket()

func _connect_socket():
	socket = Nakama.create_socket_from(client)
	await socket.connect_async(session)
	socket_connected.emit()
