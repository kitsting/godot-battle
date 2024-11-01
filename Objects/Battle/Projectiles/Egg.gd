extends Area2D


var power = 25
var speed = 5


func set_speed(new_speed):
	speed = new_speed


func _process(delta):
	position.x -= delta * 60 * speed
