extends Panel

@onready var content = $Grid

func add_cell(cell: Control) -> void:
	content.add_child(cell)

func set_row_color(color: Color) -> void:
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = color
	
	add_theme_stylebox_override("panel", stylebox)
