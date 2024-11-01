extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func initialize():
	$BatAnim.play("flap")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func on_hit():
	$BatAnim.stop()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "shake" and hp > 0:
		$BatAnim.play("flap")
		$Sprite.animation = "idle"


func attack():
	#await get_tree().create_timer(0.3*enemy_number).timeout
	
	#Get in position to swoop
	var initial_pos = global_position
	var initial_sprite_pos = $Sprite.position
	var attack_grid = gridref.get_random_grid()
	$Flap.playing = true
	gridref.warn_squares([attack_grid], 2)
	var tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(gridref.get_grid_position(attack_grid) + gridref.get_grid_topleft_position() + Vector2i(gridref.gridpiecesize.x,-gridref.gridpiecesize.y/2)), 1.5)
	await tween.finished
	
	#Swoop, then fly offscreen
	await get_tree().create_timer(0.3).timeout
	$BatAnim.play("Swoop")
	var tween2 = create_tween()
	tween2.tween_property(self, "global_position", Vector2(global_position.x-75, global_position.y), 1)
	tween2.tween_property(self, "global_position", Vector2(-50, global_position.y), 1.25)
	await tween2.finished
	
	#Return to original position
	global_position = initial_pos + Vector2(300, 0)
	global_position.x = 500
	$Sprite.position = initial_sprite_pos
	$Flap.playing = true
	var tween3 = create_tween()
	tween3.tween_property(self, "global_position", initial_pos, 0.3)
	await tween3.finished
	$BatAnim.play("flap")
	
	
	emit_signal("done_attacking")
