extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var colums = ["Pos", "name", "score"]
	var data = [
		[1, "user_1", 200],
		[2, "user_2", 8543],
		[3, "user_3", 20000],
		[4, "user_4", 10000]
	]
	
	var df = DataFrame.New(data, colums)
	
	df.SortBy("score", true)
	
	$Background/Table.data = df
	$Background/Table.render()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
