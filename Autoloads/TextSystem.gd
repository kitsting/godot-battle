extends CanvasLayer


var textbox_layer = 8


signal text_finished
signal text_done_rendering
signal choice_selected(choice)


var render_background = true

var fontdir = ""
var sounddir = ""
var portraitdir = ""

var default_font = "res://Fonts/DialogueFont.tres"
var default_sound = "res://Sounds/TextSounds/Default.wav"

func show_dialogue(title: String, resource: String) -> void:
	System.cutscene = true
	var dialogue = await DialogueManager.get_next_dialogue_line(load(resource), title)
	if dialogue != null:
		var command = dialogue.text.split(" ")
		#Wait
		if command[0] == "wait":
			await get_tree().create_timer(str_to_var(command[1])).timeout
			show_dialogue(dialogue.next_id, resource)
			
		#End dialogue
		elif dialogue.text == "end":
			System.cutscene = false
			emit_signal("text_finished")
			
		#Keyboard Input
		elif command[0] == "input":
			if command[1] == "name":
				var name_dialogue = load("res://Objects/UI/NameInput.tscn").instantiate()
				add_child(name_dialogue)
				await name_dialogue.done_with_name
			show_dialogue(dialogue.next_id, resource)
			
		#Add a party member
		elif command[0] == "addparty":
			if !PartyStats.party.has(command[1]):
				PartyStats.party.append(command[1])
				get_tree().call_group(command[1],"set_to_follow",get_tree().get_current_scene().get_player().get_last_in_chain())
			show_dialogue(dialogue.next_id, resource)
					
		elif command[0] == "removeparty":
			if PartyStats.party.has(command[1]):
				PartyStats.party.erase(command[1])
				get_tree().call_group(command[1],"stop_following")
			show_dialogue(dialogue.next_id, resource)
			
		elif command[0] == "callgroup":
			get_tree().call_group(command[1],command[2])
			show_dialogue(dialogue.next_id, resource)
			
		
		
		#Camera controls
		elif command[0] == "movecam":
			var goto = Vector2(str_to_var(command[1]), str_to_var(command[2]))
			if command.size() > 4:
				get_tree().call_group("camera", "new_position", goto, str_to_var(command[3]), bool(str_to_var(command[4])))
			else:
				get_tree().call_group("camera", "new_position", goto, str_to_var(command[3]))
			await get_tree().create_timer(str_to_var(command[3])).timeout
			show_dialogue(dialogue.next_id, resource)
			
		elif command[0] == "resetcam":
			get_tree().call_group("camera", "reset_pos", str_to_var(command[1]))
			await get_tree().create_timer(str_to_var(command[1])).timeout
			show_dialogue(dialogue.next_id, resource)
		
		
		#Fight a battle
		elif command[0] == "dobattle":
			BattleSystem.do_battle(load("res://Resources/Scenarios/"+command[1]+".tres"))
			
			
		#Call group (string argument)
		elif command[0] == "call":
			get_tree().call_group(command[1], command[2], command[3])


		#Spawn a follower
		elif command[0] == "spawnfollower":
			var newfollower = load("res://Objects/Overworld/Follower.tscn").instantiate()
			newfollower.set_member_name(command[3])
			newfollower.position = Vector2(str_to_var(command[1]), str_to_var(command[2]))
			get_tree().call_group("Objects","add_child",newfollower)
			show_dialogue(dialogue.next_id, resource)
		
		elif command[0] == "savegame":
			System.save_game()
			show_dialogue(dialogue.next_id, resource)
		
		#Show dialogue
		else:
			#Instance a new dialogue box
			var dialogue_box = preload("res://Objects/UI/Text/TextBox.tscn").instantiate()
			print(dialogue)
			dialogue_box.box_dialogue = dialogue
			add_child(dialogue_box)
			
			#Set text color and portrait based on character name
			if dialogue.character != null:
				var charinfo = dialogue.character.split(" ")
				if Constants.voices.has(charinfo[0]):
					#Color
					dialogue_box.set_text_color(Constants.voices[charinfo[0]]["Color"])
					
					#Portrait
					if Constants.voices[charinfo[0]].has("Portraits"):
						if Constants.voices[charinfo[0]]["Portraits"].has(charinfo[1]):
							dialogue_box.set_portrait(Constants.voices[charinfo[0]]["Portraits"][charinfo[1]])

			show_dialogue(await dialogue_box.text_finished, resource)
	else:
		System.cutscene = false
		get_tree().call_group("camera", "reset_pos", 0.2)
		emit_signal("text_finished")


#Return a new standard textbox
func give_new_textbox(textarray):
	var new_box = load("res://Objects/UI/Text/TextBox.tscn").instance()
	#new_box.initialize(box_dimensions)
	new_box.set_graphics("box_border", 3, "*", "choice_graphic")
	new_box.set_text(textarray, "textspeed", "starter")
	new_box.set_background_visibility(render_background)
	new_box.ignore_margins()
	return new_box


#Delete all current textboxes
func purge_boxes():
	for box in get_children():
		box.queue_free()


#Set whether or not to render the background of the text
func set_box_background_render(render = true):
	render_background = render

func set_sound_directory(dir = ""):
	if !dir.ends_with("/"):
		dir = dir + "/"
	sounddir = dir

func set_portrait_directory(dir = ""):
	if !dir.ends_with("/"):
		dir = dir + "/"
	portraitdir = dir
