extends Node

#Signals
signal equipsuccessful(success)


#Variables
var party = ["You", "Vardell"]
var defense_boost = 0
var focus_boost = 0
var inventory = []
var inventory_copy = []
var key_items = []
var max_inventory = 20


var has_badges = []
var equipped_badges = [null, null, null]


#Set the defense boost for the party
func boost_defense(amount, unboost = false):
	if !unboost:
		defense_boost += amount
	else:
		defense_boost = 0


#Set the focus boost for the party
func boost_focus(amount, unboost = false):
	if !unboost:
		focus_boost += amount
	else:
		focus_boost = 0
		
		
func has_badge(badge_name):
	return badge_name in equipped_badges
	
	
func badge_in_inventory(badge_name):
	if has_badges.find(badge_name) != -1:
		print("badge found")
		return true
	else:
		print("badge not found")
		return false


func get_badge(badge_name):
	for badge in equipped_badges:
		if load("res://Resources/Badges/"+badge+".tres").badge_id == badge_name:
			return load("res://Resources/Badges/"+badge+".tres")
	return null


func load_badge(badge):
	return load("res://Resources/Badges/"+badge+".tres")


func equip_badge(badge_name, slot):
	if slot < equipped_badges.size():
		equipped_badges[slot] = badge_name


func dequip_badge(badge_name):
	if has_badge(badge_name):
		#badge_slots += load_badge(badge_name).badge_slots
		equipped_badges.erase(badge_name)
		
		
func add_badge(badge_name):
	if !has_badge(badge_name):
		has_badges.append(badge_name)

func load_inventory():
	var new_inventory = []
	for item in inventory:
		new_inventory.append(load("res://Resources/Items/"+item+".tres"))
	return new_inventory
	
func remove_inventory(item):
	inventory.erase(item.attackid)
	
func add_inventory(item_name):
	var success = true
	if inventory.size() < max_inventory:
		inventory.append(item_name)
	else:
		success = false
		
	return success
	
	
func copy_inventory(save = true):
	if save:
		inventory_copy = inventory.duplicate()
	else:
		inventory = inventory_copy.duplicate()

func load_party_id(slot : int):
	if slot < party.size():
		return load("res://Resources/PartyMembers/"+party[slot]+".tres")
	else:
		return null
	
	
func load_party_name(member_name : String):
	return load("res://Resources/PartyMembers/"+member_name+".tres")
	
	
	
func has_party(member_name: String):
	if member_name in party:
		return true
	return false
