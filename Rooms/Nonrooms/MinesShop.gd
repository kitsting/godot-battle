extends CanvasLayer

@export_file("*.dialogue") var dialogue

signal done_shopping

var can_input = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$Info.visible = false
	$CoinCount/Count/Number.text = str(System.registry_lookup("money"))
	
	for shelf in $Items.get_children():
		for item in shelf.get_children():
			item.connect("focus_entered", update_info)
	
	await get_tree().create_timer(0.8).timeout
	TextSystem.show_dialogue("Enter", dialogue)
	await TextSystem.text_finished
	$Items/BottomShelf.get_child(0).grab_focus()
	$ButtonPrompts.visible = true
	can_input = true
	
	
	
	
func _input(event):
	if can_input:
		var focused = get_viewport().gui_get_focus_owner()
		if Input.is_action_just_pressed("more_info"):
			if focused.is_in_group("shop_item"):
				$ButtonPrompts.visible = false
				can_input = false
				TextSystem.show_dialogue("Ask"+focused.get_filename().replace(" ",""), dialogue)
				await TextSystem.text_finished
				await get_tree().process_frame
				$ButtonPrompts.visible = true
				can_input = true
				
				
		if Input.is_action_just_pressed("ui_cancel"):
			can_input = false
			TextSystem.show_dialogue("Exit", dialogue)
			await TextSystem.text_finished
			await get_tree().process_frame
			emit_signal("done_shopping")
			
			
		if Input.is_action_just_pressed("ui_accept"):
			if focused.is_in_group("shop_item"):
				can_input = false
				var confirm_prompt = load("res://Objects/UI/Elements/prompt.tscn").instantiate()
				confirm_prompt.set_prompt("Really buy it?","Yeah","Nah")
				add_child(confirm_prompt)
				var confirmation = await confirm_prompt.selection
				focused.grab_focus()
				await get_tree().create_timer(0.1)
				can_input = true
				if confirmation:
					if System.registry_lookup("money") >= focused.cost:
						if focused.canbuy:
							if focused.type == "Pin":
								PartyStats.add_badge(focused.get_filename())
							if focused.type == "Item":
								PartyStats.add_inventory(focused.get_filename())
							
							System.collect_money(-focused.cost)
							focused.on_buy()
							$PurchaseSound.play()
							update_info()

func update_info():
	var focused = get_viewport().gui_get_focus_owner()
	if focused != null:
		$Info.visible = true
		if focused.is_in_group("shop_item"):
			$Info/TopArrow.global_position.x = focused.global_position.x-20
			$Info/BottomArrow.global_position.x = focused.global_position.x-20
			$Info/MarginContainer/Text/Itemname.text = focused.get_itemname()
			$Info/MarginContainer/Text/Itemdesc.text = focused.get_desc()
			
			if focused.get_parent().name == "TopShelf":
				$Info/BottomArrow.visible = true
				$Info/TopArrow.visible = false
				$Info.position.y = 135
			else:
				$Info/BottomArrow.visible = false
				$Info/TopArrow.visible = true
				$Info.position.y = 65
				
				
			if focused.type == "Pin":
				$ItemCount.visible = false
			
			elif focused.type == "Item":
				$ItemCount.visible = true
				$ItemCount/Count/Number.text = str(PartyStats.inventory.count(focused.get_filename()))
				
			if focused.cost <= 0:
				$ButtonPrompts/Buy/Label.text = "Take"
			else:
				$ButtonPrompts/Buy/Label.text = "Buy"
				
