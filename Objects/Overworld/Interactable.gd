@tool
extends Area2D


@export_file("*.dialogue") var dialogue
@export var record_name : String

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
		System.interacting_object = self
		TextSystem.show_dialogue(record_name, dialogue)
		await TextSystem.text_finished
		cooldown = true
		await get_tree().create_timer(0.1).timeout
		cooldown = false
	
	
func _ready():
	$Object/Collision.disabled = disable_collision
