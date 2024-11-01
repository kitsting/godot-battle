extends Node2D


signal anim_done


func _ready():
	await get_tree().create_timer(0.4).timeout
	$UseAnim.visible = true
	$Sprite.visible = false
	$UseAnim.play()
	await $UseAnim.animation_finished
	emit_signal("anim_done")
	queue_free()


func set_texture(texture):
	$Sprite.texture = texture
