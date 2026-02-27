extends Button

enum StateEnum {
	READY,
	CACELLED
}

var state: StateEnum = StateEnum.READY

func _ready() -> void:
	pass

func _on_pressed() -> void:
	toggle_state()
	
func toggle_state():
	match state:
		StateEnum.READY:
			MultiplayerManager.mark_player_ready(true)
			state = StateEnum.CACELLED
			text = 'Cancelar'
		StateEnum.CACELLED:
			MultiplayerManager.mark_player_ready(false)
			state = StateEnum.READY
			text = 'Listo!'
