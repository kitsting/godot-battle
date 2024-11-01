extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


var types = ["Pawn", "Rook", "Bishop"]
var elements = ["", "Ice", "Fire", "Web"]

var typedescs = ["This piece will drop onto a single spot, ",
"This peice will move in vertical or horizontal lines, ",
"This peice will move diagonally across the board, "]

var elementdescs = ["crushing anything in its way.",
"leaving behind ice",
"leaving behind fire",
"leaving behind sticky webs"
]

var type = "Pawn"
var element = ""
var available_elements = [""]

var exhausted = false
var times_changed = 0
var speed_scale = 1

var initial_position = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func initialize():
	if is_advanced:
		available_elements = ["", "Ice", "Fire", "Web"]
	
	random_combo()
	$Sprite.visible = false
	await get_tree().create_timer(0.1).timeout
	$Sprite.visible = true


func attack():
	initial_position = position
	
	if exhausted:
		exhausted = false
		await random_combo()
		
	speed_scale = 5.0/gridref.get_enemies().size()
	print("speed scale is "+str(speed_scale))
	#await get_tree().create_timer(0.6*(enemy_number-(gridref.get_first_enemy_number(1)-1))).timeout
	$AnimationPlayer.play("Chess/rise",-1,1.4)
	await $AnimationPlayer.animation_finished
	
	if type == "Pawn":
		var target_square = more.choose([gridref.get_random_grid(),gridref.get_targeted_player_position()])
		gridref.warn_squares([target_square])
		await get_tree().create_timer(1.1/speed_scale).timeout

		await move_to_square(target_square)
		await pound(0.15)
		
		if element == "Ice":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_ice)
		if element == "Fire":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_lava)
		if element == "Web":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_web)
			
		await get_tree().create_timer(0.75).timeout
		
		await return_to_position(initial_position)
		
	elif type == "Bishop":
		var target_square
		var dest_square
		var dest_offset
		var corner = more.choose(["NW","SW","NE","SE"])
		if corner == "NW":
			target_square = Vector2i(0,0)
			dest_square = Vector2i(gridref.get_grid_horizontal_size()-1,gridref.get_grid_vertical_size()-1)
			dest_offset = Vector2i(gridref.gridpiecesize)
		elif corner == "SE":
			target_square = Vector2i(gridref.get_grid_horizontal_size()-1,gridref.get_grid_vertical_size()-1)
			dest_square = Vector2i(0,0)
			dest_offset = Vector2i(-gridref.gridpiecesize)
		elif corner == "SW":
			target_square = Vector2i(0,gridref.get_grid_vertical_size()-1)
			dest_square = Vector2i(gridref.get_grid_horizontal_size()-1,0)
			dest_offset = Vector2i(gridref.gridpiecesize.x,-gridref.gridpiecesize.y)
		else:
			dest_square = Vector2i(0,gridref.get_grid_vertical_size()-1)
			target_square = Vector2i(gridref.get_grid_horizontal_size()-1,0)
			dest_offset = Vector2i(-gridref.gridpiecesize.x,gridref.gridpiecesize.y)
		
		gridref.warn_squares([target_square])
		await get_tree().create_timer(1.15/speed_scale).timeout
		
		await move_to_square(target_square)
		await pound(0.15)
		
		if element == "Ice":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_ice)
		if element == "Fire":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_lava)
		if element == "Web":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_web)
		
		for gridx in int(abs(dest_square.x-target_square.x))+1:
			for gridy in int(abs(dest_square.y-target_square.y))+1:
				if gridx == gridy and (corner == "NW" or corner == "SE"):
					gridref.warn_squares([Vector2(gridx,gridy)])
				elif gridx == (abs(gridref.get_grid_horizontal_size()-1-gridy)) and (corner == "NE" or corner == "SW"):
					gridref.warn_squares([Vector2(gridx,gridy)])
				
		await get_tree().create_timer(0.85/speed_scale).timeout
		
		var move_to =  Vector2(gridref.get_grid_position(dest_square) + dest_offset)
		
		$Particles2D.emitting = true
		await create_tween().tween_property(self,"position",move_to,0.45).finished
		$Particles2D.emitting = false
		
		await get_tree().create_timer(0.25).timeout
		
		await return_to_position(initial_position)
		
	elif type == "Rook":
		var target_square
		var dest_square
		var dest_offset
		var mode = more.choose(["Left","Right","Up","Down"])
		if mode == "Left":
			var row = randi() % gridref.get_grid_vertical_size()
			target_square = Vector2i(gridref.get_grid_horizontal_size()-1,row)
			dest_square = Vector2i(0, row)
			dest_offset = Vector2i(-gridref.gridpiecesize.x,0)
		elif mode == "Right":
			var row = randi() % gridref.get_grid_vertical_size()
			target_square = Vector2i(0,row)
			dest_square = Vector2i(gridref.get_grid_horizontal_size()-1, row)
			dest_offset = Vector2i(gridref.gridpiecesize.x,0)
		elif mode == "Up":
			var column = randi() % gridref.get_grid_horizontal_size()
			target_square = Vector2i(column, gridref.get_grid_vertical_size()-1)
			dest_square = Vector2i(column, 0)
			dest_offset = Vector2i(0,-gridref.gridpiecesize.y)
		else:
			var column = randi() % gridref.get_grid_horizontal_size()
			target_square = Vector2i(column, 0)
			dest_square = Vector2i(column, gridref.get_grid_vertical_size()-1)
			dest_offset = Vector2i(0,gridref.gridpiecesize.y)
			
		gridref.warn_squares([target_square])
		await get_tree().create_timer(1.15/speed_scale).timeout
		
		await move_to_square(target_square)
		await pound(0.15)
		
		if element == "Ice":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_ice)
		if element == "Fire":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_lava)
		if element == "Web":
			gridref.add_object(target_square.x, target_square.y, gridref.obj_web)
		
		if mode == "Up" or mode == "Down":
			for grid in int(abs(target_square.y-dest_square.y))+1:
				gridref.warn_squares([Vector2(target_square.x,grid)])
		else:
			for grid in int(abs(target_square.x-dest_square.x))+1:
				gridref.warn_squares([Vector2(grid,target_square.y)])
				
		await get_tree().create_timer(0.85/speed_scale).timeout
		
		var move_to =  Vector2(gridref.get_grid_position(dest_square) + dest_offset)
		
		$Particles2D.emitting = true
		await create_tween().tween_property(self,"position",move_to,0.3).finished
		$Particles2D.emitting = false
		
		await get_tree().create_timer(0.25).timeout
		
		await return_to_position(initial_position)
		
	else:
		$AnimationPlayer.play("Chess/pound")
		await $AnimationPlayer.animation_finished
		get_tree().call_group("camera","shake",0.5,18,2)
		$Impact.play()

	await get_tree().create_timer(0.1).timeout
	exhausted = more.choose([true,false])
	if exhausted:
		$Sprite/ExhaustSprite.texture = load("res://Graphics/Enemies/Boss_Chess/Exhausted_"+type+".png")
		$Exhaust.play()
		$AnimationPlayer.play("Chess/exhaust")
		await $AnimationPlayer.animation_finished
		$Sprite/ExhaustSprite.visible = false
		update()
	await get_tree().create_timer(0.1).timeout
	emit_signal("done_attacking")


