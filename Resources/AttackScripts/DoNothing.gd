extends Node

signal attack_finished

func execute(_caller, _victim, _user):
	await get_tree().create_timer(0.75).timeout
	emit_signal("attack_finished")
