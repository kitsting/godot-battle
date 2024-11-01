extends CanvasLayer

const LIST_BATTLE_SCENE = preload("res://Objects/UI/Elements/ListBattle.tscn")

@export var battles : Array[String]

signal closed

var exit_cooldown = true




func _ready():
	
	for battle in battles:
		var new_listbattle = LIST_BATTLE_SCENE.instantiate()
		new_listbattle.set_battle(battle)
		new_listbattle.connect("focused",update_battle_info)
		new_listbattle.connect("selected", start_battle)
		%BattleList.add_child(new_listbattle)
		
	$OuterMargin/Panel/InnerMargin/VBox/Upper/BackButton.grab_focus()
		
	exit_cooldown = true
	await get_tree().create_timer(0.1).timeout
	exit_cooldown = false
	
	
func update_battle_info(scenario):
	%BattleInfo/Name.text = scenario.get_battle_name()
	%BattleInfo/MoreInfo/Enemies/Count.text = str(scenario.get_enemy_count())
	
	if scenario.is_boss:
		%BattleInfo/Info/Sep.visible = true
		%BattleInfo/Info/Boss.visible = true
	else:
		%BattleInfo/Info/Sep.visible = false
		%BattleInfo/Info/Boss.visible = false
		
	match scenario.difficulty:
		0:
			%BattleInfo/Info/Difficulty.text = "Easy"
		1:
			%BattleInfo/Info/Difficulty.text = "Moderate"
		2:
			%BattleInfo/Info/Difficulty.text = "Hard"
		3:
			%BattleInfo/Info/Difficulty.text = "Very Hard"
		_:
			%BattleInfo/Info/Difficulty.text = "Normal"

	%BattleInfo/MoreInfo/Reward/Count.text = str(scenario.coins)
	
	%BattleInfo/Desc.text = scenario.challenge_desc


func start_battle(scenario):
	BattleSystem.do_battle(scenario, true)
	exit()


func _on_back_button_pressed():
	pass


func _on_back_button_button_down():
	if !exit_cooldown:
		System.cutscene = false
		exit()
		
func exit():
	emit_signal("closed")
	queue_free()
