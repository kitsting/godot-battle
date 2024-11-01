extends Area2D

#Export Variables
export(Texture) var sprite = preload("res://Graphics/Overworld/NPCs/SnowResidentAnim.tres")
export(String, FILE, ".tres") var dialogue
export(String) var record_name


#Other Variables
var talking = false


#Initialize variables and methods
func _ready():
	if System.deletenpcs:
		queue_free()
	
	$Sprite.texture = sprite
	TextSystem.connect("text_done_rendering", self, "text_done")


func interact():
	var cutscene = load("res://Objects/Cutscene.tscn").instance()
	cutscene.connect("self_talk", self, "set_talking")
	get_tree().get_root().add_child(cutscene)
	cutscene.start(dialogue, record_name)
	


#Control the talking animation if one is set
func set_talking(is_talking):
	talking = is_talking
	
	if $Sprite.texture is AnimatedTexture:
		if talking == true:
			$Sprite.texture.pause = false
			$Sprite.texture.current_frame = 0
		else:
			$Sprite.texture.pause = true
			$Sprite.texture.current_frame = 0


#Stop the talking animation when the textbox finishes showing text
func text_done():
	set_talking(false)



