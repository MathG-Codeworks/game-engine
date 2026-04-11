extends Control

@onready var base = $Base
@onready var stick = $Stick

@export var max_distance := 100.0 # Qué tan lejos se puede mover el stick
var touch_index := -1
var output_vector := Vector2.ZERO # El valor que leerá tu personaje (entre -1 y 1)

func _ready():
	# Si el sistema operativo NO es Android y NO es iOS
	# O si no estamos en un dispositivo con pantalla táctil
	if OS.get_name() != "Android" and OS.get_name() != "iOS":
		# Opcional: Si quieres que aparezca en PC para pruebas, comenta la siguiente línea
		hide()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			# Si tocamos dentro del área del control
			if get_global_rect().has_point(event.position):
				touch_index = event.index
				update_joystick(event.position)
		elif not event.pressed and event.index == touch_index:
			# Al soltar el dedo, reseteamos todo
			touch_index = -1
			reset_joystick()

	if event is InputEventScreenDrag and event.index == touch_index:
		update_joystick(event.position)

func update_joystick(touch_pos: Vector2):
	# Usamos position (relativa al padre) o pivot_offset para el centro
	# Si tus Sprites están centrados en el nodo Control:
	var center = size / 2 
	var direction = (touch_pos - global_position) - center
	
	if direction.length() > max_distance:
		direction = direction.normalized() * max_distance
	
	stick.position = center + direction # Usamos .position no .global_position
	output_vector = direction / max_distance
	print("Joystick enviando: ", output_vector) # <--- AÑADE ESTO

func reset_joystick():
	output_vector = Vector2.ZERO
	# Animación suave de regreso al centro (opcional)
	var tween = create_tween()
	tween.tween_property(stick, "position", Vector2.ZERO, 0.1).set_trans(Tween.TRANS_SINE)
