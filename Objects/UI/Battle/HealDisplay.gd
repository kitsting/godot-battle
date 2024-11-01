extends CanvasLayer


func set_position(pos = Vector2(0,0)):
	offset = pos


func set_amount(amount):
	if amount is String:
		$Label.text = amount
	else:
		$Label.text = "+" + str(amount)
	
	
func _ready():
	$AnimationPlayer.play("heal_display",-1,1.5)


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
