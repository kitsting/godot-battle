extends Resource
class_name PartyMember


## Basic stats about the marty member
@export_category("Party Member Info")

## Party member name. Shows up in menus
@export var name = "Member"

## When ticked, the above name is replaced with the
## user-defined name at the start of the game
@export var use_playername = false

## How much damage this party member deals
## This is not the exact value, but rather a ratio
@export var attack = 5

## Damage taken is subtracted by this amount
@export var defense = 0

## AP used is subtracted by this amount
@export var ap_reduction = 0


## Sprites and colors used in the overworld and during battle
@export_category("Colors and Sprites")

## Icon shown on the health bar during battle
@export_file("*.png") var health_icon = "res://Graphics/UI/Icons/Party/23Icon.png"

## Color used when highlighting a menu item in battle
## Also used in the healthbar
@export var select_color = Color(0.33, 0.66, 1)

## Color used for windows in battle
@export var unselect_color = Color(0, 0.28, 0.73)

## List of possible overworld sprites
@export var overworld_sprites : Array[SpriteFrames]

## List of possible battle sprites
@export var battle_sprites : Array[SpriteFrames]

## Get index for overworld and battle sprites
## Align the two for best results
@export var costume = 0


## Variables that change through the game (and are saved)
@export_category("Battle and Inventory")

## Attacks shown in the "Fight" menu
@export var basic_attacks : Array[String] = []
## Attacks shown in the "Special" menu
@export var special_attacks : Array[String] = ["Check", "Defend", "Focus"]

## Enemies in these groups will instill fear
@export var fears : Array[String] = []


func update_name():
	if use_playername:
		name = System.registry_lookup("playername")


#Load various arrays of strings
func load_attacks():
	var attack_array = []
	for loadattack in basic_attacks:
		attack_array.append(load("res://Resources/Attacks/"+loadattack+".tres"))
	if System.registry_lookup("learned_attacks_"+get_lower_name()) != null:
		for loadattack2 in System.registry_lookup("learned_attacks_"+get_lower_name()):
			print("adding learned attack "+str(loadattack2))
			attack_array.append(load("res://Resources/Attacks/"+loadattack2+".tres"))
	return attack_array
	
func load_special_attacks():
	var attack_array = []
	for loadattack in special_attacks:
		attack_array.append(load("res://Resources/SpecialAttacks/"+loadattack+".tres"))
	if System.registry_lookup("learned_special_"+get_lower_name()) != null:
		for loadattack2 in System.registry_lookup("learned_special_"+get_lower_name()):
			attack_array.append(load("res://Resources/SpecialAttacks/"+loadattack2+".tres"))
	return attack_array


#Add to arrays
func learn_attack(attack_name):
	if System.registry_lookup("learned_attacks_"+get_lower_name()) != null:
		System.registry_append("learned_attacks_"+get_lower_name(), attack_name)
	
func learn_special_attack(attack_name):
	if System.registry_lookup("learned_special_"+get_lower_name()) != null:
		System.registry_append("learned_special_"+get_lower_name(), attack_name)


func get_overworld_costume():
	if costume < overworld_sprites.size():
		return overworld_sprites[costume]
	else:
		return overworld_sprites[0]
		
		
func get_battle_costume():
	if costume < battle_sprites.size():
		return battle_sprites[costume]
	else:
		return battle_sprites[0]


func get_member_name():
	if !use_playername:
		return name
	else:
		return System.registry_lookup("playername")


#Saving and loading
func get_dict():
	var save_dict = {
		"ap_reduction" : ap_reduction,
		"basic_attacks" : basic_attacks,
		"special_attacks" : special_attacks,
	}
	return save_dict
	
	
func load_dict(dictionary):
	ap_reduction = dictionary["ap_reduction"]
	
	var basic_temp = []
	for basic in dictionary["basic_attacks"]:
		basic_temp.append(basic)
	basic_attacks = basic_temp
	
	var special_temp = []
	for special in dictionary["special_attacks"]:
		special_temp.append(special)
	special_attacks = special_temp

func get_fears():
	return fears

func get_lower_name():
	if !use_playername:
		return name.to_lower()
	else:
		return "you"
