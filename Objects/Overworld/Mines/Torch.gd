extends Node2D

func _ready():
	$Sprite.play()
	$Sprite.frame += randi_range(0,2)
	$Sprite.speed_scale = randf_range(0.8,1.2)
