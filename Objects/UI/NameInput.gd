extends CanvasLayer


var currenttext = ""
var maxlength = 9

var nameStrings = ["Vandus","Subjie","Deltenrun","SwichBord","Machine"]
var nameIterations = 0

signal done_with_name


# Called when the node enters the scene tree for the first time.
func _ready():
	$AppearAnim.play("Appear")
	$Paper/Name.text = currenttext
	$Popup.visible = false


func _input(event):
	if Input.is_action_just_pressed("ui_cancel") and !$Popup.visible:
		backspace()


func add_letter(text):
	if currenttext.length() + text.length() <= maxlength:
		currenttext = currenttext + text
		$Paper/Name.text = currenttext
		$WriteSound.pitch_scale = randf_range(0.8,1.2)
		$WriteSound.play()
	else:
		$CancelSound.play()
	
	
func backspace():
	currenttext.erase(currenttext.length()-1,1)
	$Paper/Name.text = currenttext
	
	
func random_string():
	currenttext = nameStrings[nameIterations]
	$Paper/Name.text = currenttext
	$WriteSound.pitch_scale = randf_range(0.8,1.2)
	$WriteSound.play()
	nameIterations += 1
	if nameIterations >= nameStrings.size():
		nameIterations = 0


func clear():
	currenttext = ""
	$Paper/Name.text = currenttext

func enter():
	if currenttext == "":
		currenttext = "Blank"
		$Paper/Name.text = currenttext
	$Popup/Margin/BG/NameRepeat.text = currenttext
	$Popup.visible = true
	$Popup/Margin/BG/Buttons/NoButton.grab_focus()

func _on_NoButton_pressed():
	$Popup.visible = false
	$Keyboard.get_focus()


func _on_YesButton_pressed():
	System.registry_set("playername",currenttext)
	System.save_game()
	emit_signal("done_with_name")
	
	$AppearAnim.play_backwards("Appear")
	await $AppearAnim.animation_finished
	queue_free()
