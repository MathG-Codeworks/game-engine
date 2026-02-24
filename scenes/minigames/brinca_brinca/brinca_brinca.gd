extends Node3D

var character_scene: PackedScene = preload("res://scenes/character/character.tscn")
@onready var spawn_point: Marker3D = $SpawnPoint
@onready var answer_platform1: StaticBody3D = $AnswerPlatform1
@onready var answer_platform2: StaticBody3D = $AnswerPlatform2
@onready var answer_platform3: StaticBody3D = $AnswerPlatform3
@onready var answer_platform4: StaticBody3D = $AnswerPlatform4

func _ready() -> void:
	CharacterManager.spawn_local_player()
	CountdownManager.countdown_finished.connect(_on_time_finished)
	CountdownManager.start(10)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Character:
		body.respawn(spawn_point.global_position)
		
func _on_time_finished():
	print("Se acabo el tiempo")
	
	for platform in [answer_platform2,answer_platform2, answer_platform3, answer_platform4]:
		platform.visible = false
		platform.get_node("CollisionShape3D").disabled = true
		
