extends Control

func _ready():
	update_colors()


func update_colors():
	var i = $Guards.get_child_count()
	for child in $Guards.get_children():
		child.modulate.v = 1-(i*0.15)
		i -= 1
