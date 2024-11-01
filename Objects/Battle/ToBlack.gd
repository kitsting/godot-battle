extends CanvasLayer

signal midpoint
signal done

var speed = 1


func _ready():
	$AnimationPlayer.play("FadeIn",-1,speed)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeIn":
		emit_signal("midpoint")
		$AnimationPlayer.play("FadeOut",-1,speed)
	elif anim_name == "FadeOut":
		emit_signal("done")
		queue_free()


func set_speed(new_speed):
	speed = new_speed
