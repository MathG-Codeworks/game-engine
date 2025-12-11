extends CharacterBody3D

@export var speed: float = 14.0
@export var jump_force: float = 18.0
@export var fall_acceleration: float = 75.0

var target_velocity: Vector3 = Vector3.ZERO
var facing_angle: float = -90
var camera_weight: float = 0.1

@onready var anim: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float):
	var direction = Vector3.ZERO

	# ---- Movimiento WASD ----
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

	# ---- Velocidad horizontal deseada ----
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if not is_on_floor():
		if velocity.y < 0:
			velocity.y -= fall_acceleration * 1.8 * delta # caída más rápida
		else:
			velocity.y -= fall_acceleration * delta
	else:
		velocity.y = 0

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_force

	velocity.x = lerp(velocity.x, target_velocity.x, 0.15)
	velocity.z = lerp(velocity.z, target_velocity.z, 0.15)

	move_and_slide()

	$CameraController.position = lerp($CameraController.position, position, camera_weight)

func flip_to(angle: float):
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", angle, 0.15).set_trans(Tween.TRANS_SINE)
