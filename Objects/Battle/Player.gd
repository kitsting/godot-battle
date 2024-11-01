extends Node2D

var gridpos = Vector2(1,1)

var xincrement = 35
var yincrement = 23

var maxhealth = 100
var health = maxhealth

var attackpower = 8
var canready = true

var canmove = false
var move_cooldown = false
var dead = false
var iframes = false
var iframe_amount = 0.5

var targeted = true

var party_number = 0
var data = null

var iced = false
var webbed = false
var conveyored = false
var conveyordir = Vector2(0,0)
var inlava = 0
var scared = false
var stuck_in = null
var previous_move = Vector2(0,0)
var buffer_input = Vector2(0,0)
var fallen = false

var cooldowns = []
var cooldown_counts = []
var cooldown_rate = 2
var global_cooldown = 0

var energy_shield = false


@onready var grid_node = get_parent().get_parent()


signal health_changed(hp)
signal done_attacking



func _ready():
	#Duplicate the "white glow" shader
	set_material(get_material().duplicate(true))
	
	#Load data for the party member
	data = PartyStats.load_party_id(party_number)
	
	$Sprite.frames = data.get_battle_costume()
	$Sprite.play()
	
	$CanMove.modulate = data.select_color
	$CanMove.modulate.a = 0.5
	
	attackpower = data.attack
	
	#Connect signals
	await get_tree().create_timer(0.5).timeout
	BattleSystem.connect("side_change", change_sides)
	BattleSystem.connect("battle_finished", clear_cooldowns)
	
	#Play idle animation
	$Sprite.animation = "idle"
	
	#Make sure the player's position is an integer
	position.x = roundi(position.x)
	position.y = roundi(position.y)


func _input(_event):
	if BattleSystem.enemyturn and canmove and !BattleSystem.dialogue and !System.cutscene:
		if Input.is_action_just_pressed("ui_up"):
			grid_move(0, -1)
		elif Input.is_action_just_pressed("ui_down"):
			grid_move(0, 1)
		elif Input.is_action_just_pressed("ui_left"):
			grid_move(-1, 0)
		elif Input.is_action_just_pressed("ui_right"):
			grid_move(1, 0)


func _on_MoveCooldown_timeout():
	#Move again if an ice square or conveyor square was touched
	if !iced and !conveyored:
		move_cooldown = false
		if buffer_input != Vector2(0,0):
			grid_move(buffer_input.x, buffer_input.y)
	elif iced:
		iced = false
		move_cooldown = false
		grid_move(previous_move.x, previous_move.y, false)
	elif conveyored:
		conveyored = false
		move_cooldown = false
		grid_move(conveyordir.x,conveyordir.y, false)
	
	
func _process(_delta):
	#Make sure the UI around the player is properly offset
	$UI.offset = global_position + Vector2(0, 8)
			
	#Fall off the grid if the player happens to move to an empty square
	if BattleSystem.enemyturn:
		if !grid_node.has_grid(gridpos.x, gridpos.y):
			fallen = true
			modulate.a = 0
			canmove = false
			
	#Show the hurt idle animation if at low health and the wrong animation is playing 
	if $Sprite.animation == "idle" and health <= 25:
		$Sprite.animation = "idle_hurt"
		
	if $Sprite.animation == "idle_hurt" and health > 25: #and vice versa
		$Sprite.animation = "idle"
		
		
	#Move indicator arrows on the board
	if BattleSystem.enemyturn and canmove and !move_cooldown: #Show the arrows only if moving is possible
		$CanMove.visible = true
	else:
		$CanMove.visible = false
		
	if canmove: #Show individual arrows based on which directions are obstructed
		$CanMove/Down.visible = can_move(Vector2i(0,1))
		$CanMove/Up.visible = can_move(Vector2i(0,-1))
		$CanMove/Left.visible = can_move(Vector2i(-1,0))
		$CanMove/Right.visible = can_move(Vector2i(1,0))
			
			

