extends Button

enum ReadyState {
	READY,
	CACELLED
}

var state: ReadyState = ReadyState.READY

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_visual()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	toggle_state()
	update_visual()
	
func toggle_state():
	if state == ReadyState.READY:
		state = ReadyState.CACELLED
	else:
		state = ReadyState.READY
	
func update_visual():
	match state:
		ReadyState.READY:
			text = "Cancelar"
		ReadyState.CACELLED:
			text = "Listo"
