class_name Character
extends CharacterBody3D

@export var speed: float = 14.0
@export var jump_force: float = 18.0
@export var fall_acceleration: float = 75.0

var target_velocity: Vector3 = Vector3.ZERO
var facing_angle: float = -90
var camera_weight: float = 0.1
var user_name_weight: float = 0.45
var underline_user_name_weight: float = 0.375
var is_local_player : bool = false
var target_remote_position: Vector3
var target_remote_rotation: float
var last_sent_position: Vector3
var last_sent_rotation: float

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var label_user_name: Label3D = $UserName
@onready var underline_user_name: MeshInstance3D = $Underline

# REFERENCIA AL JOYSTICK: 
# Buscamos el nodo en el árbol. Asegúrate de que el nodo se llame "Joystick"
@onready var joystick = get_tree().root.find_child("joystick", true, false)

func _ready() -> void:
	add_to_group("players")
	target_remote_position = global_position
	target_remote_rotation = rotation_degrees.y

func _physics_process(delta: float):
	if is_local_player:
		if not CharacterManager.input_enabled:
			return
		
		_process_local_input(delta)
		
		# Sincronización Multijugador
		if global_position.distance_to(last_sent_position) > 0.1 or abs(rotation_degrees.y - last_sent_rotation) > 1:
			var current_anim = anim.current_animation if anim.is_playing() else ""
			MultiplayerManager._send_player_state(global_position, rotation_degrees.y, current_anim)
			last_sent_position = global_position
			last_sent_rotation = rotation_degrees.y
	else:
		# Lógica para jugadores remotos
		global_position = global_position.lerp(target_remote_position, 0.2)
		rotation_degrees.y = lerp(rotation_degrees.y, target_remote_rotation, 0.2)
		_update_ui_positions()

func _process_local_input(delta):
	var direction = Vector3.ZERO

	# 1. Entrada de Teclado (PC)
	direction.x = Input.get_axis("left", "right")
	direction.z = Input.get_axis("up", "down")

	# 2. Entrada de Joystick (Mobile)
	# Si el joystick existe y se está moviendo, tiene prioridad
	if joystick and joystick.output_vector != Vector2.ZERO:
		direction.x = joystick.output_vector.x
		direction.z = joystick.output_vector.y # Y del joystick es Z en 3D

	if direction != Vector3.ZERO:
		# Solo normalizamos si la magnitud es mayor a 1 (para teclado)
		# Esto permite que el joystick maneje velocidades graduales
		if direction.length() > 1.0:
			direction = direction.normalized()

		# Lógica de rotación (Flip)
		if direction.x > 0 and facing_angle != -90:
			facing_angle = -90
			flip_to(facing_angle)
		elif direction.x < 0 and facing_angle != -270:
			facing_angle = -270
			flip_to(facing_angle)

		if not anim.is_playing() or anim.current_animation != "global/walk":
			anim.play("global/walk")
	else:
		if anim.is_playing() and anim.current_animation == "global/walk":
			anim.stop()

	# Aplicar movimiento
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Gravedad
	if not is_on_floor():
		var gravity_mult = 1.8 if velocity.y < 0 else 1.0
		velocity.y -= fall_acceleration * gravity_mult * delta
	else:
		velocity.y = 0

	# Salto (Funciona con Input Map o Botones Virtuales de Godot)
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

	# Suavizado de movimiento
	velocity.x = lerp(velocity.x, target_velocity.x, 0.15)
	velocity.z = lerp(velocity.z, target_velocity.z, 0.15)

	move_and_slide()
	_update_ui_positions()
	$CameraController.position = lerp($CameraController.position, position, camera_weight)

# Función auxiliar para no repetir código de UI
func _update_ui_positions():
	label_user_name.position = lerp(label_user_name.position, position + Vector3.UP * 2.8, user_name_weight)
	underline_user_name.position = lerp(underline_user_name.position, position + Vector3.UP * 2.5, underline_user_name_weight)

func update_remote_state(data):
	target_remote_position = Vector3(data.x, data.y, data.z)
	target_remote_rotation = data.rot
	var anim_name = data.get("anim", "")
	if anim_name == "":
		if anim.is_playing(): anim.stop()
	else:
		if not anim.is_playing() or anim.current_animation != anim_name:
			anim.play(anim_name)

func flip_to(angle: float):
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", angle, 0.15).set_trans(Tween.TRANS_SINE)

func respawn(at_position):
	global_position = at_position
	velocity = Vector3.ZERO
	target_velocity = Vector3.ZERO
	target_remote_position = at_position
	target_remote_rotation = rotation_degrees.y
	last_sent_position = at_position
	last_sent_rotation = rotation_degrees.y
	anim.stop()

func set_label(value: String):
	label_user_name.text = value
	await get_tree().process_frame
	_update_underline_width()

func set_underline(color: Color):
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	underline_user_name.material_override = mat
	underline_user_name.visible = true

func _update_underline_width():
	var aabb = label_user_name.get_aabb()
	var mesh := underline_user_name.mesh as QuadMesh
	mesh.size.x = aabb.size.x