func take_damage(amount, cause = "general"):
	#See if theres iframes from the last time damage was taken
	var iframeslast = iframes
	
	
	#Set iframes if none are already active, except for moving
	if !iframes and cause != "moving" and cause != "lava":
		if !energy_shield:
			health -= amount
		else:
			if BattleSystem.currentap > 0:
				BattleSystem.change_ap(-amount*2)
			else:
				health -= amount
		iframes = true
		$Sprite.self_modulate.a = 0.6
		$IFrames.start(iframe_amount)
		$Sprite.animation = "ouch"
	elif cause == "moving" or cause == "lava":
		health -= amount
		if health < -99:
			health = -99
	
	#Take damage from moving too much, but don't die from it
	if cause == "moving":
		if health < 1:
			health = 1
		else:
			get_tree().call_group("camera","shake",0.5,14,1)
			$HurtMove.play()
	
	#Shake the camera and display effects when hurt by conventional attacks
	if amount > 0 and cause != "moving" and !iframeslast and cause != "lava":
		get_tree().call_group("camera","shake",0.5,14,4)
		$Hurt.play()
		make_damage_display(amount)
	
	#Die
	if health <= 0 and rotation != 90:
		dead = true
		rotation = 90
		$Sprite.stop()
		await get_tree().create_timer(0.25).timeout
		make_damage_display("DOWN")
		

	#Let other nodes know that the player's health is different now
	emit_signal("health_changed", health)
	
	
func change_sides(enemyturn):
	#Become greyed out if its the player's turn and this party member isn't targeted
	if enemyturn:
		tick_cooldown()
		$Sprite.modulate = Color(1,1,1,1)
		$Sprite.animation = "idle"
		if !targeted:
			$Sprite.modulate = Color(0.5, 0.5, 0.5, 0.75)
			$Collision/CollisionShape2D.disabled = true
			canmove = false
		
	if !enemyturn:
		#Reset variables
		energy_shield = false
		
		#Make sure the player's health is at 1 if using the "one hit kill" badge
		if PartyStats.has_badge("One Hit Kill"):
			if health > 1:
				health = 1
				emit_signal("health_changed", health)
		
		#Fall back onto the grid if the player fell off
		if fallen:
			await get_tree().create_timer(0.05*party_number).timeout
			fallen = false
			var new_pos = grid_node.get_grid_closest_to_point(Vector2(190,149))
			print(new_pos)
			position = grid_node.get_grid_position(new_pos.x, new_pos.y)
			gridpos = new_pos
			$AnimationPlayer.play("fall")
			await $AnimationPlayer.animation_finished
			take_damage(20)
			
		#Reset modulation and make it impossible to be hit while in the menu
		$Sprite.modulate.a = 1
		$Collision/CollisionShape2D.disabled = false
		canmove = true
		
	#Check for enemies that instill fear naturally
	set_scared(false)
	if grid_node.get_enemies_of_type("fear").size() != 0:
		set_scared(true)
	#Check for member-specific fears
	if data.get_fears() != null:
		for fear in data.get_fears():
			if grid_node.get_enemies_of_type(fear).size() != 0:
				set_scared(true)


func _on_Hitbox_area_entered(area):
	var totaldef = data.defense + PartyStats.defense_boost
	
	#Take damage when touching a projectile
	if area.is_in_group("damage"):
		if area.is_in_group("flying_bullet"):
			if area.aiming_for() != null:
				if area.aiming_for() == gridpos:
					take_damage(max(area.power - totaldef, 1))
					area.queue_free()
		else:
			take_damage(max(area.power - totaldef, 1))
			area.queue_free()
		
	#Take damage when touching an enemy
	if area.is_in_group("enemy_hitbox"):
		take_damage(max(area.damage - totaldef, 1))
		
	#Slip on ice
	if area.is_in_group("ice") and move_cooldown:
		iced = true
		
	#Get caught in webs
	if area.is_in_group("web"):
		webbed = true
		stuck_in = area
		$Webbed.visible = true
		
	#Move on conveyors
	if area.is_in_group("conveyor"):
		conveyored = true
		conveyordir = area.get_parent().get_direction()
		
	#Keep track of how many lava cells the player is in
	if area.is_in_group("lava"):
		inlava += 1


