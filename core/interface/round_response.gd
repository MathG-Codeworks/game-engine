class_name Round

var id: int
var createdAt: String
var updatedAt: String
var minigame: Minigame

func _init(
	p_id: int = 0, 
	p_createdAt: String = "", 
	p_updatedAt: String = "", 
	p_minigame: Minigame = null
) -> void:
	id = p_id
	createdAt = p_createdAt
	updatedAt = p_updatedAt
	minigame = p_minigame

static func from_dict(data: Dictionary) -> Round:
	return Round.new(
		data.get("id", 0),
		data.get("createdAt", ""),
		data.get("updatedAt", ""),
		Minigame.from_dict(data.get("minigame", null))
	)
	
func to_dict() -> Dictionary:
	return  {
		"id": id,
		"createdAt": createdAt,
		"updatedAt": updatedAt,
		"minigame": minigame.to_dict()
	} 
