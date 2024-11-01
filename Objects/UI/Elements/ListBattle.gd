extends HBoxContainer


var count = 0
var current_id = ""
var desc = ""

signal focused(scenario)
signal selected(scenario)


func _on_focus_entered():
	SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-6)
	$Arrow.visible = true
	$FArrow.visible = false
	$Name.label_settings.font_color = Constants.get("select_color")
	$Name.label_settings.font = load("res://Fonts/DialogueFontBold.tres")
	emit_signal("focused", get_loaded_battle())


func _on_focus_exited():
	$Arrow.visible = false
	$FArrow.visible = true
	$Name.label_settings.font_color = Color.WHITE
	$Name.label_settings.font = load("res://Fonts/DialogueFont.tres")
	
	
	
func set_label_name(new_name):
	$Name.text = new_name
	
	
func set_battle(battle):
	current_id = battle
	var bat = load("res://Resources/Scenarios/"+battle+".tres")
	if bat.is_boss:
		$BossLabel.visible = true
	set_label_name(bat.get_battle_name())
	

func get_loaded_battle():
	return load("res://Resources/Scenarios/"+current_id+".tres")
	
	
func _input(event):
	if has_focus():
		if Input.is_action_just_pressed("ui_accept"):
			emit_signal("selected", get_loaded_battle())
