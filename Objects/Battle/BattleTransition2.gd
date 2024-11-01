extends CanvasLayer

signal midpoint
signal done


func _ready():
	$AnimationPlayer.play("In",-1,3)
	await get_tree().create_timer(0.05).timeout
	$Top.visible = true
	$Middle.visible = true
	$Bottom.visible = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "In":
		$AnimationPlayer.play("Load",-1,3)
		await get_tree().create_timer(0.1).timeout
		emit_signal("midpoint")
	elif anim_name == "Out":
		emit_signal("done")
		queue_free()
	elif anim_name == "Load":
		$AnimationPlayer.play("Out",-1,3)


func set_members(numberarray):
	var iteration = 0
	for member in numberarray:
		if iteration < PartyStats.party.size() and member == true:
			if PartyStats.party[iteration] == "You":
				$Middle/YouEyes.visible = true
			elif PartyStats.party[iteration] == "Vardell":
				$Top/VardellEyes.visible = true
			elif PartyStats.party[iteration] == "Shylen":
				$Bottom/ShylenEyes.visible = true
		iteration += 1
