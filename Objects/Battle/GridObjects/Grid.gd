extends Node2D

#Selection mode
enum SELECT_MODE {
	NONE,
	ENEMY,
	PARTY,
	GRID,
}
var selectionmode = SELECT_MODE.NONE

#Constants
const gridpiecesize = Vector2(35,23)
const player_scene = preload("res://Objects/Battle/Player.tscn")
const obj_ice = preload("res://Objects/Battle/GridObjects/Ice.tscn")
const obj_web = preload("res://Objects/Battle/GridObjects/Web.tscn")
const obj_lava = preload("res://Objects/Battle/GridObjects/Lava.tscn")
const obj_conveyor = preload("res://Objects/Battle/GridObjects/Conveyor.tscn")

#ENEMY ALIGNMENT
#  5
#1   3
#  0
#2   4
#  6
const up_priorities = [
	[5, 1, 3], #From 0
	[5], #From 1
	[1, 0], #From 2
	[5], #From 3
	[3, 0], #From 4
	[], #From 5
	[0, 2, 4, 1, 3, 5] #From 6
]
const down_priorities = [
	[6, 2, 4], #From 0
	[2, 0, 6, 4], #From 1
	[6], #From 2
	[4, 0, 6, 2], #From 3
	[6], #From 4
	[0, 1, 3, 2, 4, 6], #From 5
	[], #From 6
]
const left_priorities = [
	[1, 2], #From 0
	[], #From 1
	[], #From 2
	[0, 5, 1, 2], #From 3
	[0, 6, 2, 1], #From 4
	[1, 2], #From 5
	[2, 1], #From 6
]
const right_priorities = [
	[3, 4], #From 0
	[0, 5, 3, 4], #From 1
	[0, 6, 4, 3], #From 2
	[], #From 3
	[], #From 4
	[3, 4], #From 5
	[4, 3], #From 6
]


#General variables
var enemy_slots = [false, false, false, false, false, false, false]
var enemyselection = 0
var gridselection = Vector2i(0,0)
var endedbattle = false
var enemiesdone = 0
var skipanim = true
var in_pattern = 0

#Count the iterations of get_random_grid() to prevent an infinite loop
var get_empty_iterations = 0

#Signals
signal enemy_selection_name(enemy_name)
signal object_selected(object)


#Setup signals to react when the turn ends
func _ready():
	position = position - Vector2(0,32)
	await TextSystem.text_finished
	BattleSystem.connect("side_change", change_sides)
	BattleSystem.connect("battle_finished", battle_over)


