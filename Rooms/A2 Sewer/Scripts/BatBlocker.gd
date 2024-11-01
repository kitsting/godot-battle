extends StaticBody2D


func set_active(is_active):
	$Collision.disabled = !is_active
	$Cutscener/Collision.disabled = !is_active


func _on_cutscener_body_entered(body):
	if body.is_in_group("overworld_player"):
		TextSystem.show_dialogue("BatIntroEscape", "res://Dialogue/DemoDialogueMinesNew.dialogue")
