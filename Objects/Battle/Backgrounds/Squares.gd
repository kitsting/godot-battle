extends Control


func _ready():
	if System.options["background_mode"] < 1:
		$Background.visible = false
