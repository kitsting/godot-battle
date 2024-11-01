extends CanvasLayer


func set_position(pos = Vector2(0,0)):
	offset = pos


func set_damage(damage):
	if damage is String:
		$Label.text = damage
	else:
		$Label.text = "-" + str(damage)
	
	
func _ready():
	$AnimationPlayer.play("damage_display",-1,1.5)


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
