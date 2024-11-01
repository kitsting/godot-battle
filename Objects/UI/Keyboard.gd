extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	get_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_focus():
	$Background/IMargin/HBox/Keys/Uppercase/A.grab_focus()


func _on_Delete_pressed():
	get_tree().call_group("keyboard","backspace")


func _on_Random_pressed():
	get_tree().call_group("keyboard","random_string")


func _on_Clear_pressed():
	get_tree().call_group("keyboard","clear")
	

func _on_Done_pressed():
	get_tree().call_group("keyboard","enter")
