@tool
extends Node2D


enum DIRECTION {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

@export var dir = DIRECTION.DOWN:
	set(new_dir):
		if new_dir == DIRECTION.DOWN:
			$Sprite.texture = load("res://Graphics/Overworld/Transition/TransDown.png")
		elif new_dir == DIRECTION.UP:
			$Sprite.texture = load("res://Graphics/Overworld/Transition/TransUp.png")
		elif new_dir == DIRECTION.LEFT:
			$Sprite.texture = load("res://Graphics/Overworld/Transition/TransLeft.png")
		elif new_dir == DIRECTION.RIGHT:
			$Sprite.texture = load("res://Graphics/Overworld/Transition/TransRight.png")
		
		dir = new_dir
		
		update_width()
	get:
		return dir

@export var width_tiles = 1:
	set(new_width):
		width_tiles = new_width
		update_width()
		
		
@export var wall_height = 4

@export_file("*.tscn") var destination
@export_file("*.tscn") var quick_destination

@export var quick_flag : String

@export var custom_pos : Vector2

@export var invisible = false
@export var disabled = false


func get_player_offset():
	if dir == DIRECTION.UP:
		return Vector2(0, -30)
	elif dir == DIRECTION.DOWN:
		return Vector2(0, 30)
	elif dir == DIRECTION.LEFT:
		return Vector2(-30, (wall_height/2)*16)
	elif dir == DIRECTION.RIGHT:
		return Vector2(30, (wall_height/2)*16)
	else:
		return Vector2(0, 0)
		
		
func get_direction():
	return dir
		
func get_exit_offset():
	if dir == DIRECTION.UP:
		return Vector2(0, 30)
	elif dir == DIRECTION.DOWN:
		return Vector2(0, -30)
	elif dir == DIRECTION.LEFT:
		return Vector2(30, 0)
	elif dir == DIRECTION.RIGHT:
		return Vector2(-30, 0)
	else:
		return Vector2(0, 0)
		
		
func dir_to_string():
	match dir:
		DIRECTION.UP:
			return "down"
		DIRECTION.DOWN:
			return "up"
		DIRECTION.LEFT:
			return "right"
		DIRECTION.RIGHT:
			return "left"
		_:
			return "up"
		
	

func _on_Area2D_body_entered(body):
	if body.is_in_group("overworld_player"):
		if destination != null and !disabled:
			System.cutscene = true
			body.move_cutscene(get_exit_offset().x, get_exit_offset().y, 0.35, true)
			body.set_anim(dir_to_string()+"_walk")
			System.registry_set("room_entry_dir", dir)
			System.registry_set("current_room", destination)
			#System.save_game()
			var new_transition = load("res://Objects/Battle/ToBlack.tscn").instantiate()
			new_transition.set_speed(2.5)
			get_tree().get_root().add_child(new_transition)
			await new_transition.midpoint
			System.cutscene = false
			get_tree().change_scene_to_file(destination)
			
			
func _ready():
	if !Engine.is_editor_hint():
		#Turn invisible if marked as invisible
		if invisible:
			visible = false
		#Force a sprite update
		dir = dir



func update_width():
	if width_tiles != null:
		if width_tiles >= 1:
			if dir == DIRECTION.LEFT or dir == DIRECTION.RIGHT:
				scale.x = 1
				scale.y = width_tiles
			else:
				scale.y = 1
				scale.x = width_tiles
