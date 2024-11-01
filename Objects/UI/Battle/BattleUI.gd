extends CanvasLayer

#Selection variables
var mainselect = 0
var mainselectprev = mainselect
var maincommit = false
var subselect = 0

#Variables to keep track of who's turn it is
var currentturn = 0
var turns = 0
var target = 0

#Reference variables
var useattacks = null
var gridref = null

#Other variables
var waiting = false
var enemy_ui_shown = false
var maindesc = ["Deal damage to your opponent", 
				"Actions not involving combat", 
				"Use an item from your inventory", 
				"Cool down and take a breather..."]
				
var mainattacks = []
var tactics = []
var inventory = []

var playerarray = []
				
				
#Preloads
var submenuitem = preload("res://Objects/UI/Battle/SubmenuItem.tscn")
				
				
signal player_turn_changed
signal ui_accept_pressed

func _ready():
	#Hide the ui
	for child in $Actions.get_children():
		child.set_panel_visible(false)
	
	#Get the battle grid and establish connections
	gridref = get_tree().get_nodes_in_group("battle_grid")[0]
	gridref.connect("enemy_selection_name", update_enemy_name)
	
	#Wait a bit before connecting change_sides to prevent switching on the first instance of it
	#Also wait before setting turns to ensure that all player instances are created first
	await get_tree().create_timer(0.1).timeout
	BattleSystem.connect("side_change", change_sides)
	BattleSystem.connect("battle_finished", battle_over)
	turns = gridref.get_players().size()
	
	#Make healthbars
	var iteration = 0
	for member in gridref.get_players():
		var new_healthnode = load("res://Objects/UI/Battle/HealthNode.tscn").instantiate()
		new_healthnode.party_num = member.party_number
		new_healthnode.player_num = iteration
		member.connect("health_changed", new_healthnode.set_value)
		$TopUI/Health.add_child(new_healthnode)
		playerarray.append(member.party_number)
		iteration += 1
		


func _process(_delta):
	#Use the proper set of attacks
	if mainselect == 0:
		useattacks = mainattacks
	elif mainselect == 1:
		useattacks = tactics
	elif mainselect == 2:
		useattacks = inventory
		
	#Don't show an AP cost if a move isn't selected
	if !maincommit:
		$Info.set_cost(-1)
		BattleSystem.end_preview()
		
	#Make sure that the submenu has focus if it's out
	if maincommit and get_viewport().gui_get_focus_owner() == null and !waiting:
		if %Options.get_child(0) != null:
			%Options.get_child(0).grab_focus()


#Play animations whenever the turn changes
func change_sides(enemyturn):
	
	mainattacks = PartyStats.load_party_id(playerarray[currentturn]).load_attacks()
	tactics = PartyStats.load_party_id(playerarray[currentturn]).load_special_attacks()
	inventory = PartyStats.load_inventory()
	
	#Your turn
	if !enemyturn:
		
			
		for node in $TopUI/Health.get_children():
			node.set_turn([currentturn])
			
		#Choose which party member to target for when it's the enemy's turn again
		if gridref.get_players().size() > 1:
			for node in $TopUI/Health.get_children():
				node.set_turn([currentturn])
			
			target = randi() % gridref.get_players().size()
			
			while gridref.get_players()[target].dead:
				target = randi() % gridref.get_players().size()
		
			for child in $TopUI/Health.get_children():
				child.set_targeted(false)
		
			$TopUI/Health.get_child(target).set_targeted(true)
			
			for child in gridref.get_players():
				child.targeted = false
				if child.party_number == target:
					child.targeted = true
		
		#Disable the icons of dead players
		for player in gridref.get_players():
			player.not_thinking()
			
			
		#Disable the icon for the first party member if they are dead and move to the next
		if gridref.get_players()[currentturn].dead:
