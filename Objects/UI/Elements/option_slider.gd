@tool
extends HBoxContainer


@export var label = "Label:":
	set(new_label):
		$Label.text = new_label
		
		label = new_label
	get:
		return label
		
@export var property = "master_volume"


func _ready():
	$HSlider.value = System.options[property] * 100


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


func _on_h_slider_value_changed(value):
	SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
	$Percent.text = str(value) + "%"
	System.option_set(property, value/100)