#Select objects and end the battle if necessary
func _process(delta):
	#Moving Grid
	if BattleSystem.enemyturn:
		if BattleSystem.current_scenario != null and !skipanim:
			if BattleSystem.current_scenario.state == 2:
				position.x -= 0.5 * delta * 60
	
	
	#Conditions to end the battle
	if !endedbattle:
		if get_enemies().size() == 0: #All enemies defeated (VICTORY)
			endedbattle = true
			BattleSystem.battle_complete(true)
		if all_players_dead(): #All players dead (DEFEAT)
			endedbattle = true
			BattleSystem.battle_complete(false)
	
	
	#Select an enemy
	if selectionmode == SELECT_MODE.ENEMY and get_enemies().size() != 0:
		#Get user input to select
		if Input.is_action_just_pressed("ui_down"):
			enemyselection = enemy_from_array(down_priorities[enemyselection])
			$Selection.play()
			
		if Input.is_action_just_pressed("ui_up"):
			enemyselection = enemy_from_array(up_priorities[enemyselection])
			$Selection.play()
		
		if Input.is_action_just_pressed("ui_right"):
			enemyselection = enemy_from_array(right_priorities[enemyselection])
			$Selection.play()
			
		if Input.is_action_just_pressed("ui_left"):
			enemyselection = enemy_from_array(left_priorities[enemyselection])
			$Selection.play()
			
		enemyselection = more.clamp_wrap(enemyselection, 0, enemy_slots.size()-1)
		
		if !has_enemy(enemyselection):
			enemyselection = get_first_enemy_number()

		emit_signal("enemy_selection_name", get_enemy_at_number(enemyselection).enemyname)
		
		#Show the healthbar and selection arrows of the enemies
		for child in get_enemies():
			child.am_selected(child.enemy_number == enemyselection)
		
		#Get user confirmation or cancellation
		if Input.is_action_just_pressed("ui_accept"):
			for child in get_enemies():
				child.show_arrow(false)
				child.show_small_arrow(false)
				child.show_glow(false)
			emit_signal("object_selected",get_enemy_at_number(enemyselection))
			selectionmode = SELECT_MODE.NONE
			SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
			
		if Input.is_action_just_pressed("ui_cancel"):
			for child in get_enemies():
				child.show_healthbar(false)
				child.show_arrow(false)
				child.show_small_arrow(false)
				child.show_glow(false)
			emit_signal("object_selected",null)
			selectionmode = SELECT_MODE.NONE
			SoundSystem.play_sound("res://Sounds/UI/UI_Cancel.wav","ui_battle",-6)

	elif selectionmode == SELECT_MODE.GRID:
		#Get user input to select
		if Input.is_action_just_pressed("ui_down"):
			gridselection.y += 1
			$Selection.play()
		if Input.is_action_just_pressed("ui_up"):
			gridselection.y -= 1
			$Selection.play()
		if Input.is_action_just_pressed("ui_left"):
			gridselection.x -= 1
			$Selection.play()
		if Input.is_action_just_pressed("ui_right"):
			gridselection.x += 1
			$Selection.play()
			
		gridselection.x = more.clamp_wrap(gridselection.x, 0, get_grid_horizontal_size()-1)
		gridselection.y = more.clamp_wrap(gridselection.y, 0, get_grid_vertical_size()-1)

		emit_signal("enemy_selection_name", Constants.ALPHABET[gridselection.x] + String(gridselection.y+1))
		
		var grids = get_tree().get_nodes_in_group("grid_piece")
		for grid in grids:
			if grid.is_in_group("Horiz " + String(gridselection.x)) and grid.is_in_group("Vert " + String(gridselection.y)):
				grid.am_selected(true)
			else:
				grid.am_selected(false)
		
		#Get user confirmation or cancellation
		if Input.is_action_just_pressed("ui_accept"):
			for child in get_tree().get_nodes_in_group("grid_piece"):
				child.clear_selection()
			emit_signal("object_selected",gridselection)
			selectionmode = SELECT_MODE.NONE
			SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
			
		if Input.is_action_just_pressed("ui_cancel"):
			for child in get_tree().get_nodes_in_group("grid_piece"):
				child.clear_selection()
			emit_signal("object_selected",null)
			selectionmode = SELECT_MODE.NONE
			SoundSystem.play_sound("res://Sounds/UI/UI_Cancel.wav","ui_battle",-6)


#Move up or down whenever the turn changes
func change_sides(enemyturn):
	await get_tree().create_timer(0.05).timeout
	if !skipanim and !System.cutscene:
		if !enemyturn:
			create_tween().tween_property(self, "position", position - Vector2(0,32), 0.2).set_ease(Tween.EASE_IN)
			get_tree().call_group("grid_piece","hide_guides")
			
		if enemyturn:
			await create_tween().tween_property(self, "position", position + Vector2(0,32), 0.2).set_ease(Tween.EASE_IN).finished
			
			print("Support enemies attack")
			for enemy in get_enemies_of_type("support_enemy"):
				if enemy != null:
					if enemy.can_attack:
						enemy.attack()
						await enemy.done_attacking
					await get_tree().create_timer(randf_range(0.25, 0.5)).timeout
			print("Normal enemies attack")
			for enemy in get_enemies_of_type("normal_enemy"):
				if enemy != null:
					if enemy.can_attack:
						enemy.attack()
					await get_tree().create_timer(randf_range(0.25, 0.5)).timeout
			
	else:
		skipanim = false
		
	BattleSystem.party_in_battle = get_players(false, false).size()


