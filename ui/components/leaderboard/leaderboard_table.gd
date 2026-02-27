extends Control

func _ready() -> void:
	MultiplayerManager.ranking_updated.connect(_update_ranking_table)
	_update_ranking_table()

func _update_ranking_table():
	var columns = ["Pos", "name", "score", "ready?"]
	var data = []
	
	for i in range(MultiplayerManager.ranking_players.size()):
		var player = MultiplayerManager.ranking_players[i]
		data.append([
			i + 1,
			player.username,
			player.score,
			"Listo!" if player.ready else "Gallina"
		])
		
	if data.is_empty():
		data = [["-", "Sin jugadores", 0]]
	
	var df = DataFrame.New(data, columns)
	$MarginContainer/Background/Table.data = df
	$MarginContainer/Background/Table.render()
