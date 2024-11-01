extends Node


var pressed = false
var canpress = false


signal time_finished(good)


var time = 3

# Called when the node enters the scene tree for the first time.
func start():
	$Timer.start(time)
	$WindupTimer.start(0.1)
	await $WindupTimer.timeout
	await get_tree().create_timer(0.05)
	pressed = false
	canpress = true

func set_time(window):
	time = window

func _input(_event):
	if Input.is_action_just_pressed("ui_accept") and !pressed and canpress:
		print("Presse")
		pressed = true
		emit_signal("time_finished",$Timer.time_left)
		

func _on_Timer_timeout():
	emit_signal("time_finished",$Timer.time_left)