#See BattleScenario for how a grid should look
func setup_grid(gridarray):
	#Delete any grid pieces that may already exist
	for child in $Pieces.get_children():
		queue_free()
		
	#Iterate through the grid rows
	for y in gridarray.size():
		#Make a new node2d for every row for organization
		var new_row = Node2D.new()
		new_row.name = str(y)
		$Pieces.add_child(new_row)
		
		#Iterate through the grid columns
		for x in gridarray[y].size():
			if $Pieces.has_node(str(y)):
				if gridarray[y][x] != "missing":
					#Add the main top part of the square
					var new_grid_square = make_grid_square(x,y,gridarray[y][x])
					
					#Add a player in predetermined locations
					var gridint = str_to_var(gridarray[y][x])
					if gridint is int:
						add_player(gridint, new_grid_square.position.x, new_grid_square.position.y, true)
					
					#Finally add the new square to the main grid
					$Pieces.get_node(str(y)).add_child(new_grid_square)
					
	#Move the grid vertically to accomodate for its size
	position.y -= ceilf(((get_grid_vertical_size() * gridpiecesize.y)/2) - (3*gridpiecesize.y/2) + 5)
	for object in $Objects.get_children():
		if "EnemyPos" in object.name:
			object.position.y += ceil(((get_grid_vertical_size() * gridpiecesize.y)/2) - (3*gridpiecesize.y/2))


#Check if a grid square is empty
func is_empty(x,y):
	if y < get_grid_vertical_size() and x >= 0:
		if x < get_grid_horizontal_size() and y >= 0:
			if has_grid(x, y):
				return true
	return false


#Set the selection type
func select_type(mode):
	await get_tree().create_timer(0.1).timeout
	if mode == "enemy":
		selectionmode = SELECT_MODE.ENEMY
		enemyselection = get_first_enemy_number()
	elif mode == "grid":
		selectionmode = SELECT_MODE.GRID
	elif mode == "none":
		selectionmode = SELECT_MODE.NONE


#Return all enemies
func get_enemies():
	var enemyarray = []
	for node in get_tree().get_nodes_in_group("enemy"):
		enemyarray.append(node)
	return enemyarray


#Return all enemies of a certain group
func get_enemies_of_type(enemygroup):
	var enemyarray = []
	for node in get_tree().get_nodes_in_group("enemy"):
		if node.is_in_group(enemygroup):
			enemyarray.append(node)
	return enemyarray


#Return all player nodes
func get_players(partyorder = true, include_dead = true):
	var partyarray = []
	for node in get_tree().get_nodes_in_group("party"):
		if !include_dead:
			if node.dead == false:
				partyarray.append(node)
		else:
			partyarray.append(node)
		
	if partyorder:
		partyarray.sort_custom(sort_by_number)
			
	return partyarray


#Return a random spot on the grid
func get_random_grid(state = "") -> Vector2i:
	get_empty_iterations += 1
	var randy = randi() % get_grid_vertical_size()
	var randx = randi() % get_grid_horizontal_size()
	
	if state == "":
		if is_empty(randx, randy):
			get_empty_iterations = 0
			return Vector2i(randx, randy)
		else:
			if get_empty_iterations < 25:
				return get_random_grid()
			else:
				return Vector2i(0,0)
	else:
		if is_empty(randx, randy):
			get_empty_iterations = 0
			return Vector2i(randx, randy)
		else:
			if get_empty_iterations < 25:
				return get_random_grid()
			else:
				return Vector2i(0,0)


#Return the position of a grid square
func get_grid_position(pos : Vector2i) -> Vector2i:
	if has_node("Pieces/"+str(pos.y)):
		if has_node("Pieces/"+str(pos.y)+"/"+str(pos.x)):
			return Vector2i(get_node("Pieces/"+str(pos.y)+"/"+str(pos.x)).position)
	return Vector2i(0,0)


#Add enemies to the grid
func add_enemies(enemyarray : Array[EnemyData]):
	var iteration = 0
	
	for enemy in enemyarray:
		if enemy.enemyscene != null:
			var new_enemy = enemy.enemyscene.instantiate()
			if new_enemy.is_in_group("in_place") == false:
				new_enemy.position = get_node("Objects/EnemyPos"+str(iteration)).position
			new_enemy.connect("done_attacking", enemy_done)
			new_enemy.enemy_number = iteration
			enemy_slots[iteration] = true
			
			new_enemy.is_advanced = enemy.is_advanced
			new_enemy.metadata_int = enemy.general_int
			
			if iteration == 1 or iteration == 3:
				new_enemy.gridrow = 0
			elif iteration == 0:
				new_enemy.gridrow = 1
			elif iteration == 2 or iteration == 4:
				new_enemy.gridrow = 2
				
			$Objects.add_child(new_enemy)
			
		else:
			enemy_slots[iteration] = false
			
		iteration += 1


