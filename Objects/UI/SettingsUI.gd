extends VBoxContainer

var active = true

signal done


func _ready():
	if active:
		now_active()


func _input(event):
	if active:
		if Input.is_action_just_pressed("ui_cancel"):
			exit()


func _on_Button_pressed():
	exit()

func exit():
	emit_signal("done")
	queue_free()


func now_active():
	$Top/Button.grab_focus()
