extends NinePatchRect


func set_text(new_text):
	%InfoText.text = new_text


#Set to a negative number to hide the cost
func set_cost(new_cost):
	if new_cost >= 0:
		%InfoCost.visible = true
		%InfoCost.text = "-"+str(new_cost)+" Energy "
	else:
		%InfoCost.visible = false
		
	if new_cost > BattleSystem.currentap:
		set_cost_color(Color.RED)
	else:
		set_cost_color(Color.WHITE)
		
		

func set_cost_color(new_color):
	%InfoCost.label_settings.font_color = new_color
