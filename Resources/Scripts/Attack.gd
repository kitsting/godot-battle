extends Resource
class_name Attack


#Basic info
@export var attackname = "Standard"
@export_multiline var desc = "Standard Attack"
@export_multiline var extended_desc = ""

@export var cost = 10
@export var damage = 1.0 #Multiplies by the users attack stat
@export var cooldown = 0
@export var ap_penalty = 0

#More specific info
@export_enum("none", "enemy", "grid", "all_enemies", "player") var affects = 0
@export var timing = 1.5
@export var timing_window = 0.5

#This is the actual attack, in the form of the script that runs
#See the preloaded script for an example of what an attack should look like
@export var usescript : Script = preload("res://Resources/AttackScripts/StandardAttack.gd")

@export var requires1 = false
@export var requires2 = false



#Return the script for loading by something that's part of the SceneTree
func get_script():
	return usescript
	
	
	
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
