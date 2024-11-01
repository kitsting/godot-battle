extends Node

signal attack_finished

func execute(caller, victim, user):
	var damage_modifier = 1
	
	if caller.timing != 0:
		user.single_anim("windup")
		var timed_press = load("res://Objects/TimedPress.tscn").instantiate()
		user.canready = true
		timed_press.set_time(caller.timing)
		get_tree().get_root().add_child(timed_press)
		timed_press.start()
		user.get_ready(caller.timing)
		var timing = await timed_press.time_finished
		user.canready = false
		user.reset_anim_player()
		
		var good_timing = true
		if timing == 0:
			good_timing = false

		if !good_timing:
			user.show_timing_bad()
			user.single_anim("attack_bad")
			damage_modifier = 0.5
		else:
			var ratio = (caller.timing-timing)/float(caller.timing)
			var type = "OK"
			if ratio > 0.50:
				type = "Good"
			if ratio > 0.70:
				type = "Great"
			if ratio > 0.90:
				type = "Superb"
			
			user.show_timing_good(type)
			user.single_anim("attack_good")
			damage_modifier = 0.75 + (ratio/1.2)
		
	for enemy in victim:
		enemy.take_damage(ceil(float(caller.damage) * damage_modifier * user.attackpower))
	await get_tree().create_timer(0.75).timeout
	emit_signal("attack_finished")
