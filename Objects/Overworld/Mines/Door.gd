extends Node2D


func activate():
	$DoorL.visible = false
	$DoorR.visible = false
	$Collision/CollisionShape2D.disabled = true
	
