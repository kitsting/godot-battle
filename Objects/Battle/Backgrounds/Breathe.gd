extends Control

var currentseed = 0


func _ready():
	randomize()
	$TextureRect.texture.noise.seed = randi()
	currentseed = $TextureRect.texture.noise.seed

		

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Breathe":
		change()
	if anim_name == "Fade":
		$TextureRect.texture.noise.seed = currentseed
		$AnimationPlayer.play("Unfade")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("Breathe", -1, 0.15 * System.options["background_mode"])

func change():
	$TextureRect2.texture.noise.persistence = $TextureRect.texture.noise.persistence
	$TextureRect2.texture.noise.period = $TextureRect.texture.noise.period	
	$TextureRect2.texture.noise.seed = randi()
	currentseed = $TextureRect2.texture.noise.seed
	$AnimationPlayer.play("Fade",-1,0.15 * System.options["background_mode"])
