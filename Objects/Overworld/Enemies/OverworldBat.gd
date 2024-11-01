extends CharacterBody2D


# Declare member variables here. Examples:
# var a = 2
@export_file var scenario = "res://Resources/Scenarios/Test1.tres"

@export var cutscene_on_death = false
@export_file("*.dialogue") var dialogue
@export var record_name : String

var target = null
var canmove = false

var original_pos = Vector2(0,0)
var idle_target = Vector2(0,0)



# Called when the node enters the scene tree for the first time.
func _ready():
	if load(scenario).readable_name in System.registry_lookup("finished_encounters"):
		queue_free()
	
	original_pos = position
	$FlapAnim.play("Flap",-1,1)
	$IdleTimer.start(randf_range(1,2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func reset():
	canmove = false
	target = null
	position = original_pos
	$IdleTimer.start(randf_range(2,5))

func _physics_process(delta):
	if target != null and canmove:
		if !System.cutscene:
			var target_position = global_position.direction_to(target.global_position)
			if target_position.x > 0:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = false
			velocity = target_position*60
			move_and_slide()
	else:
		if global_position != idle_target and idle_target != Vector2(0,0) and global_position.distance_to(idle_target) > 1:
			var idle_target_position = global_position.direction_to(idle_target)
			if idle_target_position.x > 0:
				$Sprite.flip_h = true
			else:
				$Sprite.flip_h = false
			velocity = idle_target_position*30
			move_and_slide()
		else:
			global_position.x = round(global_position.x)
			global_position.y = round(global_position.y)


func _on_Collision_body_entered(body):
	if body.is_in_group("overworld_player") and !System.skip_battles:
		BattleSystem.do_battle(load(scenario))
		await BattleSystem.back_in_overworld
		
		if cutscene_on_death:
			var cutscene = load("res://Objects/Cutscene.tscn").instantiate()
			get_tree().get_root().add_child(cutscene)
			cutscene.start(dialogue, record_name)
			System.cutscene = true
		
		queue_free()


func _on_Awareness_body_entered(body):
	if body.is_in_group("overworld_player") and target == null and !System.skip_battles:
		target = body
		$Aware.visible = true
		$Knows.play()
		$ShowAware.start(0.4)


func _on_ShowAware_timeout():
	canmove = true
	$Aware.visible = false


func _on_VisibilityNotifier2D_screen_exited():
	reset()


func _on_IdleTimer_timeout():
	if target == null:
		idle_target = global_position + Vector2(randi_range(-8,8),randi_range(-8,8))
		$IdleTimer.start(randf_range(2,5))


func _on_VisibilityNotifier2D_viewport_exited(viewport):
	if target != null:
		reset()
