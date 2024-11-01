@tool
extends Control


enum TYPE {
	FIGHT,
	SPECIAL,
	ITEM,
	DEFEND
}
@export var type = TYPE.FIGHT

var disabled = false
var select_color = Color()
var unselect_color = Color()

signal intro_anim_done


func _ready():
	change_text_color(Color.WHITE)
	%Text.text = get_string().to_upper()
	%Icon.texture = load("res://Graphics/UI/Icons/"+get_string()+".tres")
	if %Icon.texture == null:
		%Icon.texture = load("res://Graphics/UI/Icons/"+get_string()+".png")
	
	if %Icon.texture is AnimatedTexture:
		%Icon.texture.pause = true
		%Icon.texture.current_frame = 0


func set_selected(selected = false):
	if selected:
		$AnimationPlayer.play("Lift")
		if !disabled:
			change_text_color(select_color)
			$BG.texture = Constants.box_texture_selected
		else:
			change_text_color(Constants.disabled_color_highlight)
		%Text.label_settings.font = load("res://Fonts/battle_bold.ttf")
		if %Icon.texture is AnimatedTexture:
			%Icon.texture.pause = false
			%Icon.texture.current_frame = 0
	else:
		if %Icon.texture is AnimatedTexture:
			%Icon.texture.pause = true
			%Icon.texture.current_frame = 0
		$AnimationPlayer.play("Down")
		change_text_color(Color.WHITE)
		%Text.label_settings.font = load("res://Fonts/battle.ttf")
		if !disabled:
			$BG.texture = Constants.box_texture_selected
		
		
func set_committed(committed = true):
	if committed:
		change_text_color(Constants.commit_color)
	else:
		$BG.texture = Constants.box_texture_selected
		change_text_color(select_color)
		

func enable():
	disabled = false
	change_text_color(Color.WHITE)

func disable():
	disabled = true
	change_text_color(Constants.disabled_color)


func get_string():
	if type == TYPE.FIGHT:
		return "Fight"
	elif type == TYPE.SPECIAL:
		return "Special"
	elif type == TYPE.ITEM:
		return "Items"
	elif type == TYPE.DEFEND:
		return "Refrain"
	else:
		return "None"


func change_text_color(new_color):
	%Text.label_settings.font_color = new_color
	if new_color != Color.WHITE:
		%Icon.modulate = new_color
		$BG.self_modulate = new_color
	else:
		%Icon.modulate = unselect_color
		$BG.self_modulate = unselect_color
		
		
func set_colors(new_select_color, new_unselect_color):
	select_color = new_select_color
	unselect_color = new_unselect_color
	change_text_color(Color.WHITE)


func play_intro_anim(reverse = false):
	if !reverse:
		$IntroAnim.play("Popup",-1,1.25)
	else:
		$IntroAnim.play("Popdown",-1,1)


func _on_IntroAnim_animation_finished(_anim_name):
	emit_signal("intro_anim_done")
	
func set_panel_visible(visibility):
	$BG.visible = visibility