#			$Icons.get_child(currentturn).disable()
			advance()
		else:
			emit_signal("player_turn_changed", [currentturn])
			gridref.get_players()[currentturn].thinking()
			
		update_menu_color()
			
		#Wait for dialogue if there is any
		if BattleSystem.dialogue:
			await TextSystem.text_finished
			
		#Show and reset the ui
		await get_tree().create_timer(0.1).timeout
		animate_ui_appear()
		enemy_turn_ui_hide()
		maincommit = false
	
	#Their turn
	if enemyturn:
		#Reset and hide the ui
		if $AnimationPlayer.is_playing():
			await $AnimationPlayer.animation_finished
		$Actions.get_child(mainselect).set_selected(false)
		maincommit = false
		if $MoreInfo.visible:
			animate_ui_disappear_all()
		else:
			animate_ui_disappear()
		enemy_turn_ui_show()
		$Info.set_text("")
		await $AnimationPlayer.animation_finished


#Update the actions on the left hand side and make sure only one is selected
func update_actions():
	if !maincommit:
		#Change the color
		update_menu_color()

		#Set the bottom panel to show the description of the current selection
		$Info.set_text(maindesc[mainselect].to_upper())
		
		#Deselect the previous selection
		$Actions.get_child(mainselectprev).set_selected(false)
		
		for action in $Actions.get_children():
			#Select the current action
			if $Actions.get_child(mainselect).has_method("set_selected"):
				$Actions.get_child(mainselect).set_selected(true)
			
			#Disable the use of special attacks if the current player doesn't have any
#			if action.type == action.TYPE.SPECIAL:
#				if PartyStats.load_party_id(currentturn).special_attacks == []:
#					action.disable()
#				else: action.enable()
			
			#Disable the use of items if none are in the inventory
			if action.type == action.TYPE.ITEM:
				if PartyStats.inventory == []:
					action.disable()
				else: action.enable()


#Update the actions in the submenu
func update_more():
	var current_party = PartyStats.load_party_id(gridref.get_players()[currentturn].party_number)
	#Show inventory capacity
	if mainselect == 2:
		%InvCapacity/Have.text = str(PartyStats.inventory.size())
		%InvCapacity/Max.text = str(PartyStats.max_inventory)
		%InvCapacity.visible = true
	else:
		%InvCapacity.visible = false
	
	
	#Clear existing submenu options
	for child in %Options.get_children():
		child.queue_free()
	await get_tree().process_frame
	
	#Make new submenu options
	var attackid = 0
	for attack in useattacks:
		#Check if the options can be stacked
		var stacked = false
		if attack is Item:
			for child in %Options.get_children():
				if child.get_attack_name() == attack.attackname.to_upper():
					child.add_one()
					stacked = true
					break
		if stacked:
			attackid += 1
			continue
		
		#If not, add a new entry
		var new_attack = submenuitem.instantiate()
		new_attack.set_text(attack.attackname.to_upper())
		new_attack.cost = attack.cost
		new_attack.set_color(current_party.select_color)
		if !can_use_attack(attack):
			new_attack.grey_out()
		if !(attack is Item):
			var use_cooldown = bool(attack.ap_penalty)
			new_attack.set_cooldown(use_cooldown,gridref.get_players()[currentturn].get_cooldown(attack))
		else:
			new_attack.show_stack()
			
		new_attack.connect("new_selection", update_submenu_ui)
		
		if attack.requires1:
			new_attack.show_icon(1)
		if attack.requires2:
			new_attack.show_icon(2)
			
		if attackid == 0:
			new_attack.grab_focus()
			
		new_attack.attackid = attackid
		attackid += 1
		
		%Options.add_child(new_attack)

#Make sure the main menu is properly displayed after animating
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Appear":
		mainselectprev = mainselect
		update_actions()


#Update the bottom label when selecting an enemy, grid square, or player
func update_enemy_name(new_name):
	if waiting:
		$Info.set_text("USE [b]" + str(useattacks[subselect].attackname).to_upper() + "[/b] ON [b]" + new_name.to_upper() + "[/b]")


