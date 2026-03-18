extends Node3D

@onready var answer1: Label3D = $Label3D
@onready var answer2: Label3D = $Label3D2
@onready var answer3: Label3D = $Label3D3 
@onready var answer4: Label3D = $Label3D4

const letters = ["A", "B", "C", "D"]
	
func assing_option(options: Array, platforms: Array[StaticBody3D]):
	var labels = [answer1, answer2, answer3, answer4]
	var correct_platform: StaticBody3D
	
	for i in range(options.size()):
		var platform = platforms[i]
		var option = options[i]
		
		platform.set_text(letters[i])
		platform.option = option
		labels[i].text = platform.get_text() + ".  " + option.result
		
		if option.is_correct:
			correct_platform = platform
	
	return correct_platform
	
