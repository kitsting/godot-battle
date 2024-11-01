extends CanvasLayer

#Signals
signal text_finished(next_id)

#Default variables regarding the text and it's properties
var box_dialogue : DialogueLine
var textsound = load("res://Sounds/TextSounds/Default.wav")

var text_finished_typing = false
var choice_selection = false


func text_done():
	#Stop the portrait from talking if it's animated
	if $Background/TextMargin/Contents/Portrait.texture is AnimatedTexture:
		$Background/TextMargin/Contents/Portrait.texture.pause = true
		$Background/TextMargin/Contents/Portrait.texture.current_frame = 0
	
	#Show indicator if no choices are present
	if box_dialogue.responses == []:
		%Indicator.visible = true
		text_finished_typing = true
	#Show choices if choices are present
	else:
		for choice in %Choices.get_children():
			await get_tree().create_timer(0.2).timeout
			choice.visible = true
		await get_tree().create_timer(0.2).timeout
		%Choices.get_child(0).grab_focus()
		await get_tree().create_timer(0.2).timeout
		choice_selection = true


func letter_done(letter, _index, _speed):
	if !letter in [" ",".",",","!","?"]:
		$TextSound.play()
		if $Background/TextMargin/Contents/Portrait.texture is AnimatedTexture:
			$Background/TextMargin/Contents/Portrait.texture.pause = false
	else:
		if !letter in [" "]:
			if $Background/TextMargin/Contents/Portrait.texture is AnimatedTexture:
				$Background/TextMargin/Contents/Portrait.texture.pause = true
				$Background/TextMargin/Contents/Portrait.texture.current_frame = 0

#Set the text color
func set_text_color(newcolor):
	%MainText.self_modulate = newcolor

#Set the visibility of the background
func set_background_visibility(show_bg = true):
	$Background.self_modulate = Color(1, 1, 1, show_bg)
	
#Set the character portrait
func set_portrait(texture):
	$Background/TextMargin/Contents/Portrait.texture = load(texture)


func _ready():
	$Background.self_modulate = System.get_unselect_color()
	%Indicator.visible = false
	$TextSound.stream = textsound
	%MainText.connect("finished_typing",text_done)
	%MainText.connect("spoke", letter_done)
	populate_choices()
	await get_tree().create_timer(0.1).timeout
	%MainText.dialogue_line = box_dialogue
	%MainText.type_out()


#Check for user input
func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		if text_finished_typing:
			emit_signal("text_finished",box_dialogue.next_id)
			queue_free()
			
		if choice_selection:
			var focused = get_viewport().gui_get_focus_owner()
			TextSystem.emit_signal("choice_selected",focused.get_text())
			emit_signal("text_finished",focused.nextid)
			queue_free()


func populate_choices():
	for choice in box_dialogue.responses:
		var new_choice = load("res://Objects/UI/Elements/DialogueChoice.tscn").instantiate()
		new_choice.set_text(choice.text)
		new_choice.nextid = choice.next_id
		new_choice.visible = false
		%Choices.add_child(new_choice)
