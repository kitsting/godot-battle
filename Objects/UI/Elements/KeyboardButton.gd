extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Key_pressed():
	get_tree().call_group("keyboard","add_letter",text)

#
#func _on_Key_focus_entered():
#	add_font_override("font",load("res://Fonts/DialogueFontBold.tres"))
#
#
#func _on_Key_focus_exited():
#	add_font_override("font",load("res://Fonts/DialogueFont.tres"))
