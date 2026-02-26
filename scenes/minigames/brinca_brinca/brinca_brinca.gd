extends Node3D

var character_scene: PackedScene = preload("res://scenes/character/character.tscn")
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var answer_platform1: StaticBody3D = $AnswerPlatform1
@onready var answer_platform2: StaticBody3D = $AnswerPlatform2
@onready var answer_platform3: StaticBody3D = $AnswerPlatform3
@onready var answer_platform4: StaticBody3D = $AnswerPlatform4

func _ready() -> void:
	CharacterManager.spawn_local_player()
	
	RoundManager.round_started.connect(_on_round_started)
	RoundManager.round_finished.connect(_on_round_finished)
	RoundManager.all_rounds_finished.connect(_on_game_finished)

	RoundManager.start_game(3, 10, 15) # 3 rondas de 10 segundos 15 segundos de intervalo entre rondas


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		body.respawn(spawn_point.global_position)
		
func _on_round_started(round_number):
	print("Ronda iniciada:", round_number)
	
	for platform in [answer_platform2, answer_platform3, answer_platform4]:
		platform.visible = true
		platform.get_node("CollisionShape3D").disabled = false
	

func _on_round_finished(round_number):
	print("Ronda terminada:", round_number)
	
	
	for platform in [answer_platform2, answer_platform3, answer_platform4]:
		platform.visible = false
		platform.get_node("CollisionShape3D").disabled = true

func _on_game_finished():
	print("Juego terminado")
		
