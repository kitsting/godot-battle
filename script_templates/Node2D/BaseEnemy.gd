extends "res://Objects/Battle/Enemies/EnemyTemplate.gd"


# Called when the node enters the scene tree for the first time.
# Use this instead of _ready()
func intiialize():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	
	#Process code here


#Called when the enemy attacks
func attack():
	
	#Attacking code here
	
	emit_signal("done_attacking")
	
	
#Called on hit
func on_hit():
	pass
	

#Custom entry animation
func entry():
	pass


#Called when health reaches 0
func die():
	queue_free()
