extends Area2D

@export_file("*.dialogue") var dialogue
@export var record_name : String

var activated = false


func _ready():
	var cutseen = dialogue + "|" + record_name
	if cutseen in System.registry_lookup("seen_cutscenes"):
		queue_free()

func _on_CutsceneTrigger_body_entered(body):
	if !activated and !System.skipcutscenes:
		if body.is_in_group("overworld_player"):
			var cutscene = load("res://Objects/Cutscene.tscn").instantiate()
			get_tree().get_root().add_child(cutscene)
			cutscene.start(dialogue, record_name)
			activated = true
		#queue_free()