#Check when enemies finish their turn
func enemy_done():
	enemiesdone += 1
	if enemiesdone >= get_not_dead_enemies().size():
		enemiesdone = 0
		BattleSystem.turn_end()


#Add an object to the grid
func add_object(x,y,object_scene,direction = Vector2i(0,1), direct = false):
	var use_pos = Vector2i(x,y)
	if direct:
		use_pos = Vector2i(round(x/gridpiecesize.x),round(y/gridpiecesize.y))
	
	var square = get_square_at_position(use_pos)
	if square != null:
		var new_object = object_scene.instantiate()
		new_object.grid_position = Vector2i(use_pos.x,use_pos.y)
		if object_scene == obj_conveyor:
			new_object.set_direction(direction)
			
		if object_scene == obj_web:
			square.add_fobject(new_object)
		else:
			square.add_object(new_object)


#Add a player to the grid
func add_player(partynum, x, y, direct = false):
	if partynum < PartyStats.party.size():
		var new_player = player_scene.instantiate()
		new_player.party_number = partynum
		if !direct:
			new_player.position = get_grid_position(Vector2i(x, y+(gridpiecesize.y/2)-3))
			new_player.gridpos = Vector2i(x,y)
		else:
			new_player.position = Vector2i(x,y+(gridpiecesize.y/2)-3)
			new_player.gridpos = Vector2i(x/gridpiecesize.x,(y/gridpiecesize.y))
		new_player.position.y -= round(gridpiecesize.y/2)
		$Objects.add_child(new_player)
		BattleSystem.party_in_battle += 1


#Check if a party member is at a given position
func is_party_at_position(x,y):
	for party in get_players():
		if party.gridpos == Vector2i(x,y):
			return true
	return false


#Check if all party members are dead
func all_players_dead():
	for player in get_players():
		if !player.dead:
			return false
	return true


#Get the position of the topleft grid piece (at 0,0)
func get_grid_topleft_position():
	return Vector2i(get_node("Pieces/0/0").get_global_position())


#Return the horizontal size of the grid
func get_grid_horizontal_size():
	var largestx = 0
	
	for child in $Pieces.get_children():
		if child.get_child_count() > largestx:
			largestx = child.get_child_count()
	
	return largestx


#Return the vertical size of the grid
func get_grid_vertical_size():
	return $Pieces.get_child_count()


#Show a warning on the specified squares
func warn_squares(pos_array, time = 1):
	for square in pos_array:
		var use_square = get_square_at_position(square)
		if use_square != null:
			use_square.warn(time)


#Get the grid piece at the specified position
func get_square_at_position(pos = Vector2i(0,0)):
	var grids = get_tree().get_nodes_in_group("grid_piece")
	for grid in grids:
		if grid.is_in_group("Horiz " + str(pos.x)) and grid.is_in_group("Vert " + str(pos.y)):
			return grid
	return null


#Get the position of the currently target party member
func get_targeted_player_position():
	for player in get_players():
		if player.targeted:
			return player.gridpos
	return Vector2i(0,0)


#Remove an enemy from the slots
func remove_enemy(slot):
	if slot < enemy_slots.size():
		enemy_slots[slot] = false


#Make sure all enemy slots aren't full
func can_add_enemy():
	if enemy_slots.find(false) != -1:
		return true
	else: return false


#Add an enemy to the specified position
func add_enemy(enemy_name, make_advanced = false):
	var slot = enemy_slots.find(false)
	
	if slot != -1:
		var new_enemy = load("res://Objects/Battle/Enemies/"+enemy_name+".tscn").instantiate()
		if make_advanced: new_enemy.is_advanced = true
		new_enemy.position = get_node("Objects/EnemyPos"+str(slot)).position
		new_enemy.connect("done_attacking", enemy_done)
		new_enemy.enemy_number = slot
		enemy_slots[slot] = true
		
		if slot == 1 or slot == 3:
			new_enemy.gridrow = 0
		elif slot == 0:
			new_enemy.gridrow = 1
		elif slot == 2 or slot == 4:
			new_enemy.gridrow = 2
		
		new_enemy.play_entry_animation = true
		$Objects.add_child(new_enemy)


