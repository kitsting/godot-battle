extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


var is_exhausted = false
var make_new_enemies = false
var phase2 = false


func initialize():
	max_hp = hp

func attack():
	if is_exhausted:
		if hp <= (max_hp/2) and !phase2:
			phase2 = true
			set_exhausted(false)
	else:
		if get_parent().get_parent().get_not_dead_enemies("chess").size() < 1:
			set_exhausted(true)
		
	await get_tree().create_timer(0.5).timeout
	if make_new_enemies:
		for _i in range(0,4+(2*int(is_advanced))):
			if gridref.can_add_enemy():
				print("making enemy #"+str(_i))
				if is_advanced:
					gridref.add_enemy("bosses/chess/ChessPiece", true)
				else:
					gridref.add_enemy("bosses/chess/ChessPiece", false)
				await get_tree().create_timer(0.15).timeout
		make_new_enemies = false
		await get_tree().create_timer(0.35).timeout
		
	emit_signal("done_attacking")


func set_exhausted(exhausted):
	if exhausted:
		$AnimationPlayer.play("exhausted")
		$Exhausted.play()
		defense = 0
		enemydesc = "Weak without the support of its army. Now's your chance to attack!"
		await $AnimationPlayer.animation_finished
		$Sprite.animation = "Exhausted"
		$ExhaustSprite.visible = false
	else:
		$AnimationPlayer.play("reborn")
		$Sprite.animation = "Active"
		defense = 1
		enemydesc = "It looks terrified for a moment, but soon realizes it's safe. Not to be confused with the real king."
		make_new_enemies = true
				
	await get_tree().create_timer(0.1).timeout
	is_exhausted = exhausted


func on_check():
	if is_exhausted:
		take_damage(20)
