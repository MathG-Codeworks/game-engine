extends Control

@onready var tableRow = preload("res://ui/components/leaderboard/table_row.tscn")
@onready var tableCell = preload("res://ui/components/leaderboard/table_cell.tscn")
@export var data: DataFrame


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func render():
	
	if data:
		var rowCount = data.data.size()
		
		for r in range(rowCount):
			var row = tableRow.instantiate()
			$Rows.add_child(row)
			
			for value in data.GetRow(r):
				var cell = tableCell.instantiate()
				cell.text = str(value)
				row.add_child(cell)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
