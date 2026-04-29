class_name Minigame

var id: int
var name: String
var description: String
var createdAt: String
var updatedAt: String

func _init(p_id: int = 0, p_name: String = "", p_description: String = "", p_createdAt: String = "", p_updatedAt: String = "") -> void:
	id = p_id
	name = p_name
	description = p_description
	createdAt = p_createdAt
	updatedAt = p_updatedAt

static func from_dict(data: Dictionary) -> Minigame:
	return Minigame.new(
		data.get("id", 0),
		data.get("name", ""),
		data.get("description", ""),
		data.get("createdAt", ""),
		data.get("updatedAt", ""),
	)
	
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"createdAt": createdAt,
		"updatedAt": updatedAt
	}
