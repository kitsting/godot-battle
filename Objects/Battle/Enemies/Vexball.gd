extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


enum ATTACK_TYPES {
	ROLL_SLOW,
	ROLL_FAST
}

var touched_grid_square = false
	
	
func _on_AnimationPlayer_animation_finished(anim_name):
	pass


func attack():
	var initial_position = position
	touched_grid_square = false
	$Sprite.animation = "attack"
	
	#Solo attack
	if alone:
		$AnimationPlayer.play("rev_slow")
		await $AnimationPlayer.animation_finished
		$Rev.playing = true
		$AnimationPlayer.play("roll", -1, 1.15)
		await $AnimationPlayer.animation_finished
		#Code for tracking the player is in _process()
	
	#Group attack
	elif !alone:
		#Change row occasionally
		var target_square = null
		var changerow = randi_range(1,3)
		if changerow == 1:
			target_square = gridref.get_grid_position(Vector2i(0,gridref.get_random_grid().y))
			print(target_square)
			create_tween().tween_property(self, "position:y", target_square.y, 0.5)
		
		#Choose an attack and go through with it
		var attack_type = randi() % ATTACK_TYPES.size()
		#Slow roll
		if attack_type == ATTACK_TYPES.ROLL_SLOW:
			$AnimationPlayer.play("rev_slow")
			await $AnimationPlayer.animation_finished
			$Rev.playing = true
			$AnimationPlayer.play("roll", -1, 1.3)
			await $AnimationPlayer.animation_finished
		#Fast roll
		elif attack_type == ATTACK_TYPES.ROLL_FAST:
			$AnimationPlayer.play("rev_fast")
			await $AnimationPlayer.animation_finished
			$FastRev.playing = true
			$AnimationPlayer.play("roll", -1, 2)
			await $AnimationPlayer.animation_finished
			
	#Return to initial position
	position.y = initial_position.y
	$AnimationPlayer.play("return", -1, 2)
	await $AnimationPlayer.animation_finished
	attacking = false
	$Sprite.animation = "idle"
	emit_signal("done_attacking")
			
			
func die():
	if $AnimationPlayer.is_playing():
		await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("run")
	await $AnimationPlayer.animation_finished
	queue_free()


func _on_IdleTimer_timeout():
	if !BattleSystem.enemyturn and hp > 0:
		$AnimationPlayer.play("idle")
	$IdleTimer.start(randf_range(3,8))
	
func initialize():
	$IdleTimer.start(randf_range(3,8))
	
	
func _process(delta):
	super._process(delta)
	
	if alone and $AnimationPlayer.current_animation == "roll" and !touched_grid_square:
		var target_square = gridref.get_grid_position(Vector2i(0, gridref.get_targeted_player_position().y))
		create_tween().tween_property(self, "position:y", target_square.y, 0.25)


func _on_grid_checker_area_entered(area):
	if area.is_in_group("grid_piece_collision"):
		touched_grid_square = true
