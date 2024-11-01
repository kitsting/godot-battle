extends ColorRect


var current_selection = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Yes/Arrow.visible = true
	$No/Arrow.visible = false
	
	$Yes/Label.label_settings.font_color = Constants.select_color
	$No/Label.label_settings.font_color = Color.WHITE


func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		if current_selection == 0:
			select_no()
			SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-12)
		else:
			select_yes()
			SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-12)
			
	if Input.is_action_just_pressed("ui_up"):
		if current_selection == 1:
			select_yes()
			SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-12)
		else:
			select_no()
			SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-12)
		
	if Input.is_action_just_pressed("ui_accept"):
		SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-12)
		if current_selection == 1:
			get_tree().quit()
		else:
			var new_transition = load("res://Objects/Battle/ToBlack.tscn").instantiate()
			new_transition.set_speed(2.5)
			get_tree().get_root().add_child(new_transition)
			await new_transition.midpoint
			get_tree().change_scene_to_file("res://Rooms/Nonrooms/LoadFile.tscn")
		
		
		
func select_yes():
	current_selection = 0
	$Yes/Arrow.visible = true
	$No/Arrow.visible = false
	
	$Yes/Label.label_settings.font_color = Constants.select_color
	$No/Label.label_settings.font_color = Color.WHITE
	
func select_no():
	current_selection = 1
	$Yes/Arrow.visible = false
	$No/Arrow.visible = true
	
	$Yes/Label.label_settings.font_color = Color.WHITE
	$No/Label.label_settings.font_color = Constants.select_color
