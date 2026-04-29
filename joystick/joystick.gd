extends Control

@onready var base = $Base
@onready var stick = $Stick

@export var max_distance := 100.0 
var touch_index := -1
var output_vector := Vector2.ZERO 

func _ready():
	# 1. Centramos visualmente los sprites
	var center = size / 2
	base.position = center
	stick.position = center
	
	# 2. Lógica de visibilidad: Solo se muestra si hay pantalla táctil disponible
	# Esto hará que en Android sea visible y en PC (sin táctil) se oculte solo.
	if DisplayServer.is_touchscreen_available():
		show()
	else:
		hide()
	
	# Esto es vital: permite que el joystick capture el toque
	mouse_filter = Control.MOUSE_FILTER_STOP

func _input(event):
	# Manejo de pantallas táctiles (Celulares)
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			if get_global_rect().has_point(event.position):
				touch_index = event.index
				update_joystick(event.position)
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			reset_joystick()

	if event is InputEventScreenDrag and event.index == touch_index:
		update_joystick(event.position)
	
	# Manejo de Mouse (Para pruebas en PC, se activa solo si el nodo es visible)
	if is_visible_in_tree():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and get_global_rect().has_point(event.position):
				touch_index = 0
				update_joystick(event.position)
			elif not event.pressed:
				touch_index = -1
				reset_joystick()
				
		if event is InputEventMouseMotion and touch_index != -1:
			update_joystick(event.position)

func update_joystick(touch_pos: Vector2):
	var center = base.global_position
	var direction = touch_pos - center
	
	if direction.length() > max_distance:
		direction = direction.normalized() * max_distance
	
	stick.global_position = center + direction
	output_vector = direction / max_distance

func reset_joystick():
	output_vector = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(stick, "global_position", base.global_position, 0.15)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
