extends AnimatedSprite2D

var grid_position = Vector2(0,0)


func _ready():
	play()

func melt():
	$AnimationPlayer.play("melt")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "melt":
		get_tree().call_group("battle_grid","set_grid",grid_position.x, grid_position.y, "empty")
		queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("ice"):
		melt()
