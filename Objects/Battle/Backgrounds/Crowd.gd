extends Sprite2D


func _ready():
	texture.speed_scale = 6 * System.options["background_mode"]
