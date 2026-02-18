extends Node

var client : NakamaClient
var session : NakamaSession
var socket : NakamaSocket

signal authenticated
signal socket_connected

const SERVER_KEY = "defaultkey"
const HOST = "nakama-production-cb19.up.railway.app"
const PORT = 443
const SCHEME = "https"

func _ready():
	_create_client()

func _create_client():
	client = Nakama.create_client(SERVER_KEY, HOST, PORT, SCHEME)

func authenticate_device():
	var device_id = OS.get_unique_id() + str(randi() % 10000)
	var result = await client.authenticate_device_async(device_id)

	if result.is_exception():
		print("Auth error:", result.get_exception().message)
		return

	session = result
	authenticated.emit()
	
	await _connect_socket()

func _connect_socket():
	socket = Nakama.create_socket_from(client)
	await socket.connect_async(session)
	socket_connected.emit()
