extends Node


export var power = 15;


func queue_free():
	get_parent().get_parent().get_parent().track_ball = null
	get_parent().queue_free()
	

func aiming_for():
	return get_parent().get_parent().get_parent().track_pos
