extends Node

signal joined
signal spawned
signal started

var match_id : String
var match_code : String
var players := {}
var pending_players := []
var ranking_players := []
var character_scene : PackedScene = preload("res://scenes/character/character.tscn")

const OP_PLAYER_STATE = 1
const RANKING_OP_STATE = 2
	
func start_match():
	var result = await NetworkManager.socket.rpc_async("create_match", "")
	
	if result.is_exception():
		print("Match error: ", result.get_exception().message)
		return
		
	var response = JSON.parse_string(result.payload)
	
	if not response.success:
		print("Error creating match")
		return
		
	match_id = response.matchId
	match_code = response.code
	
	NetworkManager.socket.received_match_state.connect(_on_match_state)
	NetworkManager.socket.received_match_presence.connect(_on_presence)
	
	var join_result = await NetworkManager.socket.join_match_async(match_id)
	
	if join_result.is_exception():
		print("Error joining match")
		NetworkManager.socket.received_match_state.disconnect(_on_match_state)
		NetworkManager.socket.received_match_presence.disconnect(_on_presence)
		return
		
	started.emit()

func join_match(code: String):
	var payload = JSON.stringify({"code": code})
	var result = await NetworkManager.socket.rpc_async("join_match_by_code", payload)
	
	if result.is_exception():
		print("Error searching for match")
		return
		
	var response = JSON.parse_string(result.payload)
	
	if not response.success:
		print("Error: ", response.error)
		return
		
	match_id = response.matchId
	
	NetworkManager.socket.received_match_state.connect(_on_match_state)
	NetworkManager.socket.received_match_presence.connect(_on_presence)
	
	var join_result = await NetworkManager.socket.join_match_async(match_id)
	
	if join_result.is_exception():
		print("Error joining match")
		NetworkManager.socket.received_match_state.disconnect(_on_match_state)
		NetworkManager.socket.received_match_presence.disconnect(_on_presence)
		return
	
	match_code = code
	joined.emit()
	
	for presence in join_result.presences:
		if presence.user_id != NetworkManager.session.user_id:
			pending_players.append(presence)

func _on_match_state(state):
	match state.op_code:
		OP_PLAYER_STATE:
			var data = JSON.parse_string(state.data)
			var sender_id = state.presence.user_id
	
			if sender_id == NetworkManager.session.user_id:
				return
	
			if not players.has(sender_id):
				return
		
			players[sender_id].update_remote_state(data)
		
		RANKING_OP_STATE:
			ranking_players = JSON.parse_string(state.data)

func _on_presence(event):
	for join in event.joins:
		pending_players.append(join)
		spawned.emit()
	
	for leave in event.leaves:
		_remove_player(leave)
		
func _remove_player(player):
	if players.has(player.user_id):
		players[player.user_id].queue_free()
		players.erase(player.user_id)
		
func _send_player_state(position: Vector3, rotation_y: float, anim_name: String = ""):
	if match_id == "":
		return
	
	var data = {
		"x": position.x,
		"y": position.y,
		"z": position.z,
		"rot": rotation_y,
		"anim": anim_name
	}
	
	NetworkManager.socket.send_match_state_async(
		match_id,
		OP_PLAYER_STATE,
		JSON.stringify(data)
	)
