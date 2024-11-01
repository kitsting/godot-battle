extends Control


var skipanim = true


# Called when the node enters the scene tree for the first time.
func _ready():
	BattleSystem.connect("side_change",change_sides)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$BG/Road.position.x -= 8 * delta * 60
	if $BG/Road.position.x < -$BG/Road.texture.get_width():
		$BG/Road.position.x = 0

func change_sides(enemyturn):
	if !skipanim:
		if !enemyturn:
			create_tween().tween_property($BG, "position", $BG.position - Vector2(0,32), 0.2)
			
		if enemyturn:
			if BattleSystem.dialogue_queued:
				await TextSystem.text_finished
			create_tween().tween_property($BG, "position", $BG.position + Vector2(0,32), 0.2)
	else:
		skipanim = false
