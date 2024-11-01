extends Node

signal attack_finished

func execute(caller, victim, _user):
	await victim.item_animation(caller.get_mini_texture())
	
	BattleSystem.change_ap(caller.heals_ap)
	
	if caller.get_affects() == "player":
		if caller.heals_hp != 0:
			victim.heal(caller.heals_hp)
	
	await get_tree().create_timer(1).timeout
	emit_signal("attack_finished")
