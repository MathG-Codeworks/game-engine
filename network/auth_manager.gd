extends Node
class_name ExternalAuthClient

signal login_success()
signal login_error(message: String)

const AUTH_PATH: String = "user://auth.cfg"
const AUTH_SECTION: String = "auth"

@export var API_URL: String = "https://mathg-api-v1.up.railway.app"
var LOGIN_URL: String = ""
var PROFILE_URL: String = ""
var START_SESSION_URL: String = ""
var END_SESSION_URL: String = ""
var PLATFORM: String = "Godot"

var access_token: String = ""
var refresh_token: String = ""
var is_verified: bool
var profile: Profile
var user_session: UserSession
var _ending_session: bool = false

var _http: HTTPRequest

func _ready() -> void:
	LOGIN_URL = API_URL + "/auth/login"
	PROFILE_URL = API_URL + "/auth/profile"
	START_SESSION_URL = API_URL + "/session"
	END_SESSION_URL = API_URL + "/session/:id/end"
	_http = HTTPRequest.new()
	add_child(_http)
	get_tree().set_auto_accept_quit(false)

func _notification(what: int) -> void:
	if _ending_session:
		return

	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			_ending_session = true
			await _end_session()
			get_tree().quit()
		
		NOTIFICATION_APPLICATION_PAUSED:
			_ending_session = true
			await _end_session()

		_:
			pass

func login(username_or_email: String, password: String) -> Dictionary:
	var payload: Dictionary = {
		"usernameOrEmail": username_or_email,
		"password": password
	}

	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json",
        "Accept: application/json"
	])

	var request_error: int = _http.request(
		LOGIN_URL,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

	if request_error != OK:
		var init_msg: String = "Error iniciando request: " + error_string(request_error)
		login_error.emit(init_msg)
		return {
			"ok": false,
			"status": 0,
			"error": "RequestInitError",
			"message": init_msg
		}

	var result: Array = await _http.request_completed
	var result_code: int = int(result[0])
	var response_code: int = int(result[1])
	var body: PackedByteArray = result[3]

	if result_code != HTTPRequest.RESULT_SUCCESS:
		var net_msg: String = "Error de red: " + _result_code_to_text(result_code)
		login_error.emit(net_msg)
		return {
			"ok": false,
			"status": response_code,
			"error": "NetworkError",
			"message": net_msg
		}

	var body_text: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(body_text)

	if typeof(parsed) != TYPE_DICTIONARY:
		var parse_msg: String = "Respuesta invalida del servidor."
		login_error.emit(parse_msg)
		return {
			"ok": false,
			"status": response_code,
			"error": "InvalidJson",
			"message": parse_msg,
			"raw": body_text
		}

	var data: Dictionary = parsed as Dictionary

	if response_code < 200 or response_code >= 300:
		var api_err: Dictionary = _extract_api_error(data, response_code)
		login_error.emit(str(api_err["message"]))
		return api_err

	var new_access_token: String = str(data.get("accessToken", ""))
	var new_refresh_token: String = str(data.get("refreshToken", ""))

	if new_access_token == "" or new_refresh_token == "":
		var token_msg: String = "Login OK pero faltan accessToken o refreshToken."
		login_error.emit(token_msg)
		return {
			"ok": false,
			"status": response_code,
			"error": "MissingTokens",
			"message": token_msg,
			"data": data
		}
		
	access_token = new_access_token
	refresh_token = new_refresh_token
		
	var profile_loaded = await _load_profile()
	if not profile_loaded:
		var profile_msg: String = "No se pudo cargar el perfil del usuario"
		login_error.emit(profile_msg)
		return {
			"ok": false,
			"message": profile_msg
		}

	var session_created = await _create_session()
	if not session_created:
		var session_msg: String = "No se pudo iniciar la sesión del usuario"
		login_error.emit(session_msg)
		return {
			"ok": false,
			"message": session_msg
		}

	var token_saved = TokenManager.save_tokens(access_token, refresh_token)
	
	if !token_saved:
		login_error.emit("Error de permisos de almacenamiento")
		return { "ok": false, "status": 0, "error": "Error de permisos de almacenamiento" }

	is_verified = true
	login_success.emit()

	return {
		"ok": true,
		"status": response_code,
		"access_token": access_token,
		"refresh_token": refresh_token,
		"data": data
	}

func _load_profile() -> bool:
	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json",
		"Accept: application/json",
		"Authorization: Bearer " + access_token
	])

	var request_error: int = _http.request(
		PROFILE_URL,
		headers,
		HTTPClient.METHOD_GET
	)

	if request_error != OK:
		return false

	var result: Array = await _http.request_completed
	var result_code: int = int(result[0])
	var response_code: int = int(result[1])
	var body: PackedByteArray = result[3]

	if result_code != HTTPRequest.RESULT_SUCCESS:
		return false

	var body_text: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(body_text)

	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	var data: Dictionary = parsed as Dictionary

	if response_code < 200 or response_code >= 300:
		return false
		
	profile = Profile.new(
		int(data.get("id", 0)),
		str(data.get("username", "")),
		str(data.get("email", "")),
		str(data.get("createdAt", "")),
		str(data.get("updatedAt", "")),
	)

	return true