#Get user input
func _input(_event):
	#Helper signal for info screen
	if Input.is_action_just_pressed("ui_accept"): emit_signal("ui_accept_pressed")
	
	if !BattleSystem.enemyturn and !$AnimationPlayer.is_playing() and !BattleSystem.dialogue and !waiting and BattleSystem.battling and !System.battle_cutscene:
		if Input.is_action_just_pressed("ui_up"):
			if !maincommit:
				mainselectprev = mainselect
				mainselect = more.clamp_wrap(mainselect-1, 0, $Actions.get_child_count()-1)
				update_actions()
				$Selection.play()
			
		if Input.is_action_just_pressed("ui_down"):
			if !maincommit:
				mainselectprev = mainselect
				mainselect = more.clamp_wrap(mainselect+1, 0, $Actions.get_child_count()-1)
				update_actions()
				$Selection.play()
			
		if Input.is_action_just_pressed("more_info"):
			if maincommit:
				waiting = true
				var focus = get_viewport().gui_get_focus_owner()
				focus.release_focus()
				$AttackInfoAnim.play("show")
				$MoreInfo/BackPrompt.visible = false
				$MoreInfo/MorePrompt.visible = false
				await get_tree().create_timer(0.1).timeout
				$AttackInfo.show_info(useattacks[subselect])
				await $AttackInfo.closed
				$AttackInfoAnim.play("hide")
				await get_tree().create_timer(0.25).timeout
				$MoreInfo/BackPrompt.visible = true
				$MoreInfo/MorePrompt.visible = true
				waiting = false
				focus.grab_focus()
				
			
		if Input.is_action_just_pressed("ui_cancel"):
			if maincommit:
				$AnimationPlayer.play("ShowLess")
				for child in %Options.get_children():
					child.queue_free()
				subselect = 0
				maincommit = false
				$Actions.get_child(mainselect).set_committed(false)
				$Info.set_text(maindesc[mainselect].to_upper())
				SoundSystem.play_sound("res://Sounds/UI/UI_Cancel.wav","ui_battle",-6)
			
		if Input.is_action_just_pressed("ui_accept"):
			#Act on main menu
			if !maincommit:
				#Advance if the selection is "refrain"
				if mainselect == 3:
					gridref.get_players()[currentturn].tick_cooldown()
					SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
					advance()
				else:
					if !$Actions.get_child(mainselect).disabled:
						#Set the currently selected menu item visually
						$Actions.get_child(mainselect).set_committed()
						
						#Enter and show submenu
						maincommit = true
						$AnimationPlayer.play("ShowMore")
						update_more()
					else:
						SoundSystem.play_sound("res://Sounds/UI/UI_Cancel.wav","ui_battle",-6)
			
			#Act on submenu
			else:
				#Standard Attacks and Special Attacks
				if can_use_attack(useattacks[subselect]):
					SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
					$AnimationPlayer.play("ShowLess")
					#Special case if the current attack is Check
					if useattacks[subselect].attackname == "Check":
						var enemy = await get_object("enemy")
						if enemy != null:
							await check(enemy)
							if enemy != null:
								enemy.show_healthbar(false)
							$AnimationPlayer.play_backwards("ShowEnemyInfo")
							await $AnimationPlayer.animation_finished
							waiting = false
							advance()
						else:
							$AnimationPlayer.play("ShowMore")
					
					#Every other attack
					else:
						#Attack
						if useattacks[subselect] is Attack:
							var attack_enemy = []
							#Select an enemy
							if useattacks[subselect].get_affects() == "enemy":
								attack_enemy = [await get_object("enemy")]
							#Select all enemies
							elif useattacks[subselect].get_affects() == "all_enemies":
								attack_enemy = gridref.get_enemies()
							#Select a grid square
							elif useattacks[subselect].get_affects() == "grid":
								attack_enemy = [await get_object("grid")]
							else:
								attack_enemy = ["None lmao"]
								
							
							#Attack if the selection is valid
							if attack_enemy != [] and attack_enemy != [null]:
								waiting = true
								var node = Node.new()
								node.set_script(useattacks[subselect].get_script())
								add_child(node)
								node.execute(useattacks[subselect],attack_enemy,gridref.get_players()[currentturn])
								await node.attack_finished
								waiting = false
								BattleSystem.change_ap(-useattacks[subselect].cost - gridref.get_players()[currentturn].get_cooldown(useattacks[subselect]))
								advance()
							else:
								$AnimationPlayer.play("ShowMore")
							
						#Item
						if useattacks[subselect] is Item:
							waiting = true
							var node = Node.new()
							node.set_script(useattacks[subselect].get_script())
							add_child(node)
							node.execute(useattacks[subselect],gridref.get_players()[currentturn],gridref.get_players()[currentturn])
							await node.attack_finished
							waiting = false
							PartyStats.remove_inventory(useattacks[subselect])
							advance()
			
				elif can_use_attack(useattacks[subselect]) == false:
					SoundSystem.play_sound("res://Sounds/UI/UI_Cancel.wav","ui_battle",-6)
					if BattleSystem.currentap < useattacks[subselect].cost:
						$CostAnim.play("shake")
						

