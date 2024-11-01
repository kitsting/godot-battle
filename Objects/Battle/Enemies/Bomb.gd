extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"

var turns = 3


# Called when the node enters the scene tree for the first time.
# Use this instead of _ready()
func intiialize():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	
	#Process code here
	if metadata_int > 8:
		$Sprite.animation = "fuse8"
	elif metadata_int > 0:
		$Sprite.animation = "fuse"+str(metadata_int)


#Called when the enemy attacks
func attack():
	#Freak out
	$Sprite.speed_scale = 5
	await get_tree().create_timer(0.65).timeout
	
	#Tick down
	metadata_int -= 1
	
	if metadata_int > 0: #Count down and resume as normal
		$Tick.pitch_scale = 1
		if metadata_int <= 3:
			$Tick.pitch_scale = 1.5
		if metadata_int <= 1:
			$Tick.pitch_scale = 2
		$Tick.play()
		
		#Return to normal
		$Sprite.speed_scale = 1
		if metadata_int <= 3:
			$Sprite.speed_scale = 2
		if metadata_int <= 1:
			$Sprite.speed_scale = 3
		
		await get_tree().create_timer(0.15).timeout
		
		emit_signal("done_attacking")
		
	else: #Explode!
		$ExplosionLayer.visible = true
		for player in gridref.get_players():
			player.take_damage(9999, "explosion")
		create_tween().tween_property($ExplosionLayer/ColorRect, "color:a", 0, 2)
		$Sprite.visible = false
	
	
#Called on hit
func on_hit():
	pass
	

#Custom entry animation
func entry():
	pass


#Called when health reaches 0
func die():
	queue_free()
