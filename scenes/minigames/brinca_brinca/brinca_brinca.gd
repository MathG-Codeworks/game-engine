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
@onready var mini_game_exer: Dictionary = {
	"exercises":[
		{
			"operation": "F(x) = 5x + x + 3",
			"options": [
				{"result": "5 + 1", "is_correct": true},
				{"result": "5x", "is_correct": false},
				{"result": "3", "is_correct": false},
				{"result": "6x + 3", "is_correct": false}
			] 
		},
		{
			"operation": "F(x) = 15x + 2",
			"options": [
				{"result": "15", "is_correct": true},
				{"result": "15x", "is_correct": false},
				{"result": "2", "is_correct": false},
				{"result": "17x", "is_correct": false}
			] 
		},
		{
			"operation": "F(x) = 4x^3 + 2x^2 + 2",
			"options": [
				{"result": "12x^2 + 4x", "is_correct": true},
				{"result": "64x + 4x", "is_correct": false},
				{"result": "6x^5 + 2", "is_correct": false},
				{"result": "2", "is_correct": false}
			] 
		},
		{
			"operation": "F(x) = 7x^2 + 10",
			"options": [
				{"result": "14x", "is_correct": true},
				{"result": "17x^2", "is_correct": false},
				{"result": "27x", "is_correct": false},
				{"result": "10x", "is_correct": false}
			] 
		}
	]
}

func _ready() -> void:
	CharacterManager.spawn_local_player()
	
	RoundManager.round_started.connect(_on_round_started)
	RoundManager.round_finished.connect(_on_round_finished)
	RoundManager.all_rounds_finished.connect(_on_game_finished)
	RoundManager.start_game(mini_game_exer.exercises.size(), 10, 15) # 3 rondas de 10 segundos 15 segundos de intervalo entre rondas
	
	var areas = [area_platform1, area_platform2, area_platform3, area_platform4]

	for i in areas.size():
		areas[i].body_entered.connect(
			_on_area_3d_platform_body_entered.bind(answer_platforms[i])
		)
	
	#on_screen_answ.scale.x / 4 = 0.24949277937412
	

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
	
	var current_exercise = mini_game_exer.exercises[round_number - 1]
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
		
