extends VBoxContainer


var badgeuibutton = preload("res://Objects/UI/Elements/BadgeUIButton.tscn")
var can_exit = true


signal done


func _ready():
	%Desc/Name.text = ""
	%Desc/Description.text = ""
	
	$Top/Button.grab_focus()
	
	var slotid = 0
	for badge in PartyStats.equipped_badges:
		var new_badge = badgeuibutton.instantiate()
		new_badge.slot = slotid
		
		if badge != null:
			var badge_info = PartyStats.load_badge(badge)
			new_badge.desc = badge_info.badge_desc
			new_badge.badge_name = badge_info.badge_name
			new_badge.badge_icon = badge_info.badge_sprite
		
		$Margin/Badges.add_child(new_badge)
		slotid += 1
		
	for slot in 10-slotid:
		var null_slot = load("res://Objects/UI/Elements/null_slot.tscn").instantiate()
		$Margin/Badges.add_child(null_slot)


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if can_exit:
			exit()
		
	var focus_owner = get_viewport().gui_get_focus_owner()
	if "choose_mode" in focus_owner:
		if !focus_owner.choose_mode:
			%Desc/Name.text = focus_owner.badge_name
			%Desc/Description.text = focus_owner.desc
	else:
		%Desc/Name.text = ""
		%Desc/Description.text = ""

func exit():
	emit_signal("done")
	queue_free()


func _on_button_pressed():
	exit()


func set_can_exit(state):
	can_exit = state
