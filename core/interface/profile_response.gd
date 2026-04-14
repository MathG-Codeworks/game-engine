class_name Profile

var id: int
var username: String
var email: String
var createdAt: String
var updatedAt: String

func _init(p_id: int = 0, p_username: String = "", p_email: String = "", p_createdAt: String = "", p_updatedAt: String = "") -> void:
	id = p_id
	username = p_username
	email = p_email
	createdAt = p_createdAt
	updatedAt = p_updatedAt
