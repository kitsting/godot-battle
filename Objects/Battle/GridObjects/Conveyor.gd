extends AnimatedSprite2D

var grid_position = Vector2(0,0)
var direction_to = Vector2(1,0)


func _ready():
	play()
	$AnimationPlayer.play("flash")
	
	
	
func set_direction(direction):
	direction_to = direction
	
	if direction == Vector2(1,0):
		animation = "Left"
		$Warning.flip_h = false
		$Warning.texture = load("res://Graphics/Battle/Grid/ConveyorWarningH.png")
	elif direction == Vector2(-1,0):
		animation = "Right"
		$Warning.flip_h = true
		$Warning.texture = load("res://Graphics/Battle/Grid/ConveyorWarningH.png")
	elif direction == Vector2(0,1):
		animation = "Down"
		$Warning.flip_v = true
		$Warning.texture = load("res://Graphics/Battle/Grid/ConveyorWarningV.png")
	else:
		animation = "Up"
		$Warning.flip_v = false
		$Warning.texture = load("res://Graphics/Battle/Grid/ConveyorWarningV.png")


func get_direction():
	return direction_to
