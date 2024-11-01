extends CanvasLayer


var badgeuibutton = preload("res://Objects/UI/Elements/BadgeUIButton.tscn")


signal selected(id)

# Called when the node enters the scene tree for the first time.
func _ready():
	%Cancel.grab_focus()
	
	for badge in PartyStats.has_badges:
		var new_badge = badgeuibutton.instantiate()
		new_badge.choose_mode = true
		new_badge.badge_id = badge
		
		var badge_info = PartyStats.load_badge(badge)
		new_badge.desc = badge_info.badge_desc
		new_badge.badge_name = badge_info.badge_name
		new_badge.badge_icon = badge_info.badge_sprite
		
		%VBox/Scroll/Grid.add_child(new_badge)
		
	update_ui()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	update_ui()
		

	if Input.is_action_just_pressed("ui_accept"):
		var focus_owner = get_viewport().gui_get_focus_owner()
		if "badge_id" in focus_owner:
			if focus_owner.can_select:
				emit_signal("selected", focus_owner.badge_id)
				queue_free()
				
	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("selected", "cancel")
		queue_free()


func update_ui():
	var focus_owner = get_viewport().gui_get_focus_owner()
	if "badge_name" in focus_owner:
		%VBox/TopLabel.text = focus_owner.badge_name
	if "desc" in focus_owner:
		%VBox/DescLabel.text = focus_owner.desc


func show_unequip_button(show_button):
	%NoBadge.visible = show_button
