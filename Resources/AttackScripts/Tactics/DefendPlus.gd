extends Node

signal attack_finished

func execute(_caller, _victim, _user):
	await get_tree().create_timer(0.1).timeout
	PartyStats.boost_defense(6)
	emit_signal("attack_finished")
