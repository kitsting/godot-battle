extends Control


func _ready():
	if System.options["background_mode"] != 0:
		$Particles2D.emitting = true
		
	if System.options["background_mode"] == 1:
		$Particles2D.amount = 25
		$Particles2D.speed_scale = 0.5

func _process(delta):
	$ColorRect.color.h += 0.001 * delta * 60
