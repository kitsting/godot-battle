extends Node

signal attack_finished

func execute(caller, victim, _user):
	await victim.item_animation(caller.get_mini_texture())
	victim.tick_cooldown(15)
	
	await get_tree().create_timer(1).timeout
	emit_signal("attack_finished")
