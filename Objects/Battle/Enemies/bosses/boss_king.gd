extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"

var bone = preload("res://Objects/Battle/Projectiles/Bone.tscn")

func attack():
	### GRID
	### 0,0  0,1  0,2
	### 1,0  1,1  1,2
	### 2,0  2,1  2,2
	gridref.add_object(0,2,bone)
	gridref.add_object(1,2,bone)
	gridref.add_object(2,2,bone)
	
	await get_tree().create_timer(1.2).timeout
	
	gridref.add_object(0,1,bone)
	gridref.add_object(1,1,bone)
	gridref.add_object(2,1,bone)
	
	await get_tree().create_timer(1.2).timeout
	
	gridref.add_object(0,0,bone)
	gridref.add_object(1,0,bone)
	gridref.add_object(2,0,bone)
	
	await get_tree().create_timer(3).timeout
#	if BattleSystem.dialogue:
#			yield(TextSystem,"text_finished")
#	$BulletSpawner.spawn(7+($BulletSpawner.spawnedbullets*0.05))
#	yield($BulletSpawner,"done_spawning")
	emit_signal("done_attacking")

func on_hit():
	var pos = gridref.get_random_grid()
	
	gridref.add_object(pos.x,pos.y,bone)
