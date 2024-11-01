extends Node2D

var power = 15


func _ready():
	yield(get_tree().create_timer(0.7),"timeout")
	
	$AnimatedSprite.visible = false
	$CollisionShape2D.disabled = false
	$AnimatedSprite2.playing = true
	
	yield(get_tree().create_timer(0.7),"timeout")
	
	queue_free()
