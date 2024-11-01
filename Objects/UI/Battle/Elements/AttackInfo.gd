extends NinePatchRect


signal closed

var shown = false


func show_info(attack):
	shown = true
	if "attackname" in attack:
		$Margin/VBox/HBox/Name.text = attack.attackname
	if "extended_desc" in attack:
		$Margin/VBox/Description.text = attack.extended_desc
	if "cost" in attack:
		$Margin/VBox/HBox/Stats/Cost.text = "Cost: "+str(attack.cost)+" Energy"
		
	if "affects" in attack:
		match attack.get_affects():
			"enemy":
				$Margin/VBox/HBox/Stats/Affects.text = "Affects: Enemy"
			"all_enemies":
				$Margin/VBox/HBox/Stats/Affects.text = "Affects: All Enemies"
			"player":
				$Margin/VBox/HBox/Stats/Affects.text = "Affects: Party Member"
			"grid":
				$Margin/VBox/HBox/Stats/Affects.text = "Affects: Grid Square"
			_:
				$Margin/VBox/HBox/Stats/Affects.text = ""
	else:
		$Margin/VBox/HBox/Stats/Affects.text = ""


func _input(_event):
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel") or Input.is_action_just_pressed("more_info"):
		shown = false
		emit_signal("closed")
		
		
func set_color(new_color):
	self_modulate = new_color
