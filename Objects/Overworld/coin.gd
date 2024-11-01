extends KinematicBody2D

var moving = false
var direction = Vector2(0,0)
var speed = 30


func explode():
	var tempdir = rand_range(0,360)
	direction = Vector2(cos(deg2rad(tempdir)),sin(deg2rad(tempdir)))
	speed = rand_range(1,2)
	moving = true
	$Tween.interpolate_property(self, "speed", speed, 0, 3)
	$Tween.start()
	
	
func _physics_process(delta):
	if moving:
		direction = move_and_slide(direction * speed * delta * 60)


func _on_Collection_body_entered(body):
	if body.is_in_group("overworld_player"):
		System.collect_money(1)
		queue_free()
