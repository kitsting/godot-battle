extends Area2D

var power = 10
var move = true



func _ready():
	$Flap.play("flap")

func _process(delta):
	if move:
		position.x -= 2 * delta * 60
