extends Control


@export_enum("Pin", "Item", "Nothing") var type = "Item"
@export var item_name : String = "Bread"
@export var cost = 10
@export var unlimited = false

var canbuy = true


# Called when the node enters the scene tree for the first time.
func _ready():	
	if type == "Item":
		$Item/Texture.texture = load_item().texture
	elif type == "Pin":
		$Item/Texture.texture = load_item().badge_sprite
	$Item/Border.visible = false
	$Price/Label.text = "x" + str(cost)
	
	if type == "Pin":
		unlimited = false
		
		if PartyStats.badge_in_inventory(item_name):
			canbuy = false
			$Item/Texture.texture = load("res://Graphics/UI/Items/ItemGone.png")
	
	if type == "Nothing":
		queue_free()
	

func on_buy():
	if type == "Pin":
		canbuy = false
		$Item/Texture.texture = load("res://Graphics/UI/Items/ItemGone.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ShopItem_focus_entered():
	SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-6)
	$AnimationPlayer.play("selected")


func _on_ShopItem_focus_exited():
	$AnimationPlayer.play("unselected")


func load_item():
	if type == "Item":
		return load("res://Resources/Items/" + item_name + ".tres")
	elif type == "Pin":
		return load("res://Resources/Badges/" + item_name + ".tres")
		
		
func get_itemname():
	if type == "Item":
		return load_item().attackname
	elif type == "Pin":
		return load_item().readable_name
		
func get_filename():
	return item_name
		
		
func get_desc():
	if type == "Item":
		return load_item().desc
	elif type == "Pin":
		return load_item().badge_desc
