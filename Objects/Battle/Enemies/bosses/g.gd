extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"

var fivemode = false

var spawning = false
var spawnedbullets = 0

var bullet_scene = preload("res://Objects/Battle/Projectiles/Bullet.tscn")


func attack():
	
	var useattack = randi_range(0,2) #0 = pound, else bullets
	
	if useattack == 0:
		await get_tree().create_timer(1).timeout
		
	else:
		get_tree().call_group("grid_piece","show_r_guides")
		var bulletsperspawn = 1
		if spawnedbullets > 40:
			bulletsperspawn = randi_range(1,2)
		
		for bat in 7+(spawnedbullets*0.05):
			$Flap.play()
			for spawn in bulletsperspawn:
				spawnedbullets += 1
				var new_bullet = bullet_scene.instantiate()
				new_bullet.position.x = 420
				new_bullet.position.y += (23*gridref.get_random_grid().y)
					
				get_parent().add_child(new_bullet)
			
			await get_tree().create_timer(max(0.8 - (spawnedbullets * 0.02),0.5+(0.3*(bulletsperspawn-1)))).timeout
			
		await get_tree().create_timer(4).timeout
	
	
	emit_signal("done_attacking")
	
	
