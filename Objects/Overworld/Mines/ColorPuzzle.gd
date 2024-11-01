extends Node2D


var red = 0
var blue = 0
var green = 0
var solved = false

@export var puzzle_name = "Puzzle Name"
@export var call_on_solve = "color_puzzle_solution"
@export var correct_red = 0
@export var correct_blue = 0
@export var correct_green = 0


func _ready():
	if puzzle_name in System.registry_lookup("solved_puzzles"):
		solve()


func update_display():
	$Display/RedNumber.texture = load("res://Graphics/Overworld/Mines/ColorPuzzle/"+str(red)+".png")
	$Display/BlueNumber.texture = load("res://Graphics/Overworld/Mines/ColorPuzzle/"+str(blue)+".png")
	$Display/GreenNumber.texture = load("res://Graphics/Overworld/Mines/ColorPuzzle/"+str(green)+".png")
	
	if !solved:
		if blue == correct_blue and green == correct_green and red == correct_red:
			solved = true
			SoundSystem.play_sound("res://Sounds/Misc/Impact.wav","overworld")
			System.registry_append("solved_puzzles",puzzle_name)
			solve()


func increment_red():
	if !solved:
		red += 1
		if red > 9:
			red = 0
			
		$Pressed.pitch_scale = 0.8 + (0.05*red)
		$Pressed.play()
		update_display()
	
	
func increment_blue():
	if !solved:
		blue += 1
		if blue > 9:
			blue = 0
			
		$Pressed.pitch_scale = 0.8 + (0.05*blue)
		$Pressed.play()
		update_display()
	
	
func increment_green():
	if !solved:
		green += 1
		if green > 9:
			green = 0
		
		$Pressed.pitch_scale = 0.8 + (0.075*green)
		$Pressed.play()
		update_display()


func solve():
	solved = true
	
	green = correct_green
	blue = correct_blue
	red = correct_red
	update_display()
	
	$RedButton/Sprite2D.texture = load("res://Graphics/Overworld/Mines/ColorPuzzle/InactiveButton.png")
	$BlueButton/Sprite2D.texture = load("res://Graphics/Overworld/Mines/ColorPuzzle/InactiveButton.png")
	$GreenButton/Sprite2D.texture = load("res://Graphics/Overworld/Mines/ColorPuzzle/InactiveButton.png")
	
	get_tree().call_group(call_on_solve, "activate")
