extends Node3D

signal player_entered_platform_area(body)

var character_scene: PackedScene = preload("res://scenes/character/character.tscn")
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var answer_platforms: Array[StaticBody3D] = [
	$AnswerPlatform1,
	$AnswerPlatform2,
	$AnswerPlatform3,
	$AnswerPlatform4
]
@onready var area_platform1: Area3D = $AnswerPlatform1/Area3D
@onready var area_platform2: Area3D = $AnswerPlatform2/Area3D
@onready var area_platform3: Area3D = $AnswerPlatform3/Area3D
@onready var area_platform4: Area3D = $AnswerPlatform4/Area3D
@onready var on_screen_exer: Label3D = $QuestionScreen/ExerciseScreen
@onready var on_screen_answ: Area3D = $QuestionScreen/Area3D
@onready var answer_node = $QuestionScreen/Answer
@onready var correct_platform: StaticBody3D
const ANSWER_SCENE = preload("res://scenes/minigames/brinca_brinca/answer.tscn")

func _ready() -> void:
	CharacterManager.spawn_ranking_players()
	
	RoundManager.round_started.connect(_on_round_started)
	RoundManager.round_finished.connect(_on_round_finished)
	RoundManager.all_rounds_finished.connect(_on_game_finished)
	RoundManager.start_game(MinigameManager.exercises.size(), 10, 15) # 3 rondas de 10 segundos 15 segundos de intervalo entre rondas
	
	var areas = [area_platform1, area_platform2, area_platform3, area_platform4]

	for i in areas.size():
		areas[i].body_entered.connect(
			_on_area_3d_platform_body_entered.bind(answer_platforms[i])
		)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		body.respawn(spawn_point.global_position)
		
func _on_area_3d_platform_body_entered(body: Node3D, platform: StaticBody3D) -> void:
	if body is Character:
		if platform == correct_platform:
			print("estas en la respuesta correcta")
		
func _on_round_started(round_number):
	print("Ronda iniciada:", round_number)
	
	for platform in answer_platforms:
		platform.visible = true
		platform.get_node("CollisionShape3D").disabled = false
		platform.get_node("Area3D").monitoring = true
	
	var current_exercise = MinigameManager.exercises[round_number - 1]
	on_screen_exer.text = current_exercise.operation
	 
	correct_platform =  answer_node.assing_option(current_exercise.options, answer_platforms)
	print(correct_platform)

func _on_round_finished(round_number):
	print("Ronda terminada:", round_number)
	
	for platform in answer_platforms:
		if platform != correct_platform:
			platform.visible = false
			platform.get_node("CollisionShape3D").disabled = true
			platform.get_node("Area3D").monitoring = false
		else:
			var area: Area3D = platform.get_node("Area3D")
			var bodies = area.get_overlapping_bodies()
			
			for body in bodies:
				if body is Character:
					print("Cuerpo en plataforma correcta: ", body.name)

func _on_game_finished():
	print("Juego terminado")
		
