extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


var use_pos


# Called when the node enters the scene tree for the first time.
func _ready():
	use_pos = position
	global_position = use_pos


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = use_pos
	
	
	
func attack():
	await get_tree().create_timer(5).timeout
	emit_signal("done_attacking")


func _on_AnimTimer_timeout():
	if $Forcefield.frame < 7:
		$Forcefield.frame += 1
	else:
		$Forcefield.frame = 0


func _on_Proximity_area_entered(area):
	if area.is_in_group("battle_player"):
		$Forcefield/ForcefieldAnim.play("Appear",-1,2)


func _on_Proximity_area_exited(area):
	if area.is_in_group("battle_player"):
		$Forcefield/ForcefieldAnim.play("Disappear",-1,2)
