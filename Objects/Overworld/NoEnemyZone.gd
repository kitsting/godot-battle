@tool
extends StaticBody2D

@export var size = Vector2(16, 16):
	set(new_size):
		$CollisionShape2D.shape.extents.x = new_size.x/2
		$CollisionShape2D.shape.extents.y = new_size.y/2
		
		size = new_size
	get:
		return size
