@tool
extends HBoxContainer

@export var label = "Label:":
	set(new_label):
		$Label.text = new_label
		
		label = new_label
	get:
		return label
		
@export var property = "controller_prompts"
@export var desc = "Option description"

@export var keys : Array[String]
@export var values : Array

var cycle_position = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	print(str(System.options[property])+" in "+str(values)+" : "+str(values.find(System.options[property])))
	if values.find(System.options[property]) != -1:
		cycle_position = values.find(System.options[property])
		$Selection.text = str(keys[cycle_position])
	else:
		$Selection.text = str(keys[0])
		
	update_arrows()


func _on_focus_entered():
	SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-6)
	$Arrow.visible = true
	$FArrow.visible = false
	$Label.label_settings.font_color = System.get_select_color()
	$Label.label_settings.font = load("res://Fonts/DialogueFontBold.tres")


func _on_focus_exited():
	$Arrow.visible = false
	$FArrow.visible = true
	$Label.label_settings.font_color = Color.WHITE
	$Label.label_settings.font = load("res://Fonts/DialogueFont.tres")
	
	
func update_arrows():
	if keys[0] == $Selection.text:
		$LeftArrow.modulate.a = 0.1
	else:
		$LeftArrow.modulate.a = 1
		
	if keys.back() == $Selection.text:
		$RightArrow.modulate.a = 0.1
	else:
		$RightArrow.modulate.a = 1
		
		
func _input(event):
	if has_focus():
		if Input.is_action_just_pressed("ui_left"):
			if $Selection.text != keys[0]:
				SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
				cycle_position -= 1
				$Selection.text = keys[cycle_position]
				update_arrows()
				System.option_set(property, values[cycle_position])
		if Input.is_action_just_pressed("ui_right"):
			if $Selection.text != keys.back():
				SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
				cycle_position += 1
				$Selection.text = keys[cycle_position]
				System.option_set(property, values[cycle_position])
				update_arrows()
