extends Node

#Signals
signal self_talk


func start(cutscene_file, record_name):
	TextSystem.show_dialogue(record_name,cutscene_file)
	System.registry_append("seen_cutscenes",cutscene_file+"|"+record_name)
	#This cutscene is OVER
	queue_free()
