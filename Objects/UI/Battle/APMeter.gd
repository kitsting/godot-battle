extends Control

var current_value
var in_preview = false
var old_value = 0


func _ready():
	$Loss.visible = false
	$Bar.value = BattleSystem.maxap
	$Bar/PreviewBar.value = 0
	current_value = $Bar.value
	BattleSystem.connect("ap_changed", update_value)
	BattleSystem.connect("ap_preview", preview_value)
	BattleSystem.connect("end_ap_preview", end_preview)


func update_value(new_value):
	end_preview()
	$Bar.max_value = BattleSystem.maxap
	$Bar/PreviewBar.max_value = BattleSystem.maxap
	
	if new_value < current_value:
		$Bar.value = new_value
		$Bar/PreviewBar.value = current_value
		$Loss.text = str(new_value-current_value) + "%"
		$APAnim.stop()
		$APAnim.play("Loss",-1,3)
		create_tween().tween_property($Bar/PreviewBar,"value",new_value,0.4)
	else:
		create_tween().tween_property($Bar,"value",new_value,0.2)
	
	current_value = new_value
	$Label.text = str(new_value) + "%"

func preview_value(new_value):
	in_preview = true
	$Label2.text = str(new_value-current_value)+"%"
	$Label2.visible = true
	
	$Bar/PreviewBar.value = current_value
	create_tween().tween_property($Bar,"value",new_value,0.1)
	
func end_preview():
	if in_preview:
		in_preview = false
		await get_tree().create_timer(0.1).timeout
		$Label2.visible = false
		$Bar.value = current_value
		$Bar/PreviewBar.value = 0
