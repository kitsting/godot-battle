extends Resource
class_name Item


#Basic info
@export var attackname = "Standard"
@export var attackid = "Item"
@export_multiline var desc = "Standard Item"
@export_multiline var extended_desc = ""

@export var texture : Texture
@export var mini_texture : Texture = preload("res://Graphics/Battle/MiniItem/Unknown.png")

@export var cost = 0
@export var heals_hp = 10
@export var heals_ap = 10

@export_enum("none", "enemy", "grid", "all_enemies", "player") var affects = 0

#This is the actual attack, in the form of the script that runs
#See the preloaded script for an example of what an attack should look like
@export var custom_script = false
@export var usescript : Script = preload("res://Resources/ItemScripts/BasicItem.gd")

@export var requires1 = false
@export var requires2 = false


func execute(user, target):
	BattleSystem.change_ap(heals_ap)
	
	if get_affects() == "player":
		target.heal(heals_hp)
		

func get_script():
	if custom_script:
		return usescript
	return preload("res://Resources/ItemScripts/BasicItem.gd")

		
func get_affects():
	match affects:
		0:
			return "none"
		1:
			return "enemy"
		2:
			return "grid"
		3:
			return "all_enemies"
		4:
			return "player"


func get_mini_texture():
	if mini_texture != null:
		return mini_texture
	return load("res://Graphics/MiniItem/Unknown.png")
