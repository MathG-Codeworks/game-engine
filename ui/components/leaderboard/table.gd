extends Control

@onready var tableRow = preload("res://ui/components/leaderboard/table_row.tscn")
@onready var tableCell = preload("res://ui/components/leaderboard/table_cell.tscn")
@onready var rows = $MarginContainer/Rows

@export var data: DataFrame
@export var padding: int = 10
@export var row_height: int = 50
@export var row_colors: Dictionary = {}

func _ready() -> void:
	pass
	
func render():	
	if rows:
		for child in rows.get_children():
			child.queue_free()
			
		await get_tree().process_frame
		
	if data:
		var rowCount = data.data.size()
		var new_height = ((rowCount + 1) * row_height) + padding
		var leaderboard_table = get_parent().get_parent()
		
		if leaderboard_table:
			leaderboard_table.custom_minimum_size.y = new_height
			leaderboard_table.size.y = new_height
			
		var header_row = tableRow.instantiate()
		rows.add_child(header_row)
		
		for c in range(1, data.columns.size()):
			var column_name = data.columns[c]
			
			var cell = tableCell.instantiate()
			cell.text = str(column_name)
			cell.add_theme_color_override("font_color", Color.WHITE)
			
			header_row.add_cell(cell)
		
		for r in range(rowCount):
			var row = tableRow.instantiate()
			rows.add_child(row)
			
			var row_data = data.GetRow(r)
			var user_id = row_data[0]
			
			if row_colors.has(user_id):
				row.set_row_color(row_colors[user_id])
			
			for c in range(1, row_data.size()):
				var cell = tableCell.instantiate()
				var value = row_data[c]
				
				if c == 0 or data.columns[c] == "Pos":
					cell.text = "#" + str(value)
				else:
					cell.text = str(value)
					
				row.add_cell(cell)
