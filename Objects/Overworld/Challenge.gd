@tool
extends Area2D


@export_file("*.tscn") var shop_scene

@export var size = Vector2(16,16):
	set(new_size):
		$CollisionShape2D.shape.extents.x = new_size.x/2
		$CollisionShape2D.shape.extents.y = new_size.y/2
		
		$Object/Collision.shape.extents.x = new_size.x/2
		$Object/Collision.shape.extents.y = new_size.y/2
		
		size = new_size
	get:
		return size

@export var disable_collision : bool = false

var cooldown = false

func interact():
	if !cooldown:
		cooldown = true
		System.interacting_object = self
		TextSystem.show_dialogue("AskChallenge", "res://Dialogue/GlobalDialogue.dialogue")
		var choice = await TextSystem.choice_selected
		if choice == "Yes":
			System.cutscene = true
			var menu = load("res://Objects/UI/Challenges.tscn").instantiate()
			add_child(menu)
			await get_tree().create_timer(0.05).timeout
			System.cutscene = true
			await menu.closed
		
		await get_tree().create_timer(0.1).timeout
		cooldown = false
	
	
func _ready():
	$Object/Collision.disabled = disable_collision
