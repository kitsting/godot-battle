extends Node2D


var use_countdown = false
var countdown = 5

var grid_position = Vector2(0,0)

var play_appear_animation = false


func _process(_delta):
	$CanvasLayer.offset = global_position
#	$Subnodes/Label.text = countdown
	$Subnodes/Label.visible = use_countdown
	
	
func _ready():
	$Subnodes/Warning.play()
	$Subnodes/Wheel.play()
	
	hide_guides(true)
	
	if BattleSystem.current_scenario.state == 1:
		set_wheels()
		
	if play_appear_animation:
		$Collapse.play("appear")

func show_arrow(arrow_show = true):
	$CanvasLayer/Arrow.visible = arrow_show
	
func show_small_arrow(arrow_show = true):
	$CanvasLayer/SmallArrow.visible = arrow_show
	
func set_modulate(color):
	$Subnodes/Sprite.modulate = color
	$Subnodes/Wall.modulate = color
	$Subnodes/Wall2.modulate = color
	$Subnodes/Guides.modulate = color
	

func show_glow(glow_show = true):
	if glow_show:
		$AnimationPlayer.play("glow")
	else:
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("RESET")
		
		
func warn(time):
	$Subnodes/Warning.visible = true
	$WarnTimer.start(time)


func _on_WarnTimer_timeout():
	$Subnodes/Warning.visible = false


func set_wheels():
	$Subnodes/Wall.visible = false
	$Subnodes/Wall2.visible = true
	$Subnodes/Wheel.visible = true
	
	
func am_selected(selected):
	show_small_arrow(!selected)
	show_arrow(selected)
	show_glow(selected)
	
	
func clear_selection():
	show_small_arrow(false)
	show_arrow(false)
	show_glow(false)
	


func _on_Area2D_area_entered(area):
	if area.is_in_group("battle_player"):
		if use_countdown:
			if countdown != 0:
				countdown -= 1
			$Subnodes/Label.text = str(countdown)
			if countdown == 0:
				fall()
					
					
func fall():
	$Collapse.play("shake",-1,2.5)
	await get_tree().create_timer(1.5).timeout
	$Collapse.play("fall")
	await get_tree().create_timer(0.5).timeout
	await $Collapse.animation_finished
	queue_free()



func add_object(object):
	for child in $Subnodes/FObjects.get_children():
		child.queue_free()
	$Subnodes/Objects.add_child(object)
	
	
func add_fobject(object):
	for child in $Subnodes/FObjects.get_children():
		child.queue_free()
	$Subnodes/FObjects.add_child(object)
	

func set_appear_animation(play):
	play_appear_animation = play


func show_r_guides():
	create_tween().tween_property($Subnodes/Guides/R1, "modulate:a", 1, 0.4)
	create_tween().tween_property($Subnodes/Guides/R2, "modulate:a", 1, 0.4)
	
	
func hide_guides(immediate = false):
	for guide in $Subnodes/Guides.get_children():
		if !immediate:
			create_tween().tween_property(guide, "modulate:a", 0, 0.4)
		else:
			guide.modulate.a = 0
