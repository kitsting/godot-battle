#The battle scene is basically just a container for the background and the grid
extends CanvasLayer

#Variables
var current_scenario = preload("res://Resources/Scenarios/Test1.tres")


func _ready():
	BattleSystem.reset()
	$MainGrid.setup_grid(current_scenario.get_grid())
	$MainGrid.add_enemies(current_scenario.get_enemies())
	change_background(current_scenario.get_background())
	$BattleCamera.make_current()
	
	await get_tree().create_timer(0.5).timeout
	BattleSystem.connect("side_change", change_sides)


func change_sides(enemyturn):
	if !enemyturn:
		#Remove any stray bullets when it's the player's turn
		get_tree().call_group("bullet","queue_free")
		create_tween().tween_property($Background.get_child(0),"modulate",Color(1,1,1,1),0.4)
	else:
		create_tween().tween_property($Background.get_child(0),"modulate",Color(0.8,0.8,0.8,1),0.4)


func change_background(new_background):
	for child in $Background.get_children():
		if child.name != "DimBG":
			child.queue_free()
	var new_bg_instance = load(new_background).instantiate()
	$Background.add_child(new_bg_instance)


func _on_GridCollapser_area_entered(area):
	if area.is_in_group("grid_piece_collision"):
		if BattleSystem.current_scenario.state == 2:
			area.get_parent().fall()
			
			
func get_center_point():
	return $Center.position
