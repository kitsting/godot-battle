extends Control

signal prompt(delete)


func _on_visibility_changed():
	if visible:
		%NoDelete.grab_focus()


func _on_no_delete_pressed():
	emit_signal("prompt", false)


func _on_yes_delete_pressed():
	emit_signal("prompt", true)
	
	
	
func _input(_event):
	if visible:
		if Input.is_action_just_pressed("ui_cancel"):
			emit_signal("prompt", false)
