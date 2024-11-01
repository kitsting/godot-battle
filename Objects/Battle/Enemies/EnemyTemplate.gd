extends Node2D

@export_group("General characteristics")
@export var support_enemy = false
@export var boss = false

@export_group("Stats")

@export_subgroup("Normal")
@export var hp = 10;
@export var damage = 10;
@export_range(-1, 1, 0.05) var defense = 0.0;
@export var enemyname = "Test Enemy"
@export_multiline var enemydesc = "Does literally nothing and dies"

@export_subgroup("Advanced")
@export var advanced_hp = 10;
@export var advanced_damage = 10;
@export_range(-1, 1, 0.05) var advanced_defense = 0.0;
@export var advanced_name = ""
@export_multiline var advanced_desc = ""

var is_advanced = false
var metadata_int = 0

var max_hp = hp

var times_hit = 0
var enemy_number = 0
var gridrow = 0

var attacking = false
var play_entry_animation = false

var can_attack = true
var alone = false

signal done_attacking

@onready var gridref : Node = null



func _ready():
	if is_advanced:
		if advanced_name != "":
			enemyname = advanced_name
		if advanced_desc != "":
			enemydesc = advanced_desc
		max_hp = advanced_hp
		hp = advanced_hp
		damage = advanced_damage
		defense = advanced_defense
	
	gridref = get_tree().get_nodes_in_group("battle_grid")[0]
	$Sprite.set_material($Sprite.get_material().duplicate(true))
	BattleSystem.connect("side_change", my_turn)
	$CanvasLayer/ProgressBar.max_value = hp
	$CanvasLayer/ProgressBar.value = hp
	$CanvasLayer/Arrows.position.y -= 4
	am_selected(false)
	show_small_arrow(false)
	initialize()
	
#	if boss:
#		$CanvasLayer/ProgressBar/HealthPercent.visible = true
#	else:
	$CanvasLayer/ProgressBar/HealthPercent.visible = false
	
	if play_entry_animation:
		entry()
		emit_signal("done_attacking")
		
	if support_enemy:
		add_to_group("support_enemy")
	else:
		add_to_group("normal_enemy")
		
	randomize()
	
	$Sprite.play()
	
	
func _process(delta):
	if !support_enemy:
		if gridref.get_not_dead_enemies("normal_enemy").size() == 1:
			alone = true
		else:
			alone = false
	$Sprite/Hitbox.damage = damage
	$CanvasLayer.offset = global_position + Vector2(0, 12)
	idle(delta)
	
	
func get_max_health():
	return $CanvasLayer/ProgressBar.max_value


func take_damage(amount, ignore_defense = false):
	var loss = 0
	if defense == 1:
		loss = 0
	else:
		loss = max(0, round(amount*(1-defense)))
	hp -= loss
	#$CanvasLayer/Label.text = "-" + str(loss)
	$CanvasLayer/ProgressBar/HealthPercent.text = str(floor(hp/max_hp))+"%"
	if loss > 0:
		$Hit.play()
		$AnimationPlayer.play("shake",-1,1.65)
		if $Sprite.sprite_frames.has_animation("hit"):
			$Sprite.animation = "hit"
		$CanvasLayer/ProgressBar.visible = true
		create_tween().tween_property($CanvasLayer/ProgressBar,"value",hp,0.45)
		on_hit()
	else:
		$Reflect.play()
		

	times_hit += 1
	
	var new_dmg_display = load("res://Objects/UI/Battle/DamageDisplay.tscn").instantiate()
	new_dmg_display.set_position(global_position)
	new_dmg_display.set_damage(loss)
	get_tree().get_root().add_child(new_dmg_display)
	
	if hp <= 0:
		can_attack = false
		await get_tree().create_timer(0.2).timeout
		$AnimationPlayer.play("RESET")
		gridref.remove_enemy(enemy_number)
		die()
		
		

func attack():
	await get_tree().create_timer(5).timeout
	emit_signal("done_attacking")
	

func on_hit():
	pass
	
func idle(_delta):
	pass
	
func initialize():
	pass
	
func entry():
	pass
	
func die():
	if boss:
		System.battle_cutscene = true
		get_tree().call_group("battle_ui","lock_ui")
		$AnimationPlayer.play("boss_death")
		await $AnimationPlayer.animation_finished
		$ExplosionLayer.visible = true
		SoundSystem.play_sound("res://Sounds/Enemy/generic/boss_death.wav", "battle_sfx")
		$Sprite.visible = false
		$CanvasLayer.visible = false
		if has_node("Shadow"):
			get_node("Shadow").visible = false
		await create_tween().tween_property($ExplosionLayer/ColorRect, "color:a", 0, 2).finished
		
		
	queue_free()


func show_healthbar(healthbar_show = true):
	$CanvasLayer/ProgressBar.visible = healthbar_show
	
	
func my_turn(enemyturn):
	show_healthbar(false)
	if enemyturn:
		if support_enemy:
			if gridref.get_not_dead_enemies("normal_enemy").size() == 0:
				can_attack = false
				await get_tree().create_timer(0.5).timeout
				die()
		
		show_glow(false)
		#await get_tree().create_timer(0.5).timeout
		if hp > 0:
			attacking = true
			#attack()
	if !enemyturn:
		attacking = false
		
		
func show_arrow(arrow_show = true):
	$CanvasLayer/Arrows/Arrow.visible = arrow_show
	
func show_small_arrow(arrow_show = true):
	$CanvasLayer/Arrows/SmallArrow.visible = arrow_show
	

func show_glow(glow_show = true):
	if glow_show:
		$GlowPlayer.play("glow")
	else:
		$GlowPlayer.play("stop glowing")
		
		
func am_selected(selected):
	show_small_arrow(!selected)
	show_glow(selected)
	show_arrow(selected)
	show_healthbar(selected)



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "shake":
		if $Sprite.animation == "hit" and $Sprite.sprite_frames.has_animation("idle"):
			$Sprite.animation = "idle"
		await get_tree().create_timer(0.1).timeout
		show_healthbar(false)
		
