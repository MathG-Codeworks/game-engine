class_name MatchResponse

var id: String
var code: String
var createdAt: String
var updatedAt: String
var rounds: Array[Round]

func _init(
	p_id: String = "", 
	p_code: String = "", 
	p_createdAt: String = "", 
	p_updatedAt: String = "",
	p_rounds: Array[Round] = []
) -> void:
	id = p_id
	code = p_code
	createdAt = p_createdAt
	updatedAt = p_updatedAt
	rounds = p_rounds
	
static func from_dict(data: Dictionary) -> MatchResponse:
	var m = MatchResponse.new(
		data.get("id", ""),
		data.get("code", ""),
		data.get("createdAt", ""),
		data.get("updatedAt", "")
	)
	
	for r in data.get("rounds", []):
		m.rounds.append(Round.from_dict(r))
	
	return m
	
func to_dict() -> Dictionary:
	return {
		"id": id,
		"code": code,
		"createdAt": createdAt,
		"updatedAt": updatedAt,
		"rounds": rounds.map(func(r): return r.to_dict())
	}
