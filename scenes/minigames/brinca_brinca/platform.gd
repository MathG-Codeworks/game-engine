extends Node

@onready var label = $Label3D
@onready var floor_node : MeshInstance3D = $Floor

var option
var colors : Array[Color] = []
var shader_material : ShaderMaterial

func _ready() -> void:
	self.shader_material = ShaderMaterial.new()
	self.shader_material.shader = preload("res://scenes/minigames/brinca_brinca/platform_color.gdshader")
	self.floor_node.material_override = shader_material

func set_text(p_text: String) -> void:
	self.label.text = p_text

func get_text() -> String:
	return label.text
	
func add_color(p_color: Color) -> void:
	if not self.colors.has(p_color):
		self.colors.append(p_color)
		
	_update_colors()
	
func delete_color(p_color: Color) -> void:
	if self.colors.has(p_color):
		self.colors.erase(p_color)
		
	_update_colors()
	
func _update_colors() -> void:
	shader_material.set_shader_parameter("player_count", colors.size())
	for i in range(4):
		shader_material.set_shader_parameter("color" + str(i + 1), Color.WHITE)

	for i in range(min(colors.size(), 4)):
		shader_material.set_shader_parameter("color" + str(i + 1), colors[i])

func set_color(p_color: Color) -> void:
	var material = StandardMaterial3D.new()
	material.albedo_color = p_color
	self.floor_node.material_override = material
