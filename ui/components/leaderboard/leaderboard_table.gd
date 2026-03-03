extends Control

@onready var table = $MarginContainer/Background/Table

func _ready() -> void:
	MultiplayerManager.ranking_updated.connect(_update_ranking_table)
	_update_ranking_table()

func _update_ranking_table():
	var columns = ["Usr", "Pos", "Nombre", "Puntos", "¿listo?"]
	var colors = {}
	var data = []
	
	for i in range(MultiplayerManager.ranking_players.size()):
		var player = MultiplayerManager.ranking_players[i]
		print(player)
		data.append([
			player.userId, #Oculto
			i + 1,
			player.username,
			player.score,
			"Listo!" if player.ready else "Gallina"
		])
		colors[player.userId] = player.color
		
	if data.is_empty():
		data = [["0", "-", "Sin jugadores", 0, ""]]
	
	var df = DataFrame.New(data, columns)
	table.data = df
	table.row_colors = colors
	table.render()
