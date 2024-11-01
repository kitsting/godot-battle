extends Control


var skipanim = true


# Called when the node enters the scene tree for the first time.
func _ready():
	BattleSystem.connect("side_change",change_sides)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$BG/Tracks.position.x -= 4 * delta * 60
	if $BG/Tracks.position.x < -$BG/Tracks/Track1.texture.get_width():
		$BG/Tracks.position.x = -4 * delta * 60
		
	$BG/BG1.position.x -= 2 * delta * 60
	if $BG/BG1.position.x < -$BG/BG1.texture.get_width():
		$BG/BG1.position.x = -2 * delta * 60
		
	$BG/BG2.position.x -= 2.15 * delta * 60
	if $BG/BG2.position.x < -$BG/BG2.texture.get_width():
		$BG/BG2.position.x = -2.15 * delta * 60
		
	$BG/BG3.position.x -= 2.3 * delta * 60
	if $BG/BG3.position.x < -$BG/BG3.texture.get_width():
		$BG/BG3.position.x = -2.3 * delta * 60

func change_sides(enemyturn):
	await get_tree().create_timer(0.05).timeout
	if !skipanim:
		if !enemyturn:
			create_tween().tween_property($BG, "position", $BG.position-Vector2(0,32),0.2)
			
		if enemyturn:
			if BattleSystem.dialogue_queued:
				await TextSystem.text_finished
			create_tween().tween_property($BG, "position", $BG.position+Vector2(0,32),0.2)
	else:
		skipanim = false