func get_object(type = "enemy"):
	var to_return = null
	
	waiting = true
	gridref.select_type(type)
	to_return = await gridref.object_selected
	waiting = false
	return to_return


func advance():
	if !System.battle_cutscene:
		if useattacks.size() > 0:
			if !(useattacks[subselect] is Item) and mainselect != 3:
				set_attack_cooldown(useattacks[subselect])
		
		gridref.get_players()[currentturn].reset_anim()
		gridref.get_players()[currentturn].not_thinking()
		
		currentturn += 1
		
		if currentturn < PartyStats.party.size():
			mainattacks = PartyStats.load_party_id(currentturn).load_attacks()
			tactics = PartyStats.load_party_id(currentturn).load_special_attacks()
			inventory = PartyStats.load_inventory()
		
		$Actions.get_child(mainselect).set_committed(false)
		$Actions.get_child(mainselect).set_selected(false)
		subselect = 0
		mainselect = 0
		maincommit = false
		
		
		if currentturn < turns and currentturn > 0:
			emit_signal("player_turn_changed", [currentturn])
		
			for node in $TopUI/Health.get_children():
				node.set_turn([currentturn])

			gridref.get_players()[currentturn].thinking()
			
			if gridref.get_players()[currentturn].dead:
				advance()
				
			if currentturn in BattleSystem.skipqueue:
				BattleSystem.skipqueue.erase(currentturn)
				get_tree().call_group("health_node","set_skip",BattleSystem.skipqueue)
				advance()
			update_actions()
		else:
			currentturn = 0
			BattleSystem.turn_end(true, true)
		
		
		
func set_attack_cooldown(attack):
	if currentturn < PartyStats.party.size():
		gridref.get_players()[currentturn].set_attack_cooldown(attack)


#Check if an attack can actually be used
func can_use_attack(attack):
	var canuse = false
	
	if !(attack is Item):
		if BattleSystem.currentap >= attack.cost+gridref.get_players()[currentturn].get_cooldown(attack):
			if BattleSystem.current_scenario.state == 2:
				if attack is Attack and attack.get_affects() == "grid":
					return false
			canuse = true
		
		if attack.requires1:
			if gridref.get_players().size() >= 2:
				canuse = !gridref.get_players()[1].dead
			else:
				return false
				
		if attack.requires2:
			if gridref.get_players().size() >= 3:
				canuse = !gridref.get_players()[2].dead
			else:
				return false
	else:
		return true
		
	return canuse


