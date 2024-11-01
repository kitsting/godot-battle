extends Sprite2D

var grid_position = Vector2(0,0)

func break_web():
	get_tree().call_group("battle_grid","set_grid",grid_position.x, grid_position.y, "empty")
	queue_free()
