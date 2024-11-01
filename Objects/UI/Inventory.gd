extends VBoxContainer

signal done


func _ready():
	display_normal_items()
	
	$Top/Button.grab_focus()


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		exit()
		
	var focus_owner = get_viewport().gui_get_focus_owner()
	if "current_id" in focus_owner and focus_owner.current_id != "":
		%Info/Item/ItemPicture.texture = focus_owner.load_item().texture
		%Info/Item/ItemPicture.visible = true
		%Info/MoreInfoPrompt.visible = true
	else:
		%Info/Item/ItemPicture.visible = false
		%Info/MoreInfoPrompt.visible = false

func exit():
	emit_signal("done")
	queue_free()


func _on_button_pressed():
	exit()
	
	
func display_normal_items():
	#Display capacity
	%Capacity.visible = true
	%Capacity/Have.text = str(PartyStats.inventory.size())
	%Capacity/Max.text = str(PartyStats.max_inventory)
	
	
	#Clear the list
	for child in %Items.get_children():
		child.queue_free()
	
	
	for item in PartyStats.inventory:
		#Make sure the item doesn't already exist in the list
		var exists = false
		for item_display in %Items.get_children():
			if item_display.has_id(item):
				item_display.add_one()
				exists = true
		if exists:
			continue
		
		#If the item doesn't exist, add it
		var new_item_display = load("res://Objects/UI/Elements/InventoryItem.tscn").instantiate()
		new_item_display.set_item(item)
		%Items.add_child(new_item_display)
		
	#Add the remaining empty slots
	for item in PartyStats.max_inventory-PartyStats.inventory.size():
		var new_item_display = load("res://Objects/UI/Elements/InventoryItem.tscn").instantiate()
		%Items.add_child(new_item_display)
