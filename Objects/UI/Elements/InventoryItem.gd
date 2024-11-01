extends HBoxContainer


var count = 0
var current_id = ""
var desc = ""


func _on_focus_entered():
	SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-6)
	$Arrow.visible = true
	$FArrow.visible = false
	$Count.label_settings.font_color = Constants.get("select_color")
	$Count.label_settings.font = load("res://Fonts/DialogueFontBold.tres")


func _on_focus_exited():
	$Arrow.visible = false
	$FArrow.visible = true
	$Count.label_settings.font_color = Color.WHITE
	$Count.label_settings.font = load("res://Fonts/DialogueFont.tres")
	
	
	
func set_item(item_id):
	var loaded_item = load("res://Resources/Items/"+item_id+".tres")
	$Name.text = loaded_item.attackname
	desc = loaded_item.desc
	current_id = item_id
	count += 1
	$Count.text = "(" + str(count) + ")"
	
	
func get_id():
	return current_id
	
	
func has_id(id):
	if current_id == id:
		return true
	return false
	
	
func add_one():
	count += 1
	$Count.text = "(" + str(count) + ")"


func load_item():
	return load("res://Resources/Items/"+current_id+".tres")
