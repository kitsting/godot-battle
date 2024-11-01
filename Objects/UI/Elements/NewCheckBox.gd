extends CheckBox

func _ready():
	if !has_focus():
		disabled = true


func _on_CheckBox_focus_entered():
	disabled = false


func _on_CheckBox_focus_exited():
	disabled = true
