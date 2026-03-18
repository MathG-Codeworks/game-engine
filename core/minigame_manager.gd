extends Node

const BRINCA_BRINCA = 1

var current_minigame : int = BRINCA_BRINCA
var exercises := []
var round_duration : int = 0
var round_intermission : int = 0

func update(p_current_minigame, p_exercises, p_round_duration : int, p_round_intermission : int) -> void:
	self.current_minigame = p_current_minigame
	self.exercises = p_exercises
	self.round_duration = p_round_duration
	self.round_intermission = p_round_intermission

func evaluate_answer(operation: String, answer: String) -> void:
	if not MultiplayerManager.match_id:
		return
	
	var data = JSON.stringify({
		"operation": operation,
		"answer": answer
	})
	
	NetworkManager.socket.send_match_state_async(
		MultiplayerManager.match_id,
		MultiplayerManager.EVALUATE_ANSWER_OP_CODE,
		data
	)
