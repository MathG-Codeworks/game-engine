extends Node

signal tokens_loaded(access_token: String, refresh_token: String)

const AUTH_PATH := "user://auth.cfg"
const AUTH_SECTION := "auth"
var access_token: String = ""
var refresh_token: String = ""

func save_tokens(p_access_token: String, p_refresh_token: String) -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value(AUTH_SECTION, "access_token", p_access_token)
	cfg.set_value(AUTH_SECTION, "refresh_token", p_refresh_token)
	
	var err := cfg.save(AUTH_PATH)
	if err != OK:
		return false
		
	access_token = p_access_token
	refresh_token = p_refresh_token
	
	return true;

func load_tokens() -> bool:
	var cfg := ConfigFile.new()
	var err := cfg.load(AUTH_PATH)
	if err != OK:
		return false

	access_token = str(cfg.get_value(AUTH_SECTION, "access_token", ""))
	refresh_token = str(cfg.get_value(AUTH_SECTION, "refresh_token", ""))

	tokens_loaded.emit(access_token, refresh_token)

	return access_token != "" or refresh_token != ""

func _clear_tokens() -> bool:
	access_token = ""
	refresh_token = ""

	if FileAccess.file_exists(AUTH_PATH):
		var err := DirAccess.remove_absolute(AUTH_PATH)
		if err != OK:
			return false
			
		return true
	else:
		return false	
	
func has_tokens() -> bool:
	return access_token != "" and refresh_token != ""
