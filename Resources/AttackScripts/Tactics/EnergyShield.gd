extends Node

signal attack_finished

func execute(_caller, _victim, user):
	await get_tree().create_timer(0.1).timeout
	user.energy_shield = true
	emit_signal("attack_finished")