#Get info about the enemy and show it in the Analysis box
func check(enemy):
	if enemy.has_method("on_check"):
		enemy.on_check()
	
	%EnemyName.text = enemy.enemyname
	%EnemyHP.text = str(enemy.hp) + "/" + str(enemy.get_max_health())
	%EnemyAT.text = str(enemy.damage)
	%EnemyDF.text = str(round(enemy.defense*100))
	$Analysis/Margin/VBox/Description.text = enemy.enemydesc
	$AnimationPlayer.play("ShowEnemyInfo")
	waiting = true
	await get_tree().create_timer(0.45).timeout
	await ui_accept_pressed
	BattleSystem.change_ap(-useattacks[subselect].cost)


func battle_over():
	$AnimationPlayer.play("DisappearAll",-1, 1.65)
	visible = false
	
	
	
func update_menu_color():
	var tempparty = PartyStats.load_party_id(gridref.get_players()[currentturn].party_number)
	var newselectcol = tempparty.select_color
	var newunselectcol = tempparty.unselect_color
	for action in $Actions.get_children():
			action.set_colors(newselectcol, newunselectcol)
	$MoreInfo.self_modulate = newselectcol
	$Info.self_modulate = newunselectcol
	$Analysis.self_modulate = newunselectcol
	$AttackInfo.set_color(newunselectcol)
	
	
	
	
func swap_control(node1 : Control, node2 : Control, time = 0.2):
	var tween = create_tween()
	
	var node1pos = node1.position
	var node2pos = node2.position
	tween.tween_property(node1, "position", node2pos, time)
	tween.parallel().tween_property(node2,"position",node1pos,time)


#Functions for showing and hiding the ui
func animate_ui_appear():
	$AnimationPlayer.play("Appear", -1, 2)
	show_cards()
	
func animate_ui_disappear():
	$AnimationPlayer.play("Disappear", -1, 1.65)
	await hide_cards()
	
func animate_ui_disappear_all():
	$AnimationPlayer.play("DisappearAll", -1, 1.65)
	await hide_cards()
	
func enemy_turn_ui_show():
	if !enemy_ui_shown:
		enemy_ui_shown = true
		$EnemyUIPlayer.play("DodgeAppear")
	
	
func enemy_turn_ui_hide():
	if enemy_ui_shown:
		enemy_ui_shown = false
		$EnemyUIPlayer.play("DodgeDisappear")


func update_submenu_ui(attackid):
	subselect = attackid
	$Info.set_text(useattacks[attackid].desc.to_upper())
	$Info.set_cost(useattacks[attackid].cost+gridref.get_players()[currentturn].get_cooldown(useattacks[attackid]))
	BattleSystem.preview_ap_change(useattacks[attackid].cost+gridref.get_players()[currentturn].get_cooldown(useattacks[attackid]))
	$Selection.play()

func show_cards():
	for child in $Actions.get_children():
		child.set_panel_visible(false)
	
	var childcount = $Actions.get_child_count()
	for child in childcount:
		$CardSound.play()
		$CardSound.pitch_scale += 0.1
		$Actions.get_child(childcount-child-1).play_intro_anim()
		await get_tree().create_timer(0.025).timeout
		$Actions.get_child(childcount-child-1).set_panel_visible(true)
		await $Actions.get_child(childcount-child-1).intro_anim_done
		await get_tree().create_timer(0.025).timeout
	
func hide_cards():
	for child in $Actions.get_children():
		$CardSound.play()
		$CardSound.pitch_scale -= 0.1
		child.play_intro_anim(true)
		await child.intro_anim_done
		child.set_panel_visible(false)
		await get_tree().create_timer(0.05).timeout
		
		
func lock_ui():
	System.battle_cutscene = true
	animate_ui_disappear_all()
	for player in gridref.get_players():
			player.not_thinking()
	get_tree().call_group("party","all_done")
	$Selection.volume_db = -80
