extends Control


var files_visible = false
var file_active = false
var delete_mode:
	set(set_delete_mode):
		#$Files/Buttons/Copy.disabled = set_delete_mode
		$DeleteModeIndicator.visible = set_delete_mode
		
		if set_delete_mode:
			$Files/Buttons/Delete.set_new_text("Cancel")
		else:
			$Files/Buttons/Delete.set_new_text("Delete")
		
		delete_mode = set_delete_mode
		
		
var current_slot_pos = Vector2(0,0)
var current_slot : Node = null


func _ready():
	#Animation
	$Fadein.visible = true
	$DescRect.visible = false
	create_tween().tween_property($Fadein,"color:a",0,1)
	
	#Reset relevant game variables
	System.cutscene = false
	get_tree().paused = false
	
	#Connect signals
	for saveslot in $Files.get_children():
		if saveslot.is_in_group("savefile"):
			saveslot.connect("pressed", save_file_clicked)
			saveslot.connect("unpressed", save_file_back)
			saveslot.connect("load_request", load_request)
			saveslot.connect("delete_request", delete_request)
	
	#Give the main menu focus
	await get_tree().create_timer(1.2).timeout
	set_main_menu_enable(true)
	$MainMenu/Start.grab_focus()


func _input(_event):
	if !$DeleteConfirm.visible and !file_active:
		if Input.is_action_just_pressed("ui_cancel"):
			delete_mode = false
			files_visible = false
			$Files.visible = false
			set_main_menu_enable(true)
			$MainMenu/Start.grab_focus()
			
			
func _process(delta):
	var focused = get_viewport().gui_get_focus_owner()
	if focused != null:
		if "desc" in focused:
			%CurrentDesc.text = focused.desc
		else:
			%CurrentDesc.text = focused.get_parent().editor_description
			
	if %CurrentDesc.text != "" and %CurrentDesc.text != "Button description":
		$DescRect.visible = true
	else:
		$DescRect.visible = false


func _on_start_pressed():
	files_visible = true
	$Files.visible = true
	set_main_menu_enable(false)
	$Files/SaveFile1.grab_focus()
	$MainMenu/Start.set_custom_modulate(Constants.commit_color)



func set_main_menu_enable(state = true):
	for button in $MainMenu.get_children():
		if state:
			button.focus_mode = FOCUS_ALL
		else:
			button.focus_mode = FOCUS_NONE


func _on_quit_pressed():
	get_tree().quit()


func _on_delete_pressed():
	delete_mode = !delete_mode
	


func save_file_clicked(save_slot_node):
	file_active = true
	
	for child in $Files.get_children():
		if child != save_slot_node:
			create_tween().tween_property(child,"modulate:a",0,0.25)
		
	save_slot_node.z_index = 3
		
	current_slot = save_slot_node
	current_slot_pos = save_slot_node.position.y
	create_tween().tween_property(save_slot_node,"position:y",80,0.25)
		
		
func save_file_back(save_slot_node):
	for child in $Files.get_children():
		if child != save_slot_node:
			create_tween().tween_property(child,"modulate:a",1,0.25)
		
	await create_tween().tween_property(save_slot_node,"position:y",current_slot_pos,0.25).finished
	
	save_slot_node.z_index = 0
	
	current_slot.grab_focus()
	current_slot = null
	
	await get_tree().process_frame
	file_active = false
	
	
func load_request(save_slot):
	System.load_game(save_slot)
	

func delete_request(save_slot):
	$DeleteConfirm.visible = true
	await get_tree().create_timer(0.25).timeout
	var should_delete = await $DeleteConfirm.prompt
	await get_tree().process_frame
	$DeleteConfirm.visible = false
	
	if should_delete:
		var file_to_remove = "user://save"+save_slot+".sav"
		OS.move_to_trash(ProjectSettings.globalize_path(file_to_remove))
		get_tree().call_group("savefile","reset")
		current_slot._on_back_button_pressed()
	else:
		current_slot.focus_delete_button()


func _on_refresh_pressed():
	get_tree().call_group("savefile","reset")


func _on_settings_pressed():
	$SettingsRect.visible = true
	set_main_menu_enable(false)
	$MainMenu/Settings.set_custom_modulate(Constants.commit_color)
	
	var new_pause = load("res://Objects/UI/SettingsUI.tscn").instantiate()
	$SettingsRect/SettingsMargin.add_child(new_pause)
	await new_pause.done
	await get_tree().create_timer(0.05).timeout
	
	$SettingsRect.visible = false
	set_main_menu_enable(true)
	$MainMenu/Settings.grab_focus()
