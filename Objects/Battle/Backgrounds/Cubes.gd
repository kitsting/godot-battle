extends Control


var row_to_teleport = 1
var distance_moved = 0
var cube_size = 42


func _ready():
	_on_h_timer_timeout()
	for row in $Textures.get_children():
		for cube in row.get_children():
			cube.modulate.s = 0.75
			cube.modulate.v = 0.2
			cube.modulate.h = randf_range(0.0,1.0)
			
			
func _process(delta):
	var move = 0.25 * 60 * delta
	for row in $Textures.get_children():
		row.position.y -= move
	distance_moved += move
	if distance_moved >= cube_size:
		distance_moved = 0
		get_node("Textures/Row"+str(row_to_teleport)).position.y = 336
		get_node("Textures/Row"+str(row_to_teleport)).z_index += row_to_teleport
		row_to_teleport += 1
		if row_to_teleport > 9:
			row_to_teleport = 1
			for row in $Textures.get_children():
				row.z_index = 0


func _on_shift_timer_timeout():
	for row in $Textures.get_children():
		for cube in row.get_children():
			var shift = randi_range(0,2)
			if shift == 0:
				create_tween().tween_property(cube, "position:y", randi_range(-2,2)*10,0.3).set_ease(Tween.EASE_IN)
				


func _on_h_timer_timeout():
	var tween = create_tween()
	tween.tween_property($Textures, "position:x", -20, 5).set_ease(Tween.EASE_IN)
	tween.tween_property($Textures, "position:x", 20, 5).set_ease(Tween.EASE_IN)
