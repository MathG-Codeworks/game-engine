extends Node

signal joined
signal spawned
signal started
signal ranking_updated
signal countdown_updated
signal game_started
signal game_loaded

var match_response : MatchResponse
var match_id : String
var match_code : String
var players := {}
var pending_players := []
var ranking_players := []
var countdown = null
var character_scene : PackedScene = preload("res://scenes/character/character.tscn")
var auto_start: bool = false

const OP_PLAYER_STATE = 1
const RANKING_OP_STATE = 2
const READY_OP_CODE = 3
const UNREADY_OP_CODE = 4
const COUNTDOWN_OP_CODE = 5
const COUNTDOWN_CANCELLED_OP_CODE = 6
const GAME_STARTED_OP_CODE = 7
const EXERCISES_LOADED_OP_CODE = 8
const EVALUATE_ANSWER_OP_CODE = 9
const GAME_REPLAY_OP_CODE = 10
const PLAYER_REPLAY_OP_CODE = 11
const PLAYER_NO_REPLAY_OP_CODE = 12
const MATCH_CREATED = 13;
	
func start_match():
	var payload = JSON.stringify({
		"accessToken": TokenManager.access_token
	})
	var result = await NetworkManager.socket.rpc_async("create_match", payload)
	
	if result.is_exception():
		print("Match error: ", result.get_exception().message)
		return
		
	var response = JSON.parse_string(result.payload)
	
	if not response.success:
		print("Error creating match")
		return
		
	match_id = response.matchId
	match_code = response.code
	match_response = MatchResponse.from_dict(response.match)
	
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
	
	if not TokenManager.access_token:
		get_tree().change_scene_to_file("res://scenes/main/login/login.tscn")
	
	var payload = JSON.stringify({
		"code": code,
		"accessToken": TokenManager.access_token
	})
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
			ranking_updated.emit()
			
		COUNTDOWN_OP_CODE:
			countdown = JSON.parse_string(state.data).countdown
			countdown_updated.emit()
		
		COUNTDOWN_CANCELLED_OP_CODE:
			countdown = null
			countdown_updated.emit()
			
		GAME_STARTED_OP_CODE:
			for player in ranking_players:
				_remove_player(player.user_id)
			game_started.emit()
			
		EXERCISES_LOADED_OP_CODE:
			var data = JSON.parse_string(state.data)
			MinigameManager.update(
				int(data.minigame),
				data.description,
				data.exercises,
				int(data.round_duration),
				int(data.round_intermission)
			)
			game_loaded.emit()

		MATCH_CREATED:
			var data = JSON.parse_string(state.data)
			MultiplayerManager.match_response = MatchResponse.from_dict(data)
		
		GAME_REPLAY_OP_CODE:
			pass
			
func _on_presence(event):
	for join in event.joins:
		if join.user_id != NetworkManager.session.user_id:
			pending_players.append(join)
			spawned.emit()
	
	for leave in event.leaves:
		_remove_player(leave.user_id)
		
func _remove_player(user_id: String):
	if players.has(user_id):
		players[user_id].queue_free()
		players.erase(user_id)
		
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

func mark_player_ready(p_ready: bool):
	if match_id == "":
		return
		
	var payload = JSON.stringify({
		"matchId": match_id
	})
	
	NetworkManager.client.rpc_async(
		NetworkManager.session, 
		"set_player_ready" if p_ready else "set_player_unready", 
		payload
	)

func send_minigame_loaded(minigame: int):
	if match_id == "":
		return
		
	var payload = JSON.stringify({
		"matchId": match_id,
		"minigame": minigame
	})
	
	NetworkManager.client.rpc_async(
		NetworkManager.session,
		"scene_loaded",
		payload
	)

func leave_match() -> void:
	if match_id == "":
		return
	
	await NetworkManager.socket.leave_match_async(match_id)
	
	match_id = ""
	match_code = ""
	players.clear()
	pending_players.clear()
	ranking_players.clear()
	countdown = null
	
	if NetworkManager.socket.received_match_state.is_connected(_on_match_state):
		NetworkManager.socket.received_match_state.disconnect(_on_match_state)
	
	if NetworkManager.socket.received_match_presence.is_connected(_on_presence):
		NetworkManager.socket.received_match_presence.disconnect(_on_presence)

func mark_player_replay(p_replay: bool) -> void:
	if match_id == "":
		return
		
	var payload = JSON.stringify({
		"matchId": match_id
	})
	
	NetworkManager.client.rpc_async(
		NetworkManager.session, 
		"set_player_replay" if p_replay else "set_player_no_replay", 
		payload
	)
	
