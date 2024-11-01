extends Node

var cutscene = false
var battle_cutscene = false

var custom_room_pos = Vector2(0,0)

var demomode = false
var deletenpcs = true
var disablemusic = false
var skipcutscenes = false
var skip_battles = false

var interacting_object = null

var current_slot = "noslot"

const SAVE_ENCRYPTION_KEY = "I_Preordered_Vanadius"
var registry_backup = {}
var registry = {
	#Save file data
	"last_save_date" : "Jan 1, 1970",
	"last_room_name" : "???",
	"last_area" : 1,
	"playername" : "You",
	"current_chapter" : 1,
	#Keep track of finished battles
	"finished_encounters" : [],
	"finished_challenges" : [],
	#Money
	"money" : 0,
	#Room Info
	"current_room" : "",
	"room_entry_dir" : -1,
	#Inventory + Badges + Party
	"current_inventory" : [],
	"current_badges_equipped" : [],
	"current_badge_inventory" : [],
	"current_party" : [],
	#Keep track of overworld stuff
	"seen_cutscenes" : [],
	"solved_puzzles" : [],
	"found_secrets" : [],
	#Learned Moves
	"learned_attacks_you" : [],
	"learned_special_you" : [],
	"learned_attacks_vardell" : [],
	"learned_special_vardell" : [],
	"learned_attacks_shylen" : [],
	"learned_special_shylen" : [],
	
}

var options = {
	#Audio
	"music_volume" : 1.0,
	"sound_volume" : 0.85,
	#Accessibility
	"screenshake" : 1.0,
	"background_mode" : 1.0,
	#Graphics
	"fullscreen" : false,
	"keep_aspect" : true,
	"buttons" : 0.0,
}



func _ready():
	registry_backup = registry.duplicate(true)
	DisplayServer.window_set_min_size(Vector2(480,270))
	randomize()
	load_options()


func _input(_event):
	if Input.is_action_just_pressed("fullscreen"):
		option_set("fullscreen", !options["fullscreen"])
		
	if Input.is_action_just_pressed("collision"):
		get_tree().set_debug_collisions_hint(!get_tree().is_debugging_collisions_hint())


func registry_lookup(reg_name):
	if registry.has(reg_name):
		return registry[reg_name]
	else:
		return null


func registry_set(reg_name, value):
	registry[reg_name] = value
	
func option_set(opt_name, value):
	options[opt_name] = value
	save_options()


func registry_append(reg_name, value):
	if registry[reg_name] is Array:
		if !value in registry[reg_name]:
			registry[reg_name].append(value)
			
			
func save_options():
	var options_file = FileAccess.open("user://options.json", FileAccess.WRITE)
	options_file.store_line(JSON.stringify(options))
	print("Options Saved")
	update_options()
	
func save_game(slot=current_slot):
	var time = Time.get_date_string_from_system()
	registry_set("last_save_date", time)
#	registry_set("current_inventory", PartyStats.inventory)
	registry_set("current_badges_equipped", PartyStats.equipped_badges)
	registry_set("current_badge_inventory", PartyStats.has_badges)
	registry_set("current_party", PartyStats.party)
	var save_file = FileAccess.open_encrypted_with_pass("user://save" + slot + ".sav", FileAccess.WRITE, SAVE_ENCRYPTION_KEY)
	save_file.store_var(registry, true)
	print("Game Saved")


func load_game(slot="1", return_result = false):
	if !return_result:
		current_slot = slot
	
	if FileAccess.file_exists("user://save" + slot + ".sav"):
		var file = FileAccess.open_encrypted_with_pass("user://save" + slot + ".sav", FileAccess.READ, SAVE_ENCRYPTION_KEY)
		var text = file.get_var(true)
		print("Get var success")
		if return_result:
			#Return the loaded file for use on the file selection screen
			return text
		else:
			#Load data back into the registry
			for data in text:
				if registry.has(data):
					registry[data] = text[data]
					
			PartyStats.party = registry_lookup("current_party")
			PartyStats.has_badges = registry_lookup("current_badge_inventory")
			PartyStats.equipped_badges = registry_lookup("current_badges_equipped")
			
			#Load the saved room
			print("Game Loaded")
			var new_transition = load("res://Objects/Battle/ToBlack.tscn").instantiate()
			new_transition.set_speed(2.5)
			get_tree().get_root().add_child(new_transition)
			await new_transition.midpoint
			get_tree().change_scene_to_file(registry["current_room"])
	else:
		if return_result:
			print("Specified save file doesn't exist")
			return null
		else:
			#Start a new game
			registry = registry_backup.duplicate(true)
			var new_transition = load("res://Objects/Battle/ToBlack.tscn").instantiate()
			new_transition.set_speed(2.5)
			get_tree().get_root().add_child(new_transition)
			await new_transition.midpoint
			System.registry_set("current_room", "res://Rooms/TestRooms/BattleHall.tscn")
			get_tree().change_scene_to_file("res://Rooms/TestRooms/BattleHall.tscn")


func load_options():
	if FileAccess.file_exists("user://options.json"):
		var file = FileAccess.open("user://options.json", FileAccess.READ)
		var text = JSON.parse_string(file.get_as_text())
		for option in text:
			if options.has(option):
				print("has "+option+" | "+str(text[option]))
				options[option] = text[option]
		print("Options Loaded")
	else:
		print("Options file doesn't exist")
	update_options()
		
		
func update_options():
	#Fullscreen
	if options["fullscreen"]:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)

	#Keep Aspect
	if options["keep_aspect"] == true:
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	else:
		get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
		
	#Volume
	if options["sound_volume"] == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), false)
	if options["music_volume"] == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), false)
		
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), ((options["sound_volume"]-1)*18))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), ((options["music_volume"]-1)*18))


func collect_money(amount):
	registry_set("money",registry_lookup("money")+amount)
	get_tree().call_group("coincount","collect")
	
	
func get_select_color():
	if PartyStats.party.size() >= 1:
		return PartyStats.load_party_id(0).select_color
	else:
		return Constants.select_color


func get_unselect_color():
	if PartyStats.party.size() >= 1:
		return PartyStats.load_party_id(0).unselect_color
	else:
		return Constants.unselect_color
