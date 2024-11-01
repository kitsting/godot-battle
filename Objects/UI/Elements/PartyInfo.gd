extends NinePatchRect


@export_file("*.png") var icon = "res://Graphics/UI/Icons/Party/23Icon.png"
@export var party_name = "You"
@export var weapon = "Staff"
@export var likes = "Existing"


# Called when the node enters the scene tree for the first time.
func _ready():
	if icon != null:
		$Margin/VBox/Name/TextureRect.texture = load(icon)
		
	$Margin/VBox/Name/Label.text = party_name
	$Margin/VBox/Weapon/WeaponLabel.text = weapon
	$Margin/VBox/Likes/LikesLabel.text = likes
		
	
func set_name(text):
	$Margin/VBox/Name/Label.text = text

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
