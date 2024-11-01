extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"

signal path_end

var ready_to_shoot = false
var ball_out = false
var track_ball = null
var track_pos = null

var ball = preload("res://Objects/Battle/Enemies/shooter/IceBall.tscn")


func initialize():
	position.y += 8
	
	
	
func attack():
	var pos = get_parent().get_parent().get_random_grid("empty")
	track_pos = pos
#
#	$Path2D.curve.clear_points()
#	$Path2D.curve.add_point(position)
	$Path2D.curve.set_point_position(2, get_parent().get_parent().get_grid_position(pos.x,pos.y) - global_position  + get_parent().get_parent().get_grid_topleft_position())
	$Path2D.curve.set_point_position(1, ((get_parent().get_parent().get_grid_position(pos.x,pos.y) - global_position  + get_parent().get_parent().get_grid_topleft_position())/2) + Vector2(0,-100))
	$Path2D/PathFollow2D.offset += 1
	
	ready_to_shoot = true
	
	yield(self,"path_end")
	
	gridref.add_object(pos.x,pos.y,gridref.obj_ice)
	
	emit_signal("done_attacking")


func idle(delta):
	if attacking and ready_to_shoot:
		if track_ball == null:
			var new_ball = ball.instance()
			$Path2D.add_child(new_ball)
			track_ball = new_ball
		
		if track_ball != null:
			track_ball.offset += 375 * delta
			if track_ball.position == $Path2D.curve.get_point_position(2):
				ready_to_shoot = false
				track_ball.queue_free()
				track_ball = null
				emit_signal("path_end")