func grid_move(xamount, yamount, useap = true):
	#Play a sound if moving is impossible
	if !can_move(Vector2i(xamount, yamount)):
		$CantMoveSound.play()
	
	#Move (if possible)
	if can_move(Vector2i(xamount, yamount)) and !dead and !move_cooldown and !webbed:
		move_cooldown = true
		previous_move = Vector2(xamount, yamount)
		gridpos.x += xamount
		gridpos.y += yamount
		var move_speed = calculate_move_speed()
		var move_tween = create_tween()
		move_tween.tween_property(self, "position", position + Vector2(xincrement * xamount, yincrement * yamount), move_speed).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		$MoveSound.play()
		$MoveCooldown.start(calculate_move_cooldown())
		if useap:
			if BattleSystem.currentap > 0:
				var move_reduction = 0
				if PartyStats.has_badge("AP Move Down"):
					move_reduction += 1
				BattleSystem.change_ap(-2 + move_reduction)
			else:
				take_damage(3, "moving")
		buffer_input = Vector2(0,0)
	elif webbed: #Get out of a web if currently stuck in one
		webbed = false
		$Webbed.visible = false
		if stuck_in != null:
			stuck_in.get_parent().break_web()
			stuck_in = null
			
	#Buffer movement inputs if the move cooldown is almost over
	if move_cooldown:
		if $MoveCooldown.time_left <= 0.1:
			buffer_input = Vector2(xamount, yamount)
	

func _on_IFrames_timeout():
	iframes = false
	$Sprite.self_modulate.a = 1
	
	if $Sprite.animation == "ouch":
		$Sprite.animation = "idle"


func set_scared(state):
	scared = state
	if state == true:
		$ScaredTimer.start(0.3)


func _on_ScaredTimer_timeout():
	$AnimationPlayer.play("scared",-1,5)
	if scared:
		randomize()
		$ScaredTimer.start(randf_range(0,2))


func show_arrow(arrow_show = true):
	$UI/Arrow.visible = arrow_show


func show_small_arrow(arrow_show = true):
	$UI/SmallArrow.visible = arrow_show


func show_glow(glow_show = true):
	if glow_show:
		$AnimationPlayer.play("glow")
	else:
		$AnimationPlayer.play("RESET")

	
func show_timing_good(type = "OK"):
	get_node("UI/Timing"+type).visible = true
	await get_tree().create_timer(0.75).timeout
	get_node("UI/Timing"+type).visible = false
	
func show_timing_bad():
	$UI/TimingBad.visible = true
	await get_tree().create_timer(0.75).timeout
	$UI/TimingBad.visible = false


func get_ready(time = 1):
	await get_tree().create_timer((time/3.0)+0.1).timeout
	if canready:
		$AnimationPlayer.play("ready",-1,2)
		
func reset_anim_player():
	$AnimationPlayer.play("RESET")
		
		
func thinking():
	if !BattleSystem.enemyturn:
		if health > 25:
			looped_anim("thinking")
		else:
			looped_anim("thinking_hurt")
		$Sprite.modulate = Color(1,1,1)


func not_thinking():
	if !BattleSystem.enemyturn:
		$Sprite.modulate = Color(0.65,0.65,0.65)


func reset_anim():
	$Sprite.animation = "idle"
	$Sprite.play()

func single_anim(anim_name):
	print("playing anim" + anim_name)
	$Sprite.animation = anim_name
	await $Sprite.animation_finished
	reset_anim()
	
func looped_anim(anim_name):
	$Sprite.animation = anim_name


func _on_LavaCheck_timeout():
	if inlava > 0 and BattleSystem.enemyturn and !dead:
		take_damage(1,"lava")
		$HurtLava.play()


func _on_Collision_area_exited(area):
	if area.is_in_group("lava"):
		inlava -= 1


