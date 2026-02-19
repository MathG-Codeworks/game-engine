extends Resource
class_name DataFrame

@export var data: Array
@export var columns: PackedStringArray

static func New(d: Array, c: PackedStringArray) -> DataFrame:
	var df = DataFrame.new()
	
	df.data = d
	if c:
		df.columns = c
	
	return df
	
func  GetColumn(col: String	):
	assert(col in columns)
	
	var ix = columns.find(col)
	var result = []
	
	for row in data:
		result.append(row[ix])
		
	return result
	
func GetRow(i: int):
	assert(i < len(data))
	return data[i]
	
func _sort_by(row1, row2, ix, desc) -> bool:
	var result: bool
	if row1[ix] < row2[ix]:
		result = true
	else:
		result = false 
	
	if desc:
		result = !result
	
	return result
	
func SortBy(col_name: String, desc: bool = false):
	assert(col_name in columns)
	var ix = columns.find(col_name)
	data.sort_custom(_sort_by.bind(ix, desc))
	
	var posIndex = columns.find("Pos")
	if posIndex != -1:
		for i in range(data.size()):
			data[i][posIndex] = i + 1
			
	
func _to_string():
	if len(data) == 0:
		return "<empty DataFrame>"
		
	var result = "|".join(columns) + "\n ---------------\n"
	
	for row in data:
		result += " | ".join(row) + "\n"
	
	return result