func _create_session() -> bool:
	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json",
		"Accept: application/json",
		"Authorization: Bearer " + access_token
	])

	var payload: Dictionary = {
		"platform": self.PLATFORM,
		"device": OS.get_unique_id().replace("{", "").replace("}", "")
	}

	var request_error: int = _http.request(
		self.START_SESSION_URL,
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(payload)
	)

	if request_error != OK:
		return false

	var result: Array = await _http.request_completed
	var result_code: int = int(result[0])
	var response_code: int = int(result[1])
	var body: PackedByteArray = result[3]

	if result_code != HTTPRequest.RESULT_SUCCESS:
		return false

	var body_text: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(body_text)

	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	var data: Dictionary = parsed as Dictionary

	if response_code < 200 or response_code >= 300:
		return false

	self.user_session = UserSession.new(
		int(data.get("id", 0)),
		str(data.get("start", "")),
		str(data.get("end", "")),
		str(data.get("platform", "")),
		str(data.get("device", ""))
	)
	
	return true

func _end_session() -> bool:
	if access_token == "":
		return false

	if self.user_session == null or self.user_session.id == 0:
		return false

	var session_id: int = self.user_session.id
	var url: String = END_SESSION_URL.replace(":id", str(session_id))

	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json",
		"Accept: application/json",
		"Authorization: Bearer " + access_token
	])

	var request_error: int = _http.request(
		url,
		headers,
		HTTPClient.METHOD_PATCH
	)

	if request_error != OK:
		return false

	var result: Array = await _http.request_completed
	var result_code: int = int(result[0])
	var response_code: int = int(result[1])
	var body: PackedByteArray = result[3]

	if result_code != HTTPRequest.RESULT_SUCCESS:
		return false

	var body_text: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(body_text)

	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	if response_code < 200 or response_code >= 300:
		return false

	self._ending_session = false
	
	return true

func _extract_api_error(data: Dictionary, status_code: int) -> Dictionary:
	var message_value: Variant = data.get("message", "")
	var error_value: String = str(data.get("error", "HTTP Error"))
	var api_status: int = int(data.get("statusCode", status_code))

	var message_text: String = ""

	if typeof(message_value) == TYPE_ARRAY:
		var items: Array = message_value
		var parts: PackedStringArray = PackedStringArray()
		for item in items:
			parts.append(str(item))
		message_text = ", ".join(parts)
	elif typeof(message_value) == TYPE_STRING:
		message_text = str(message_value)
	else:
		message_text = error_value

	return {
		"ok": false,
		"status": api_status,
		"error": error_value,
		"message": message_text,
		"data": data
	}

func _result_code_to_text(code: int) -> String:
	match code:
		HTTPRequest.RESULT_SUCCESS:
			return "SUCCESS"
		HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH:
			return "CHUNKED_BODY_SIZE_MISMATCH"
		HTTPRequest.RESULT_CANT_CONNECT:
			return "CANT_CONNECT"
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "CANT_RESOLVE"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "CONNECTION_ERROR"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "TLS_HANDSHAKE_ERROR"
		HTTPRequest.RESULT_NO_RESPONSE:
			return "NO_RESPONSE"
		HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			return "BODY_SIZE_LIMIT_EXCEEDED"
		HTTPRequest.RESULT_BODY_DECOMPRESS_FAILED:
			return "BODY_DECOMPRESS_FAILED"
		HTTPRequest.RESULT_REQUEST_FAILED:
			return "REQUEST_FAILED"
		HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:
			return "DOWNLOAD_FILE_CANT_OPEN"
		HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:
			return "DOWNLOAD_FILE_WRITE_ERROR"
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			return "REDIRECT_LIMIT_REACHED"
		HTTPRequest.RESULT_TIMEOUT:
			return "TIMEOUT"
		_:
			return "UNKNOWN_" + str(code)

func verify_tokens() -> bool:
	var loaded_ok := TokenManager.load_tokens()
	is_verified = TokenManager.has_tokens() if loaded_ok else false

	return is_verified
