extends Node


#Integral Variables (not calculus)
var battling = false
var enemyturn = true
var current_scenario : BattleScenario = null
var challenge_battle = false

var num_party = 1 #Party members present at the start of battle
var num_party_array = []
var party_in_battle = 0 #Party members currently alive
var battles_cleared = 0

#Energy/AP Variables
var maxap = 100
var currentap = maxap

#Dialogue Variables
var dialogue_queue = []
var skipqueue = []
var dialogue = false
var dialogue_queued = false

#Preloads
var transition = preload("res://Objects/Battle/BattleTransition2.tscn")
var deathtransition = preload("res://Objects/Battle/ToBlack.tscn")

#Signals
signal side_change(enemyturn)
signal ap_changed(newap)
signal ap_preview(theoreticalap)
signal end_ap_preview
signal battle_finished
signal back_in_overworld
signal battle_won(victory)


#Reset the energy meter to it's default amount. Called at the start of a battle
func reset():
	currentap = maxap * (1.0/4)
	emit_signal("ap_changed", currentap)
	emit_signal("side_change", enemyturn)


#Change the amount of energy in the energy meter
func change_ap(amount):
	currentap += amount
	
	maxap = 100 + (20 * int(PartyStats.has_badge("APMaxUp")))
	currentap = clampi(currentap, 0, maxap)
	
	emit_signal("ap_changed", currentap)
	

#End the turn and move on to the next
func turn_end(custom = false, to = true):
	#Swap between enemy's turn and player's turn
	if !custom:
		enemyturn = !enemyturn
	else:
		enemyturn = to
	
	#Alert other nodes to the side change
	if !System.cutscene:
		emit_signal("side_change", enemyturn)
	
	#Regenerate energy at the start of every player turn and reset defense
	if !enemyturn:
		change_ap(round(15 + (7.5*(party_in_battle-1)) + (7.5*int(PartyStats.has_badge("APRegenUp"))) + (5*PartyStats.focus_boost)))
		#change_ap(500)
		PartyStats.boost_defense(0, true)
		PartyStats.boost_focus(0, true)

	#Show dialogue if there's any queued
	if dialogue_queue != []:
		System.reset_text_system()
		dialogue = true
		await get_tree().create_timer(1.5).timeout
		TextSystem.new_textbox(dialogue_queue)
		await TextSystem.text_finished
		dialogue = false
		dialogue_queued = false
		dialogue_queue = []
	

#Add dialogue to the queue to be shown whenever the side changes
func queue_dialogue(dialogue_array):
	dialogue_queued = true
	dialogue_queue.append_array(dialogue_array)

	
#Load a battle
func do_battle(scenario = load("res://Resources/Scenarios/Test1.tres"), challenge = false):
	if !battling:
		#Stop the overworld music and initialize variables
		SoundSystem.pause_overworld_music(0.1)
		enemyturn = true
		current_scenario = scenario
		challenge_battle = challenge
		num_party = scenario.get_num_party()
		num_party_array = [scenario.has_in_grid("0"),scenario.has_in_grid("1"),scenario.has_in_grid("2")]
		
		#Copy inventory
		PartyStats.copy_inventory(true)
		
		#Start the screen transition
		battling = true
		SoundSystem.play_sound("res://Sounds/BattleStart.wav", "ui_misc", -8)
		pause_all_nodes()
		var new_transition = transition.instantiate()
		new_transition.set_members(num_party_array)
		get_tree().get_root().add_child(new_transition)
		
		#Load the scene when the transition reaches the halfway point
		await new_transition.midpoint
		var battle = load("res://Objects/Battle/BattleScene.tscn").instantiate()
		battle.current_scenario = scenario
		get_tree().get_root().add_child(battle)
		
		#Wait for the transition to finish and show the battle description
		await new_transition.done
		TextSystem.show_dialogue(scenario.description,"res://Dialogue/BattleDescriptions.dialogue")
		
		#Wait for the text to be dismissed, start the music, and allow for input
		await TextSystem.text_finished
		System.cutscene = false
		SoundSystem.play_music(scenario.get_music(), -10)
		turn_end(true, false)


