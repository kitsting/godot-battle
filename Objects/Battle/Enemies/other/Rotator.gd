extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


func initialize():
	$AnimationPlayer.play("idle")
	$Rotation.play("Rotate1")
