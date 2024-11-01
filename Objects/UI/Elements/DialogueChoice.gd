extends HBoxContainer

var nextid = ""


func set_text(newtext):
	$Label.text = newtext
	
func get_text():
	return $Label.text


func _on_Choice_focus_entered():
	$Arrow.visible = true
	$FArrow.visible = false
	$Label.label_settings.font = load("res://Fonts/DialogueFontBold.tres")
	$Label.label_settings.font_color = System.get_select_color()


func _on_Choice_focus_exited():
	$Arrow.visible = false
	$FArrow.visible = true
	$Label.label_settings.font = load("res://Fonts/DialogueFont.tres")
	$Label.label_settings.font_color = Color.WHITE
