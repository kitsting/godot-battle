extends Node2D

@export_file("*.ogg") var music = "res://Sounds/Music/NoMusic.ogg"
@export var room_name = "???"
@export var area_name = Constants.AREAS.MINES
@export var never_show_area = false
@export var show_room_name_instead = false


var pause_cooldown = false
var room_size = Vector2(0,0)
var spawn_offset = Vector2(0,0)

var show_area = false

func _ready():
	#See if we should show the room name
	if !show_room_name_instead:
		if System.registry_lookup("last_area") != area_name:
			show_area = true
	else:
		if System.registry_lookup("last_room_name") != room_name:
			show_area = true
	
	#Save the game
	System.registry_set("last_room_name", room_name)
	System.registry_set("last_area", area_name)
	System.save_game()
	
	#Interface with autoloads
	SoundSystem.set_overworld_music(music)
	BattleSystem.connect("back_in_overworld",after_battle)
	$TileMap.visible = false
	
	#Set clear color
	$BGLayer/Background.visible = true
	
	
	#Get the size ofthe current room and lock the camera
	room_size = $TileMap.get_used_rect()
	
	if has_node("Camera"):
		$Camera.limit_bottom = (room_size.end.y*16) - 1
		$Camera.limit_right = (room_size.end.x*16)
		$Camera.limit_top = (room_size.position.y*16) + 1
		$Camera.limit_left = room_size.position.x*16
		
		
	#Set Darkness
	if $CanvasModulate.color == Color.WHITE:
		$CanvasModulate.color.v = Constants.areas[area_name][2]

	await get_tree().process_frame

	#Place the player in the room
	if has_node("Objects/OverworldPlayer"):
		#Place the player in the correct position when changing rooms
		var trans_dir = 0
		var transitions = get_tree().get_nodes_in_group("transition")
		for transition in transitions:
			#Ignore transitions if a custom position is set
			if System.custom_room_pos != Vector2(0,0):
				if abs(transition.position.x-System.custom_room_pos.x) > 30 or abs(transition.position.y-System.custom_room_pos.y) > 30:
					continue

			#Automatically find a room transition based on the direction the player entered from
			var roomdir = System.registry_lookup("room_entry_dir")
			if (transition.dir == 1 and roomdir == 0) or (transition.dir == 0 and roomdir == 1) or (transition.dir == 2 and roomdir == 3) or (transition.dir == 3 and roomdir == 2):
				if trans_dir == 0:
					trans_dir = transition.get_direction()
				$Objects/OverworldPlayer.global_position = transition.get_global_position()
				spawn_offset = transition.get_player_offset()
				$Objects/OverworldPlayer.position += spawn_offset
				$Objects/OverworldPlayer.set_dir(trans_dir)
				if transition.invisible:
					spawn_offset /= 30
				if spawn_offset.x != 0:
					spawn_offset.y = 1
	
		#Spawn other party members behind the player
		var following = $Objects/OverworldPlayer
		for member in PartyStats.party:
			if member == PartyStats.party[0]:
				continue
			
			var new_follower = load("res://Objects/Overworld/Follower.tscn").instantiate()
			new_follower.set_to_follow(following)
			new_follower.set_dir(trans_dir)
			following.next = new_follower
			new_follower.set_member_name(member)
			new_follower.position = following.position - (spawn_offset * (2.0/3))
			following = new_follower
			$Objects.add_child(new_follower)
			
			
	#Show the area name
	if show_area and !never_show_area:
		if !show_room_name_instead:
			GlobalUi.show_area_name(Constants.areas[area_name][0])
		else:
			GlobalUi.show_area_name(room_name)


#Pause and unpause
func _input(_event):
	if Input.is_action_just_pressed("pause") and !pause_cooldown:
		if !BattleSystem.battling and !System.cutscene:
			System.cutscene = true
			var new_pause = load("res://Objects/UI/PauseMenu.tscn").instantiate()
			get_tree().paused = true
			add_child(new_pause)
			pause_cooldown = true
			await new_pause.done
			get_tree().paused = false
			System.cutscene = false
			await get_tree().create_timer(0.2).timeout
			pause_cooldown = false


#Get a reference to the player
func get_player() -> Node:
	if has_node("Objects/OverworldPlayer"):
		return get_node("Objects/OverworldPlayer")
	else:
		return null
		

#Return camera control after a battle
func after_battle():
	$Camera.make_current()
	
	
	
func get_material_at_tile(tile_position : Vector2i) -> String:
	if has_node("WorldTiles"):
		if $WorldTiles.tile_set.get_custom_data_layers_count() != 0:
			var tile_data = $WorldTiles.get_cell_tile_data(0, tile_position)
			if tile_data != null:
				return tile_data.get_custom_data("Material")
	return ""
