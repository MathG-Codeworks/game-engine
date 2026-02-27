extends Control

@onready var tableRow = preload("res://ui/components/leaderboard/table_row.tscn")
@onready var tableCell = preload("res://ui/components/leaderboard/table_cell.tscn")

@export var data: DataFrame
@export var padding: int = 10
@export var row_height: int = 50

func _ready() -> void:
	pass
	
func render():	
	if $Rows:
		for child in $Rows.get_children():
			child.queue_free()
			
		await get_tree().process_frame
		
	if data:
		var rowCount = data.data.size()
		var new_height = (rowCount * row_height) + padding
		var leaderboard_table = get_parent().get_parent()
		
		if leaderboard_table:
			leaderboard_table.custom_minimum_size.y = new_height
			leaderboard_table.size.y = new_height
		
		for r in range(rowCount):
			var row = tableRow.instantiate()
			$Rows.add_child(row)
			
			for value in data.GetRow(r):
				var cell = tableCell.instantiate()
				cell.text = str(value)
				row.add_child(cell)
