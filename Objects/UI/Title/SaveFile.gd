extends Control


@export var save_slot = "1"


var committed = false
var newgame = true

signal pressed(slot)
signal unpressed(slot)

signal load_request(slot)
signal delete_request(slot)

var select_color = Color(1,1,1)
var unselect_color = Color(0.5,0.5,0.5)



func _ready():
	select_color = System.get_select_color()
	unselect_color = System.get_unselect_color()
	
	$Options.visible = false
	$Back.self_modulate = unselect_color
	$Options.self_modulate = unselect_color
	reset()
	


func set_info(save_dict):
	if save_dict != null:
		newgame = false
		%SaveName.text = save_dict["playername"]
		
		if save_dict.has("last_save_date"):
			var time = save_dict["last_save_date"].split("-")
			%Time.text = time[2]+"-"+time[1]+"-"+time[0]
			
		if save_dict.has("last_room_name"):
			%AreaName.text = save_dict["last_room_name"]
			
		if save_dict.has("last_area"):
			var filename = Constants.areas[save_dict["last_area"]][1]
			print(filename)
			%AreaIcon.texture = load("res://Graphics/UI/Menus/LoadScreen/Locations/"+filename+".png")
		
		for party in save_dict["current_party"]:
			var new_member = PartyStats.load_party_name(party)
			var new_icon = TextureRect.new()
			new_icon.texture = load(new_member.health_icon)
			new_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			%PartyIcons.add_child(new_icon)
		
		%GameInfo.visible = true
		%DeleteButton.disabled = false
	else:
		%NewGameLabel.visible = true
		%DeleteButton.disabled = true

		
		
func set_committed(is_committed = true):
	if is_committed:
		committed = true
		$Back.self_modulate = Constants.commit_color
	else:
		committed = false


func _on_focus_entered():
	SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-6)
	$Back.self_modulate = select_color
	$Select.visible = true


func _on_focus_exited():
	$Back.self_modulate = unselect_color
	$Select.visible = false
	

func reset():
	for child in %PartyIcons.get_children():
		child.queue_free()
	%GameInfo.visible = false
	%NewGameLabel.visible = false
	set_info(await System.load_game(save_slot, true))
	
	
func _input(_event):
	if $Options.visible:
		if Input.is_action_just_pressed("ui_cancel"):
			$Options.visible = false
			emit_signal("unpressed", self)
			focus_mode = Control.FOCUS_ALL
	
	
	if has_focus():
		if Input.is_action_just_pressed("ui_accept"):
			SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
			emit_signal("pressed", self)
			focus_mode = Control.FOCUS_NONE
			$Options.visible = true
			await get_tree().create_timer(0.3).timeout
			%LoadButton.grab_focus()
	


func _on_load_button_pressed():
	emit_signal("load_request", save_slot)


func _on_delete_button_pressed():
	emit_signal("delete_request", save_slot)


func _on_back_button_pressed():
	$Options.visible = false
	emit_signal("unpressed", self)
	focus_mode = Control.FOCUS_ALL


func focus_delete_button():
	%DeleteButton.grab_focus()
