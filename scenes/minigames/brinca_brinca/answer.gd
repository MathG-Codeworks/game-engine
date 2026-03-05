extends Node3D

@onready var answer1: Label3D = $Label3D
@onready var answer2: Label3D = $Label3D2
@onready var answer3: Label3D = $Label3D3 
@onready var answer4: Label3D = $Label3D4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func assing_option(options: Array, platforms: Array[StaticBody3D]):
	var labels = [answer1, answer2, answer3, answer4]
	options.shuffle()
	var correct_platform: StaticBody3D
	for i in range(options.size()):
		var platform = platforms[i]
		var option = options[i]
		
		labels[i].text = platform.get_node("Label3D").text + ".  " + option.result
		
		if option.is_correct:
			correct_platform = platform
	
	return correct_platform
	
