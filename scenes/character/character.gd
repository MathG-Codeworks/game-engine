class_name Character
extends CharacterBody3D

@export var speed: float = 14.0
@export var jump_force: float = 18.0
@export var fall_acceleration: float = 75.0

var target_velocity: Vector3 = Vector3.ZERO
var facing_angle: float = -90
var camera_weight: float = 0.1
var user_name_weight: float = 0.45
var is_local_player : bool = false
var target_remote_position: Vector3
var target_remote_rotation: float
var last_sent_position: Vector3
var last_sent_rotation: float

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var label_user_name: Label3D = $UserName

func _ready() -> void:
	target_remote_position = global_position
	target_remote_rotation = rotation_degrees.y

func _physics_process(delta: float):
	
	if is_local_player:
		if not CharacterManager.input_enabled:
			return
		
		_process_local_input(delta)
		if global_position.distance_to(last_sent_position) > 0.1 or abs(rotation_degrees.y - last_sent_rotation) > 1:
			if Engine.get_physics_frames() % 5 == 0:
				var current_anim = anim.current_animation if anim.is_playing() else ""
				MultiplayerManager._send_player_state(global_position, rotation_degrees.y, current_anim)
				last_sent_position = global_position
				last_sent_rotation = rotation_degrees.y
	else:
		global_position = global_position.lerp(target_remote_position, 0.2)
		rotation_degrees.y = lerp(rotation_degrees.y, target_remote_rotation, 0.2)
		label_user_name.position = lerp(label_user_name.position, position + Vector3.UP * 2.8, user_name_weight)

func _process_local_input(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.z += 1
	if Input.is_action_pressed("up"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()

		if direction.x > 0 and facing_angle != -90:
			facing_angle = -90
			flip_to(facing_angle)
		elif direction.x < 0 and facing_angle != -270:
			facing_angle = -270
			flip_to(facing_angle)

		if not anim.is_playing() or anim.current_animation != "global/walk":
			anim.play("global/walk")
	else:
		anim.stop()

	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if not is_on_floor():
		if velocity.y < 0:
			velocity.y -= fall_acceleration * 1.8 * delta
		else:
			velocity.y -= fall_acceleration * delta
	else:
		velocity.y = 0

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

	velocity.x = lerp(velocity.x, target_velocity.x, 0.15)
	velocity.z = lerp(velocity.z, target_velocity.z, 0.15)

	move_and_slide()
	label_user_name.position = lerp(label_user_name.position, position + Vector3.UP * 2.8, user_name_weight)
	$CameraController.position = lerp($CameraController.position, position, camera_weight)
		
func update_remote_state(data):
	target_remote_position = Vector3(data.x, data.y, data.z)
	target_remote_rotation = data.rot
	
	var anim_name = data.get("anim", "")
	
	if anim_name == "":
		if anim.is_playing():
			anim.stop()
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
	