#Check to see if an enemy exists in a slot
func has_enemy(slot):
	if slot >= enemy_slots.size():
		return false
	else:
		return enemy_slots[slot]


#Get the first available enemy
func get_first_enemy_number(from=0):
	return enemy_slots.find(true,from)


#Get the enemy at a specified slot
func get_enemy_at_number(slot):
	for enemy in get_enemies():
		if enemy.enemy_number == slot:
			return enemy
	return null


#Get all enemies who aren't dead
func get_not_dead_enemies(group = ""):
	var enemyarray = []
	if group != "":
		for enemy in get_enemies_of_type(group):
			if enemy.hp > 0:
				enemyarray.append(enemy)
	else:
		for enemy in get_enemies():
			if enemy.hp > 0:
				enemyarray.append(enemy)
	return enemyarray


#Runs when the battle is over
func battle_over():
	skipanim = true


#Append a grid segment to the rightmost part of the grid
func append_grid_h(grid_segment):
	var starting_x = get_grid_horizontal_size()
	for y in grid_segment.size():
		for x in grid_segment[y].size():
			var new_square = make_grid_square(x+starting_x,y,grid_segment[y][x])
			new_square.set_appear_animation(true)
			$Pieces.get_node(str(y)).add_child(new_square)
		await get_tree().create_timer(0.1).timeout


#Make and return a new grid square
func make_grid_square(x,y, state = "empty"):
	var new_grid_square = load("res://Objects/Battle/GridObjects/GridPiece.tscn").instantiate()
	new_grid_square.name = str(x)
	new_grid_square.position = Vector2i((x*gridpiecesize.x), (y*gridpiecesize.y))
	
	#Set color
	new_grid_square.set_modulate(BattleSystem.current_scenario.get_colors()[in_pattern])
	in_pattern += 1
	if in_pattern >= BattleSystem.current_scenario.get_colors().size():
		in_pattern = 0
	new_grid_square.add_to_group("Horiz "+str(x))
	new_grid_square.add_to_group("Vert "+str(y))
	new_grid_square.grid_position = Vector2i(x,y)
	
	#Add ice in predetermined locations
	if "ice" in state:
		new_grid_square.add_object(obj_ice.instantiate())
	
	#Add web in predetermined locations
	if "web" in state:
		new_grid_square.add_object(obj_web.instantiate())
		
	#Add lava in predetermined locations
	if "lava" in state:
		new_grid_square.add_object(obj_lava.instantiate())
		
	#Add conveyor belts in predetermined locations
	if "conveyor" in state:
		var new_conveyor = obj_conveyor.instantiate()
		if "conveyor_down" in state:
			new_conveyor.set_direction(Vector2i(0,1))
		if "conveyor_up" in state:
			new_conveyor.set_direction(Vector2i(0,-1))
		if "conveyor_left" in state:
			new_conveyor.set_direction(Vector2i(-1,0))
		if "conveyor_right" in state:
			new_conveyor.set_direction(Vector2i(1,0))
		new_grid_square.add_object(new_conveyor)
	
	return new_grid_square


#Test of the append_grid_h function
func _on_TestAppend_timeout():
	if BattleSystem.current_scenario.state == 2:
		append_grid_h([["empty"],["empty"],["ice"],["empty"],["empty"]])


func get_grid_closest_to_point(point = Vector2(0,0)):
	var closest = get_random_grid()
	for compare_square in get_tree().get_nodes_in_group("grid_piece"):
		var compare_to = get_square_at_position(closest)
		if compare_square != null:
			if compare_square.global_position.distance_to(point) < compare_to.global_position.distance_to(point):
				print("Found new closest square")
				if !is_party_at_position(compare_square.grid_position.x, compare_square.grid_position.y):
					closest = compare_square.grid_position
	return closest


func get_random_grid_position():
	var randomtile = get_random_grid()
	return get_grid_position(randomtile) + get_grid_topleft_position()


#Sorting algorithm used for sorting the party
func sort_by_number(a, b):
	return a.party_number < b.party_number


func has_grid(x, y):
	if y <= $Pieces.get_child_count():
		for piece in get_node("Pieces/"+str(y)).get_children():
			if piece.grid_position == Vector2i(x, y):
				return true
	return false


func enemy_from_array(array):
	for element in array:
		if has_enemy(element):
			return element
	return enemyselection
