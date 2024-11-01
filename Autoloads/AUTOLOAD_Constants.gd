extends Node

#Used for the grid naming scheme
const ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"


#UI colors of various varieties
const unselect_color = Color(0, 0.282353, 0.733333)
const select_color = Color(0.328125, 0.656916, 1)
const commit_color = Color(1, 0.839216, 0.145098)
const disabled_color = Color(0.37, 0.37, 0.37)
const disabled_color_highlight = Color(0.511719, 0.511719, 0.511719)


#UI Textures for easy reference
const box_texture_disabled = preload("res://Graphics/UI/Theme/BoxDisabled.png")
const box_texture_selected = preload("res://Graphics/UI/Theme/CheckboxUntickedWhite.png")
const box_texture = preload("res://Graphics/UI/Theme/CheckboxUntickedWhite.png")


#Overworld Constants
const shadow_alpha = 135


#Voices for the dialogue system
const voices = {
	"SnowResident" : {
		"Color" : Color(0.683594, 0.881348, 1),
	},
	"HellResident" : {
		"Color" : Color(1, 0.683594, 0.683594),
	},
	"Vardell" : {
		"Color" : Color(0.541176, 1, 0.545098),
		"Portraits" : {
			"None" : "",
			"Neutral" : "res://Graphics/Dialogue/vardell/normal.tres",
			"Flustered" : "res://Graphics/Dialogue/vardell/shocked1.png",
			"Sus" : "res://Graphics/Dialogue/vardell/test1.png",
			"Angry" : "res://Graphics/Dialogue/vardell/angry.tres",
			"Peeved" : "res://Graphics/Dialogue/vardell/kindaangry.png",
			"Scared" : "res://Graphics/Dialogue/vardell/scared.tres",
		},
	},
	"Shylen" : {
		"Color" : Color(1, 0.763336, 0.355469),
	},
	
	
}



const areas = [
	[
		"Old Mines", #Name
		"File_Mines", #Picture
		0.6, #Brightness. 1.0 = Fullbright, 0.0 = Pitch Dark
	],
	[
		"Battle Hall", #Name
		"File_BHall", #Picture
		1, #Brightness. 1.0 = Fullbright, 0.0 = Pitch Dark
	],
]
enum AREAS {
	MINES,
	BATTLEHALL
}
