extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


func initialize():
	$AnimationPlayer.play("idle")
	$ArmAnim.play("idle")
	
	
func on_hit():
	if $AnimationPlayer.is_playing():
		await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("idle")
	$ArmAnim.play("idle")


func attack():
	get_tree().call_group("grid_piece","show_r_guides")
	var shots = 0
	var initial_position = position
	$ArmAnim.play("ShootPrep")
	await $ArmAnim.animation_finished
	while shots < 16:
		shots += 1
		var shoot_at = gridref.get_grid_position(0,gridref.get_random_grid().y).y
		await create_tween().tween_property(self,"position",Vector2(position.x,shoot_at),0.5).finished
		
		$ArmAnim.play("Shoot",-1,1.8)
		var new_projectile = load("res://Objects/Battle/Projectiles/Egg.tscn").instantiate()
		new_projectile.set_speed(more.choose([2,4,6,8]))
		new_projectile.position = position
		get_parent().add_child(new_projectile)
		
	create_tween().tween_property(self, "position", initial_position, 0.3)
	await $ArmAnim.animation_finished
	$ArmAnim.play("idle")
	await get_tree().create_timer(0.5).timeout
	emit_signal("done_attacking")
