extends Node

const BRINCA_BRINCA = 1

var current_minigame : int = BRINCA_BRINCA
var description : String = ""
var exercises := []
var round_duration : int = 0
var round_intermission : int = 0
var exercises_loaded := false

func update(p_current_minigame, p_description: String, p_exercises, p_round_duration : int, p_round_intermission : int) -> void:
	self.current_minigame = p_current_minigame
	self.description = p_description
	self.exercises = p_exercises
	self.round_duration = p_round_duration
	self.round_intermission = p_round_intermission
	self.exercises_loaded = true

func evaluate_answer(round_id: int, operation: String, answer: String) -> void:
	if not MultiplayerManager.match_id:
		return
	
	var data = JSON.stringify({
		"userId": NetworkManager.user_id,
		"roundId": round_id, 
		"operation": operation,
		"answer": answer
	})
	
	NetworkManager.socket.send_match_state_async(
		MultiplayerManager.match_id,
		MultiplayerManager.EVALUATE_ANSWER_OP_CODE,
		data
	)

func reset() -> void:
	self.description = ""
	self.exercises.clear()
	self.round_duration = 0
	self.round_intermission = 0
	self.current_minigame = BRINCA_BRINCA
	self.exercises_loaded = false
