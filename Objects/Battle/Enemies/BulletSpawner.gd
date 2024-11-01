extends Node2D

var fivemode = false

var spawning = false
var spawnedbullets = 0
var number_to_spawn = 1

var bullet_scene = preload("res://Objects/Battle/Projectiles/Bullet.tscn")

signal done_spawning


func spawn(time):
	if spawnedbullets > 35 and number_to_spawn == 1:
		spawnedbullets = 0
		number_to_spawn = 2
	
	$Timer2.start(time)
	spawning = true
	$Timer.start(0.5)


func _on_Timer_timeout():
	if spawning:
		for spawn in number_to_spawn:
			spawn_bullet()
		
		$Timer.set_wait_time(max(0.75 - (spawnedbullets * 0.02),0.4+(0.3*(number_to_spawn-1))))
		
		if has_node("CanvasLayer/Label"):
			get_node("CanvasLayer/Label").text = "Spawned: " + str(spawnedbullets)


func _on_Timer2_timeout():
	spawning = false
	$Timer.stop()
	emit_signal("done_spawning")
	
	
func spawn_bullet():
	var pos = 0
	if fivemode:
		pos = (randi() % 5)-2
	else:
		pos = (randi() % 3)-1
		
	var new_bullet = bullet_scene.instantiate()
	new_bullet.position.x = 0
	new_bullet.position.y = 0

	new_bullet.position += Vector2(0,23*pos)
		
	add_child(new_bullet)
	
	spawnedbullets += 1
