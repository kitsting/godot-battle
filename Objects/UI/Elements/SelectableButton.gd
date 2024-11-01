extends Button


@export var desc = "Button description"
@export var button_icon : Texture

var select_color = Color(1,1,1)
var unselect_color = Color(0.5,0.5,0.5)


# Called when the node enters the scene tree for the first time.
func _ready():
	if !disabled:
		self_modulate = System.get_unselect_color()
	else:
		%Label.modulate.a = 0.7
		%Icon.modulate.a = 0.7
	%Label.text = text
	%Icon.texture = button_icon
	text = ""
	
	select_color = System.get_select_color()
	unselect_color = System.get_unselect_color()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SelectableButton_focus_entered():
	SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-6)
	if !disabled:
		self_modulate = select_color
		%Label.label_settings.font_color = select_color
		%Icon.modulate = select_color
	%Label.label_settings.font = load("res://Fonts/DialogueFontBold.tres")
	$Select.visible = true


func _on_SelectableButton_focus_exited():
	if !disabled:
		self_modulate = unselect_color
		%Label.label_settings.font_color = Color.WHITE
		%Icon.modulate = Color.WHITE
	%Label.label_settings.font = load("res://Fonts/DialogueFont.tres")
	$Select.visible = false

func set_custom_modulate(color):
	self_modulate = color
	

func set_new_text(text_string):
	%Label.text = text_string


func _on_button_down():
	SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
