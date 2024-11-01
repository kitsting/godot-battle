extends Label


@export var connected_to : NodePath



func _ready():
	if connected_to != null:
		var node = get_node(connected_to)
		node.connect("focus_entered",embolden)
		node.connect("focus_exited",normal)
	text = "     " + text


func embolden():
	self_modulate = System.get_select_color()
	$Arrow.modulate.a = 1
	#add_font_override("font",load("res://Fonts/DialogueFontBold.tres"))
	
	
func normal():
	self_modulate = Color.WHITE
	$Arrow.modulate.a = 0
	#add_font_override("font",load("res://Fonts/DialogueFont.tres"))
