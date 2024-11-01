extends "res://Objects/Overworld/Interactable.gd"


@export var item = "Bread"
@export var chestid = "1"

var opened = false
var already_opened = false

@export var contents = "item"

# Called when the node enters the scene tree for the first time.
func _ready():
	if chestid in System.registry_lookup("seen_cutscenes"):
		already_opened = true
		open()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func open():
	if !opened:
		opened = true
		$Sprite.texture = load("res://Graphics/Overworld/Misc/ChestOpen.png")
		
		if !already_opened:
			System.registry_append("seen_cutscenes", chestid)
			$OpenSound.play()
