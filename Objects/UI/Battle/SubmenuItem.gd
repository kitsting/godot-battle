extends HBoxContainer


var cooldown = false
var select_color = Color()
var attackid = 0
var stack = 1
var cost = 0
var disabled = false

signal new_selection(id)


func _ready():
	set_selected(false)

func set_text(new_text):
	$Label.text = new_text
	
	
func set_selected(select = false):
	if !select:
		$Arrow.visible = false
		$FArrow.visible = true
		$Label.label_settings.font_color = Color(1, 1, 1)
		$Label.label_settings.font = load("res://Fonts/battle.ttf")
	else:
		$Arrow.visible = true
		$FArrow.visible = false
		$Label.label_settings.font_color = select_color
		$Label.label_settings.font = load("res://Fonts/battle_bold.ttf")
		
		
func grey_out(ungrey = false):
	if !ungrey:
		$Label.modulate = Color(0.45, 0.45, 0.45)
	else:
		$Lable.modulate = Color(1, 1, 1)


func set_cooldown(use_cooldown, number = 3):
	if use_cooldown:
		var remaining_cost = 100-cost
		var redness = 0
		
		if remaining_cost > 0:
			redness = number/float(remaining_cost)
		else:
			redness = 1
		
		if redness != 0:
			$Label.self_modulate = Color(1,1-redness,1-redness)
		
		$Heat.value = redness*100*4
		
		if redness > 0.4:
			$Heat/Warning.visible = true
			
	else:
		$Heat.visible = false
		
	
#	cooldown = use_cooldown
#	grey_out(!use_cooldown)
#
#	$Cooldown.visible = use_cooldown
#	$Cooldown.text = "("+str(number)+")"
	
	
func set_color(new_select_color):
	select_color = new_select_color
	
	
func show_icon(number):
	get_node("Icon"+str(number)).visible = true


func _on_control_focus_entered():
	set_selected(true)
	emit_signal("new_selection", attackid)


func _on_control_focus_exited():
	set_selected(false)


func get_attack_name():
	return $Label.text
	

func add_one():
	stack += 1
	$Stack.text = "(" + str(stack) + ")"
	
	
func show_stack():
	$Stack.visible = true
	$Heat.visible = false
