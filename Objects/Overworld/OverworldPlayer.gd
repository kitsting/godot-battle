extends CharacterBody2D


const MAX_SPEED = 80
const FRICTION = 32

var prevaxis = Vector2.ZERO
var last_real_axis = Vector2.ZERO
var prevpositions = []
var prevanimations = []
var target_position = null
var next = null

var instairs = 0
var speedmod = Vector2(1,1)

var anim_set_manually = false

enum dirs {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	UP_LEFT,
	UP_RIGHT,
	DOWN_LEFT,
	DOWN_RIGHT,
}
var currentdir = dirs.DOWN

var speed = MAX_SPEED
var objectdist = 28

var deadzone = 0.25
var joymode = false

var party_number = 0
var leader = true
var moving = true

var woodsound = preload("res://Sounds/Footstep/woodstep.wav")
var stonesound = preload("res://Sounds/Footstep/stonestep.wav")


func _ready():
	$Sprite.play()
	
	position = round(position)
	
	$Sprite.frames = PartyStats.load_party_id(party_number).get_overworld_costume()


func get_last_in_chain():
	var target = self
	while next != null:
		target = next
		next = target.next
	return target


func move(top_speed,top_friction,delta,custom_axis=null):
	delta *= 60
	var input_vector = Vector2.ZERO
	if custom_axis == null:
		input_vector = get_input_axis()
	else:
		input_vector = custom_axis
	
	if input_vector != Vector2.ZERO:
		velocity = round(input_vector * top_speed * delta)
		#velocity = velocity.limit_length(top_speed*speedmod.y)
	else:
		velocity = velocity.move_toward(Vector2.ZERO,top_friction)

	var prev_position = position
	move_and_slide()
	
#	position.x = round(position.x)
#	position.y = round(position.y)
	
#	prev_position.x = round(prev_position.x)
#	prev_position.y = round(prev_position.y)
	
	if prev_position == position:
		moving = false
	else:
		moving = true
	return input_vector


func get_input_axis(): #Get up/down and left/right and normalize the result
	var axis = Vector2.ZERO
	axis.x = Input.get_axis("ui_left","ui_right")
	axis.y = Input.get_axis("ui_up", "ui_down")
	axis = axis.normalized()
	return axis

	
func _physics_process(delta):
	var axis = Vector2(0,0)
	
	if !System.cutscene and leader and !BattleSystem.battling:
		target_position = null
		axis = move(speed,FRICTION,delta)
		
		#Round input axis for analog stick input
		axis.x = round(axis.x)
		axis.y = round(axis.y)

		#Walking on cardinal directions
		if axis.y > 0 and axis.x == 0:
			currentdir = dirs.DOWN
			$Sprite.animation = "down_walk"
		if axis.y < 0 and axis.x == 0:
			currentdir = dirs.UP
			$Sprite.animation = "up_walk"
		if axis.x > 0 and axis.y == 0:
			currentdir = dirs.RIGHT
			$Sprite.animation = "right_walk"
		if axis.x < 0 and axis.y == 0:
			currentdir = dirs.LEFT
			$Sprite.animation = "left_walk"
			
		#Walking diagonally
		if axis.x < 0 and axis.y > 0: $Sprite.animation = "down_left_walk"
		if axis.x > 0 and axis.y > 0: $Sprite.animation = "down_right_walk"
		if axis.x < 0 and axis.y < 0: $Sprite.animation = "up_left_walk"
		if axis.x > 0 and axis.y < 0: $Sprite.animation = "up_right_walk"
		
		anim_set_manually = false
			
			
		if axis.x != 0 or axis.y != 0:
			last_real_axis.x = axis.x
			last_real_axis.y = axis.y
			
			
			
		$Interact.target_position = Vector2(objectdist * last_real_axis.x, objectdist * last_real_axis.y)
			
			
	#Stop walking animation
	if axis.x == 0 and axis.y == 0 and !anim_set_manually:
		if String($Sprite.animation).contains("walk"):
			if $Sprite.animation != String($Sprite.animation).trim_suffix("_walk"):
				$Sprite.animation = String($Sprite.animation).trim_suffix("_walk")
				$Sprite.frame = 0
		position = round(position)


func _input(_event):
	if leader and !BattleSystem.battling:
		if Input.is_action_just_pressed("ui_accept"):
			if !System.cutscene:
				var collider = $Interact.get_collider()
				if collider != null:
					print("Trying to interact with " + String(collider.name))
					if collider.has_method("interact"):
						System.interacting_object = collider
						collider.interact()
			


func _on_Area2D_area_entered(area):
	if next != null:
		if area == next:
			prevpositions = []
			prevanimations = []


func _on_Area2D_area_exited(area):
	if next != null:
		if area == next:
			prevpositions = []
			prevanimations = []
		


func _on_StairCheck_area_entered(area):
	if area.is_in_group("stair"):
		instairs += 1
		
		if instairs > 0:
			speed = MAX_SPEED/1.5


func _on_StairCheck_area_exited(area):
	if area.is_in_group("stair"):
		instairs -= 1
		
		if instairs <= 0:
			speed = MAX_SPEED
			


func _on_prev_pos_timer_timeout():
	if moving and !System.cutscene and !BattleSystem.battling:
		if !prevpositions.is_empty() and prevpositions.back() != null:
			if abs(round(position.x)-prevpositions.back().x) > 5 or abs(round(position.y)-prevpositions.back().y) > 5:
				prevpositions.append(round(position))
				prevanimations.append($Sprite.animation)
		else:
			prevpositions.append(round(position))
			prevanimations.append($Sprite.animation)


func set_dir(new_dir = dirs.UP):
	if new_dir == dirs.UP:
		$Sprite.animation = "up"
	elif new_dir == dirs.DOWN:
		$Sprite.animation = "down"
	elif new_dir == dirs.LEFT:
		$Sprite.animation = "left"
	elif new_dir == dirs.RIGHT:
		$Sprite.animation = "right"
	elif new_dir == dirs.UP_LEFT:
		$Sprite.animation = "up_left"
	elif new_dir == dirs.DOWN_LEFT:
		$Sprite.animation = "down_left"
	elif new_dir == dirs.UP_RIGHT:
		$Sprite.animation = "up_right"
	elif new_dir == dirs.DOWN_RIGHT:
		$Sprite.animation = "down_right"


func _on_sprite_frame_changed():
	if "_walk" in $Sprite.animation:
		if $Sprite.frame == 2:
			footstep(0.9)
		elif $Sprite.frame == 6:
			footstep(1.1)


func footstep(pitch=1.0):
		$Footstep.pitch_scale = pitch
		
		match owner.get_material_at_tile(Vector2i(round(position.x/16),round(position.y/16))):
			"Wood":
				$Footstep.stream = woodsound
				$Footstep.play()
			"Stone":
				$Footstep.stream = stonesound
				$Footstep.play()
			_:
				pass
				
				
func move_cutscene(to_x = 0, to_y = 0, move_speed = speed, relative = true):
	var tween = create_tween()
	if relative:
		tween.tween_property(self, "position", position + Vector2(to_x, to_y), move_speed)
	else:
		if to_x == 0:
			tween.tween_property(self, "position", Vector2(position.x, to_y), move_speed)
		elif to_y == 0:
			tween.tween_property(self, "position", Vector2(to_x, position.y), move_speed)
		else:
			tween.tween_property(self, "position", Vector2(to_x, to_y), move_speed)
			
			
func set_anim(anim_name):
	anim_set_manually = true
	$Sprite.animation = anim_name
	$Sprite.play()
