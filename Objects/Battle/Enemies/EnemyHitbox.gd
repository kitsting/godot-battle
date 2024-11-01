extends Node


@export var damage = 10;


func set_disabled(disable = true):
	$CollisionShape2D.disabled = disable
