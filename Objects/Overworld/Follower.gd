extends Node2D


var follow = true
var follow_object = null
var next = null

var target = 0
var party_number = 1

var prevposition = Vector2.ZERO
var moving = false

var prevpositions = []
var prevanimations = []

var speed = 80
var velocity = Vector2.ZERO

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
var currentdir = dirs.UP


func _ready():
	show_behind_parent = true
	position = round(position)
	set_dir(currentdir)
	$Sprite.play()
	
	
func set_member_name(member_name):
	add_to_group(PartyStats.load_party_name(member_name).name)
	$Sprite.frames = PartyStats.load_party_name(member_name).get_overworld_costume()


func set_to_follow(follow_this : Node2D):
	follow = true
	follow_object = follow_this
	follow_object.next = self
	
	
func stop_following():
	follow = false
	if next != null:
		next.follow_object = follow_object
	if follow_object != null:
		follow_object.next = next
		follow_object = null
	
	
func can_follow(follow_possible):
	follow = follow_possible
	
	
	
func _physics_process(delta):
	prevposition = position
	if follow_object != null and follow:
		if abs(position.x - follow_object.position.x) > 20 or abs(position.y - follow_object.position.y) > 20:
			show_behind_parent = false
			#velocity = Vector2.ZERO
			if "prevpositions" in follow_object:
				if follow_object.prevpositions.size() > target:
					velocity = position.direction_to(follow_object.prevpositions[target]-Vector2(0,1)) * speed * delta
					position += velocity
					if $Sprite.animation != follow_object.prevanimations[target]:
						$Sprite.animation = follow_object.prevanimations[target]
					
#					position.x = roundi(position.x)
#					position.y = roundi(position.y)
					
					if abs(position.x - follow_object.prevpositions[target].x) < 5 and abs(position.y - follow_object.prevpositions[target].y) < 5:
						target += 1
						prevpositions.append(round(position))
						prevanimations.append($Sprite.animation)
				else:
					target = 0
					
	
		#Stop walking animation
		if prevposition == position:
			if String($Sprite.animation).contains("walk"):
				$Sprite.animation = String($Sprite.animation).trim_suffix("_walk")


func emote(emotion):
	match emotion:
		"exclamation":
			$Emotion.visible = true
			SoundSystem.play_sound("res://Sounds/Select.wav", "ui_misc", -6)
			await get_tree().create_timer(0.8).timeout
			$Emotion.visible = false
		_:
			pass


func _on_Area2D_area_entered(area):
	if next != null:
		if area == next:
			prevpositions = []
			prevanimations = []
		

func set_dir(new_dir = dirs.UP):
	currentdir = new_dir
	
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
		
		
		

func set_anim(anim_name):
	$Sprite.animation = anim_name
	$Sprite.play()
	
	
func move(to_x = 0, to_y = 0, move_speed = speed, relative = true):
	print("move called")
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
	
	
