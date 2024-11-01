extends Control


func _ready():
	if System.options["background_mode"] < 1:
		$Particles.emitting = false
		$Foreground/Particles2.emitting = false
		
	if System.options["background_mode"] == 0:
		$ColorRect.color.a += 0.3
