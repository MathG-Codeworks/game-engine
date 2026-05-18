class_name UserSession

var id: int
var start: String
var end: String
var platform: String
var device: String

func _init(p_id: int = 0, p_start: String = "", p_end: String = "", p_platform: String = "", p_device: String = "") -> void:
	id = p_id
	start = p_start
	end = p_end
	platform = p_platform
	device = p_device