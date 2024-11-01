extends CanvasLayer

var knows_dev_attacks = false


func _input(_event):
	if Input.is_action_just_pressed("debug"):
		$Debug.visible = !$Debug.visible
	
	if $Debug.visible:
			
		if Input.is_action_just_pressed("cutscenes"):
			System.skipcutscenes = !System.skipcutscenes
			
		if Input.is_action_just_pressed("battles"):
			System.skip_battles = !System.skip_battles
			
		if Input.is_action_just_pressed("dev_attacks"):
			if System.registry_lookup("learned_attacks_you") == []:
				knows_dev_attacks = true
				System.registry_set("learned_attacks_you", ["KillAll"])
				System.registry_set("learned_attacks_vardell", ["KillAll"])
			else:
				knows_dev_attacks = false
				System.registry_set("learned_attacks_you", [])
				System.registry_set("learned_attacks_vardell", [])


func _on_update_timer_timeout():
	if $Debug.visible:
		$Debug/FPS.text = "FPS: " + str(Engine.get_frames_per_second())
		$Debug/Memory.text = "Mem: " + str(OS.get_static_memory_usage()/(1024*1024.0)) + "MB"
		
		$Debug/Icons/Collision.self_modulate = get_icon_modulate_color(get_tree().is_debugging_collisions_hint())
		$Debug/Icons/Cutscenes.self_modulate = get_icon_modulate_color(System.skipcutscenes)
		$Debug/Icons/Battles.self_modulate = get_icon_modulate_color(System.skip_battles)
		$Debug/Icons/DevMoves.self_modulate = get_icon_modulate_color(knows_dev_attacks)
		
		
	
func bool_to_string(boolean):
	if boolean:
		return "Y"
	else:
		return "N"


func show_area_name(area_name):
	$AreaNameDisplay.text = str(area_name)
	$AreaNameAnim.play("ShowAreaName")


func get_icon_modulate_color(boolean):
	if boolean:
		return Color(1,1,1)
	return Color(0.5,0.5,0.5)
