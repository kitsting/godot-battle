extends Sprite2D


@export_file("*.tres") var scenario = "res://Resources/Scenarios/Test1.tres"


# Called when the node enters the scene tree for the first time.
func _ready():
	BattleSystem.connect("battle_finished",check_finished)
	check_finished()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func check_finished():
	if load(scenario).readable_name in System.registry_lookup("finished_encounters"):
		texture = load("res://Graphics/Overworld/BattleHall/BattleLightOn.png")