func solid_object_in_direction(direction = Vector2i(0,1)):
	var collider = null
	#Down
	if direction == Vector2i(0,1):
		collider = $RayCastD.get_collider()
	#Up
	elif direction == Vector2i(0,-1):
		collider = $RayCastU.get_collider()
	#Left
	elif direction == Vector2i(-1,0):
		collider = $RayCastL.get_collider()
	#Right
	elif direction == Vector2i(1,0):
		collider = $RayCastR.get_collider()

	if collider != null:
		if collider.is_in_group("solid"):
			return true
	return false
	
	
func heal(amount):
	$ParticlesAnim.play("Heal")
	SoundSystem.play_sound("res://Sounds/HealthRecover.wav","battle_sfx",-6)
	make_damage_display(amount, true)
	health += amount
	if health > maxhealth:
		health = maxhealth
		
	emit_signal("health_changed", health)
	
	if health > 0 and dead:
		dead = false
		rotation = 0
		$Sprite.playing = true
		await get_tree().create_timer(0.25).timeout
		make_damage_display("UP")


func make_damage_display(amount, is_heal_display = false):
	var new_dmg_display = null
	if !is_heal_display:
		new_dmg_display = load("res://Objects/UI/Battle/DamageDisplay.tscn").instantiate()
		new_dmg_display.set_damage(amount)
	else:
		new_dmg_display = load("res://Objects/UI/Battle/HealDisplay.tscn").instantiate()
		new_dmg_display.set_amount(amount)
	new_dmg_display.set_position(global_position)
	get_tree().get_root().add_child(new_dmg_display)


func calculate_move_speed():
	var base_speed = 0.12
	
	if PartyStats.defense_boost > 0:
		base_speed += PartyStats.defense_boost * 0.025
	base_speed += int(scared) * 0.1

	return base_speed

func calculate_move_cooldown():
	var base_cooldown = 0.15
	
	if PartyStats.defense_boost > 0:
		base_cooldown += PartyStats.defense_boost * 0.025
	base_cooldown += int(scared) * 0.1
		
	return base_cooldown


func set_attack_cooldown(thisattack):
	print("setting cooldown +"+str(thisattack.ap_penalty))
	if thisattack.ap_penalty != 0:
		if cooldowns.find(thisattack) == -1:
			cooldowns.append(thisattack)
			cooldown_counts.append(thisattack.ap_penalty)
		else:
			cooldown_counts[cooldowns.find(thisattack)] += thisattack.ap_penalty
	print(get_cooldown(thisattack))
				
func tick_cooldown(amount=0):
	var iteration = 0
	
	var use_rate = cooldown_rate
	if amount != 0:
		use_rate = amount
	
	global_cooldown -= use_rate
	if global_cooldown <= 0:
		global_cooldown = 0
	
	
	if cooldowns != []:
		for count in cooldown_counts:
			cooldown_counts[iteration] -= use_rate
			if cooldown_counts[iteration] <= 0:
				cooldowns.remove_at(iteration)
				cooldown_counts.remove_at(iteration)
			iteration += 1
	
func get_cooldown(thisattack):
	if cooldowns.find(thisattack) != -1:
		return cooldown_counts[cooldowns.find(thisattack)] + global_cooldown
	return global_cooldown
	
func clear_cooldowns():
	cooldowns = []
	cooldown_counts = []
	global_cooldown = 0
	
	
func item_animation(texture):
	$Sprite.animation = "useitem"
	await $Sprite.animation_finished
	var newitem = load("res://Objects/Battle/MiniItem.tscn").instantiate()
	newitem.set_texture(texture)
	$ItemUse.add_child(newitem)
	await newitem.anim_done
	
	
func all_done():
	reset_anim()
	$Sprite.modulate = Color.WHITE
	$Sprite.self_modulate = Color.WHITE
	
	
func can_move(offset : Vector2i):
	if grid_node.is_empty(gridpos.x + offset.x, gridpos.y + offset.y) and !solid_object_in_direction(offset):
		return true
	else:
		return false