func random_combo():
	randomize()
	type = more.choose(types)
	element = more.choose(available_elements)
	
	update()


func update():
	if !exhausted:
		if times_changed > 0:
			$AnimationPlayer.play("Chess/flatten",-1,1.5)
			await $AnimationPlayer.animation_finished
		defense = 0.25
		if element == "":
			$Sprite.animation = "Active_"+type
		else:
			$Sprite.animation = element+"_"+type
		if times_changed > 0:
			$AnimationPlayer.play("Chess/unflatten",-1,1.5)
		
		times_changed += 1
	else:
		$Sprite.animation = "Exhausted_"+type
		defense = -0.25
		
	$Particles2D.texture = $Sprite.sprite_frames.get_frame_texture($Sprite.animation,0)
	$Path2D/PathFollow2D/Sprite.texture = $Sprite.sprite_frames.get_frame_texture($Sprite.animation,0)
	
	if element != "":
		enemyname = element + " " + type
	else:
		enemyname = type
	enemydesc = typedescs[types.find(type)] + elementdescs[elements.find(element)]
	
	if element == "Fire":
		$Sprite/Hitbox.add_to_group("fire")
	else:
		if $Sprite/Hitbox.is_in_group("fire"):
			$Sprite/Hitbox.remove_from_group("fire")
		
	
func pound(time = 0.8):
	$Sprite/Hitbox.set_disabled(true)
	$AnimationPlayer.play("Chess/pound")
	await $AnimationPlayer.animation_finished
	$Sprite/Hitbox.set_disabled(false)
	get_tree().call_group("camera","shake",0.5,18,2)
	$Impact.play()
	await get_tree().create_timer(time).timeout
	
	
func return_to_position(pos):
	#Rise
	$Sprite/Hitbox.set_disabled(true)
	$AnimationPlayer.play("Chess/rise",-1,1.5)
	await $AnimationPlayer.animation_finished
	
	#Go back to starting position
	position = pos
	$AnimationPlayer.play("Chess/descend")
	await $AnimationPlayer.animation_finished
	
	
func move_to_square(target_square):
	position = gridref.get_grid_position(target_square)
	#position.y -= 8
	await get_tree().create_timer(0.1).timeout


func die():
	$AnimationPlayer.play("Chess/death")
	await $AnimationPlayer.animation_finished
	queue_free()


func entry():
	$AnimationPlayer.play("Chess/pound")
	await $AnimationPlayer.animation_finished
	get_tree().call_group("camera","shake",0.5,18,2)
	$Impact.play()