#End a battle
func battle_complete(victory = true):
	if battling:
		#Stop the music and prevent input
		SoundSystem.stop_song()
		System.cutscene = true
		
		#Alert other nodes that the battle is over
		emit_signal("battle_finished")
		
		#Restock inventory
		PartyStats.copy_inventory(false)
		
		if victory or challenge_battle: #The battle has been won
			#Mark the battle as completed
			System.registry_append("finished_encounters",current_scenario.readable_name)
			
			#Collect coins and show victory text
			battles_cleared += 1
			if victory:
				if current_scenario.coins != 0:
					System.collect_money(current_scenario.coins)
				TextSystem.show_dialogue("BattleWonDefault","res://Dialogue/BattleOther.dialogue")
				await TextSystem.text_finished
			else:
				SoundSystem.play_sound("res://Sounds/GameOver.wav","ui_battle")
				await get_tree().create_timer(1).timeout
			
			#Transition back to the overworld
			var new_transition = transition.instantiate()
			new_transition.set_members(num_party_array)
			get_tree().get_root().add_child(new_transition)
			await new_transition.midpoint
			SoundSystem.resume_overworld_music()
			emit_signal("back_in_overworld")
			
			if challenge_battle:
				emit_signal("battle_won", victory)
			
			if get_tree().get_root().has_node("BattleScene"):
				get_tree().get_root().get_node("BattleScene").queue_free()
			await new_transition.done
			await get_tree().create_timer(0.3).timeout
			
		else: #The battle has been lost
			#Go to the game over screen
			SoundSystem.play_sound("res://Sounds/GameOver.wav","ui_battle")
			await get_tree().create_timer(1).timeout
			var new_transition = deathtransition.instantiate()
			get_tree().get_root().add_child(new_transition)
			await new_transition.midpoint
			#Delete the battle scene if it hasn't already been automatically unloaded
			if get_tree().get_root().has_node("BattleScene"):
				get_tree().get_root().get_node("BattleScene").queue_free()
			get_tree().change_scene_to_file("res://Objects/UI/GameOver.tscn")
		
		#Reset variables
		battling = false
		System.cutscene = false
		System.battle_cutscene = false
		pause_all_nodes(true)
		current_scenario = null
		emit_signal("battle_finished")



#Pause all nodes that are part of the overworld
func pause_all_nodes(unpause = false):
	for node in get_tree().get_current_scene().get_children():
		if node.name != "System" and node.name != "InputHelper":
			node.set_process(unpause)
			node.set_physics_process(unpause)
			node.set_process_input(unpause)


#Mark an array of players to have their turn skipped
#For use when an attack requires multiple party members
func add_to_skip_queue(array):
	skipqueue.append_array(array)
	get_tree().call_group("health_node","set_skip",skipqueue)


#Show the energy loss preview on the energy bar
func preview_ap_change(ap_change):
	emit_signal("ap_preview",currentap-ap_change)


#Hide the energy loss preview on the energy bar
func end_preview():
	emit_signal("end_ap_preview")
	
	
func enter_shop(shopscene : PackedScene):
	#Instantiate
	SoundSystem.pause_overworld_music(0.1)
	battling = true
	pause_all_nodes()
	
	#Make a new transition
	var new_transition = deathtransition.instantiate()
	get_tree().get_root().add_child(new_transition)
	
	#Make the shop when the transition reaches the halfway point
	await new_transition.midpoint
	var shop = shopscene.instantiate()
	get_tree().get_root().add_child(shop)
	
	#Start shop music after text
	await TextSystem.text_finished
	SoundSystem.play_music("res://Sounds/Music/shop.mp3", -15)
	
	#Close the shop when the player is done
	await shop.done_shopping
	var return_transition = deathtransition.instantiate()
	get_tree().get_root().add_child(return_transition)
	await return_transition.midpoint
	SoundSystem.stop_song()
	SoundSystem.resume_overworld_music()
	emit_signal("back_in_overworld")
	if get_tree().get_root().has_node("Shop"):
		get_tree().get_root().get_node("Shop").queue_free()
	await return_transition.done
	await get_tree().create_timer(0.3).timeout
	
	#Reset variables
	battling = false
	System.cutscene = false
	pause_all_nodes(true)
	emit_signal("battle_finished")
