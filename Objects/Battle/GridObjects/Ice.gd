extends Sprite2D

var grid_position = Vector2(0,0)


func _ready():
	self_modulate = Color(1,1,1,0)
	$AnimatedSprite.play("appear")


func melt():
	$AnimationPlayer.play("melt")
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "melt":
		get_tree().call_group("battle_grid","set_grid",grid_position.x, grid_position.y, "empty")
		queue_free()


func _on_Area2D_area_entered(area):
	if area.is_in_group("fire") and !$AnimationPlayer.is_playing():
		melt()


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "appear":
		self_modulate = Color(1,1,1,1)
		$AnimatedSprite.play("go away")
