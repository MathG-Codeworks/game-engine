extends Node3D

signal player_entered_platform_area(body)

var current_exercise
var character_scene: PackedScene = preload("res://scenes/character/character.tscn")
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var answer_platforms: Array[StaticBody3D] = [
	$PlatformA,
	$PlatformB,
	$PlatformC,
	$PlatformD
]
@onready var area_platform1: Area3D = $PlatformA/Area3D
@onready var area_platform2: Area3D = $PlatformB/Area3D
@onready var area_platform3: Area3D = $PlatformC/Area3D
@onready var area_platform4: Area3D = $PlatformD/Area3D
@onready var on_screen_exer: Label3D = $QuestionScreen/ExerciseScreen
@onready var on_screen_answ: Area3D = $QuestionScreen/Area3D
@onready var answer_node = $QuestionScreen/Answer
@onready var correct_platform: StaticBody3D
const ANSWER_SCENE = preload("res://scenes/minigames/brinca_brinca/answer.tscn")

func _ready() -> void:
	CharacterManager.spawn_local_player()
	CharacterManager.spawn_ranking_players()
	
	RoundManager.round_started.connect(_on_round_started)
	RoundManager.round_finished.connect(_on_round_finished)
	RoundManager.all_rounds_finished.connect(_on_game_finished)
	RoundManager.start_game(
		MinigameManager.exercises.size(), 
		MinigameManager.round_duration,
		MinigameManager.round_intermission
	)
	
	var areas = [area_platform1, area_platform2, area_platform3, area_platform4]

	for i in areas.size():
		areas[i].body_entered.connect(
			_on_area_3d_platform_body_entered.bind(answer_platforms[i])
		)
		
		areas[i].body_exited.connect(
			_on_area_3d_platform_body_exited.bind(answer_platforms[i])
		)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		body.respawn(spawn_point.global_position)
		
func _on_area_3d_platform_body_entered(body: Node3D, platform: StaticBody3D) -> void:
	if body is Character:
		var color = body.underline_user_name.material_override.albedo_color
		if color:
			platform.add_color(color)
			
		if platform == correct_platform:
			print("estas en la respuesta correcta")
			
func _on_area_3d_platform_body_exited(body: Node3D, platform) -> void:
	if body is Character:
		var color = body.underline_user_name.material_override.albedo_color
		if color:
			platform.delete_color(color)
		
func _on_round_started(round_number):
	for platform in answer_platforms:
		platform.visible = true
		platform.get_node("CollisionShape3D").disabled = false
		platform.get_node("Area3D").monitoring = true
	
	self.current_exercise = MinigameManager.exercises[round_number - 1]
	on_screen_exer.text = current_exercise.operation
	 
	correct_platform = answer_node.assing_option(current_exercise.options, answer_platforms)

func _on_round_finished(_round_number):
	for platform in answer_platforms:
		var area: Area3D = platform.get_node("Area3D")
		var bodies = area.get_overlapping_bodies()
		
		for body in bodies:
			if body is Character and body.is_local_player:
				MinigameManager.evaluate_answer(self.current_exercise.operation, platform.option.result)
				break				
		if platform != correct_platform:
			platform.visible = false
			platform.get_node("CollisionShape3D").disabled = true
			platform.get_node("Area3D").monitoring = false

func _on_game_finished():
	print("Juego terminado")
		
