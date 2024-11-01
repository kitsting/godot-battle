extends CanvasLayer

var child_open = false

signal done


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#$OMargin/Background/IMargin/HBox/PartyInfo/Coins/Count.text = str(System.registry_lookup("money"))
	
	#OMargin/Background/IMargin/HBox/PartyInfo/NinePatchRect2.set_name(System.registry_lookup("playername"))
	
	get_node("%ResumeButton").grab_focus()


func _input(event):
	if Input.is_action_just_pressed("pause") and !Input.is_action_just_pressed("ui_cancel"):
		exit()
	
	if Input.is_action_just_pressed("ui_cancel") and !child_open:
		exit()
		
		
func _process(delta):
	var focused = get_viewport().gui_get_focus_owner()
	if focused != null:
		if "desc" in focused:
			%Desc.text = focused.desc
		else:
			%Desc.text = focused.get_parent().editor_description


func exit():
	emit_signal("done")
	queue_free()


func _on_BadgeButton_pressed():
	hide_description(true)
	get_node("%BadgeButton").release_focus()
	await open_window("res://Objects/UI/BadgesUI.tscn")
	get_node("%BadgeButton").grab_focus()
	hide_description(false)


func _on_AudioButton_pressed():
	get_node("%AudioButton").release_focus()
	await open_window("res://Objects/UI/SettingsUI.tscn")
	get_node("%AudioButton").grab_focus()


func _on_SelectableButton_pressed():
	exit()


func open_window(path):
	var new_pause = load(path).instantiate()
	%Menu.add_child(new_pause)
	$LeftDim.visible = true
	$RightDim.visible = false
	child_open = true
	for child in %Buttons.get_children():
		child.focus_mode = 0
	await new_pause.done
	await get_tree().create_timer(0.05).timeout
	child_open = false
	$LeftDim.visible = false
	$RightDim.visible = true
	for child in %Buttons.get_children():
		child.focus_mode = 2
		
		
func hide_description(hide = true):
	%Desc.visible = !hide
	$HSeparate.visible = !hide


func _on_inventory_button_pressed():
	get_node("%InventoryButton").release_focus()
	await open_window("res://Objects/UI/Inventory.tscn")
	get_node("%InventoryButton").grab_focus()


func _on_exit_button_pressed():
	System.save_game()
	
	for button in %Buttons.get_children():
		button.disabled = true
	
	get_tree().paused = false
	var new_transition = load("res://Objects/Battle/ToBlack.tscn").instantiate()
	new_transition.set_speed(2.5)
	get_tree().get_root().add_child(new_transition)
	await new_transition.midpoint
	get_tree().change_scene_to_file("res://Rooms/Nonrooms/LoadFile.tscn")
