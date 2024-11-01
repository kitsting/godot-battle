extends Resource
class_name Badge


@export var badge_name = "Badge"
@export var readable_name = "Default Pin"
@export_multiline var badge_desc = "You shouldn't have this"

@export var badge_sprite : Texture = load("res://Graphics/Badges/APMoveDown.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
