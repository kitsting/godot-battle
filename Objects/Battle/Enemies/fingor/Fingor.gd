extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


var cool = false
var flamin = false

var speed_modifier = 1
var main_speed = 2

var gridsize = Vector2(0,0)
var handpos = Vector2(0,0)

var vertical = false

var start_moving = false


@export var forgor = false

# Called when the node enters the scene tree for the first time.
func initialize():
	$Hand/Hitbox.damage = damage
	
	randomize()
	
	cool = !randi() % 10
	flamin = !randi() % 50
	
	if cool:
		$Sprite/Shades.visible = true
		enemyname = "Cool " + enemyname
		speed_modifier *= 1.1
	
	
	if flamin and forgor:
		$Sprite/Shades.visible = true
		enemyname = "Flamin' " + enemyname
		speed_modifier *= 1.5
		
	gridsize = get_parent().get_parent().gridpiecesize
	handpos = $Hand.position
	
	if forgor:
		main_speed = 3


func attack():
	var pos = gridref.get_random_grid()
	
	vertical = randi() % 2
	
	await create_tween().tween_property($Hand, "modulate", Color(1,1,1,0),0.2).finished
	
	if vertical:
		$Hand.global_position = Vector2(gridref.get_grid_position(Vector2i(pos.x, 0)) + gridref.get_grid_topleft_position())
		$Hand.global_position.y -= gridsize.y
		$Hand.rotation -= deg_to_rad(90)
	else:
		$Hand.global_position = Vector2(gridref.get_grid_position(Vector2i(0, pos.y)) + gridref.get_grid_topleft_position())
		$Hand.global_position.x += gridref.get_grid_horizontal_size() * gridsize.x
		
	create_tween().tween_property($Hand,"modulate",Color(1,1,1,1),0.2)
	await get_tree().create_timer(0.9).timeout
		
	$Timer.start(2)
	start_moving = true
			
			
func idle(delta):
	if start_moving:
		if vertical:
			$Hand.position.y += main_speed * delta * 60 * speed_modifier
		else:
			$Hand.position.x -= main_speed * delta * 60 * speed_modifier


func _on_Timer_timeout():
	start_moving = false
	$Hand.position = handpos
	$Hand.rotation = 0
	emit_signal("done_attacking")
