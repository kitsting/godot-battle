extends CanvasLayer

var waiting = true

signal selection


func _ready():
	$NinePatchRect/Buttons/No.grab_focus()



func set_prompt(prompt_text, yes_text, no_text):
	$NinePatchRect/Confirmation.text = prompt_text
	$NinePatchRect/Buttons/No.set_new_text(no_text)
	$NinePatchRect/Buttons/Yes.set_new_text(yes_text)
	


func _on_no_pressed():
	if !waiting:
		emit_signal("selection", false)
		queue_free()
	else:
		waiting = false
	
func _on_yes_pressed():
	if !waiting:
		emit_signal("selection", true)
		queue_free()
