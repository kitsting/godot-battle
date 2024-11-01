extends Area2D

var secret_name = "secret name"
var group_to_call = "secret"


func _ready():
	if secret_name in System.registry_lookup("found_secrets"):
		activate()

func _on_body_entered(body):
	if body.is_in_group("overworld_player"):
		SoundSystem.play_sound("res://Sounds/Secret.wav", "overworld")
		System.registry_append("found_secrets", secret_name)
		activate()
		
		
func activate():
	get_tree().call_group(group_to_call, "activate")
	queue_free()
