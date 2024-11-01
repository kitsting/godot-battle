extends Resource
class_name BattleScenario

#ENEMY ALIGNMENT
#  5
#1   3
#  0
#2   4
#  6


#GRID KEY
#x - Normal square
#m - Missing square
#ice / i - Ice Square
#web / w - Web Square
#cdown - Conveyor belt (Down)
#cup - Conveyor belt (Up)
#cleft - Conveyor belt (Left)
#cright - Conveyor belt (Right)
#l - Lava Square

#0 - You (or party member #1)
#1 - Shylen (or party member #2)
#2 - Vardell (or party member #3)



@export var readable_name : String = ""
@export var description = "DefaultDesc"
@export_enum("Easy", "Moderate", "Hard", "Very Hard") var difficulty = 1
@export_multiline var grid : String
@export_multiline var challenge_desc = ""
@export var coins = 10
@export var is_boss = false
@export var enemies : Array[EnemyData]
@export_file("*.tscn") var background
@export_file("*.ogg") var music
@export var custom_color = Color(0.015686, 0.188235, 0.407843) #Default grid color
@export var custom_pattern : Texture
@export_enum("Normal", "Wheels", "Moving") var state = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#Return music if any is set, else return the default battle music
func get_music():
	if music != "" and music != null:
		return music
	else:
		return "res://Sounds/Music/Step Right Up.ogg"


#Get the colors of the grid in the form of a PoolColorArray
func get_colors():
	if custom_pattern == null:
		return [custom_color]
	else:
		if custom_pattern is Texture:
			var image = custom_pattern.get_image()
			#image.lock()
			var returncolors = []
			for y in image.get_height():
				for x in image.get_width():
					var usecolor = image.get_pixel(x,y)
					if usecolor.a != 0:
						returncolors.append(usecolor)
			return returncolors
		else:
			return [custom_color]
		
		
#Get the background of the battle if one is set, else fall back to Squares
func get_background():
	if background != "" and background != null:
		return background
	else:
		return "res://Objects/Battle/Backgrounds/Squares.tscn"
		
		
#Get the grid in the form of a 2D
func get_grid():
	var returngrid = []
	#Parse each item and replace with proper names if necessary
	for line in grid.split("\n"):
		var grid_row = []
		for square in line.split(" "):
			if square == "m":
				grid_row.append("missing")
			elif square == "cdown":
				grid_row.append("conveyor_down")
			elif square == "cup":
				grid_row.append("conveyor_up")
			elif square == "cleft":
				grid_row.append("conveyor_left")
			elif square == "cright":
				grid_row.append("conveyor_right")
			elif square == "l":
				grid_row.append("lava")
			elif square == "i":
				grid_row.append("ice")
			elif square == "w":
				grid_row.append("web")
			else:
				grid_row.append(square)
		returngrid.append(grid_row)
	return returngrid
	
	
#Get the enemies (setting no enemies will result in the battle ending instantly)
func get_enemies():
	return enemies


#Get the number of party members used in the battle
func get_num_party():
	var numparty = 0
	for character in grid:
		if character in "0123456789":
			numparty += 1
	return numparty
	
	
func has_in_grid(string):
	if string in grid:
		return true
	return false

func get_battle_name():
	if readable_name == null:
		return ""
	else:
		return readable_name


func get_enemy_count():
	var count = 0
	for enemy in enemies:
		if enemy != null:
			if enemy.enemyscene != null:
				count += 1
				
	return count
