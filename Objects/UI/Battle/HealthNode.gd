extends Control

@onready var current_value = $Bar/TextureProgress.value

var party_num = 0
var player_num = 0
var current_texture = ""
var active = false
var collapsed = false
var targeted = false

var normal_texture = preload("res://Graphics/UI/Battle/Bars/HealthBarFull.png")
var flashing_texture = preload("res://Graphics/UI/Battle/Bars/HealthBarFlash.tres")


func set_max_value(new_max):
	$Bar/TextureProgress.max_value = new_max
	
	
func _ready():
	var data = PartyStats.load_party_id(party_num)
	
	$Bar/TextureProgress.max_value = 100
	$Bar/Icon.texture = load(data.health_icon)
	current_texture = data.health_icon.replace(".png","")
	$Bar/Border.self_modulate = data.select_color
	$Bar/Name.text = data.get_name().to_lower()
	BattleSystem.connect("side_change", side_changed)
	
	await get_tree().create_timer(0.3 + (0.2*party_num)).timeout
	$Entry.play("entry")
	
	#$Icon.rect_position -= Vector2(1,0)
	

func set_value(new_value):
	if (new_value - current_value) < 0:
		$Bar/Damage.text = str(new_value - current_value) + "%"
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Damage",-1,2.5)
		$HurtTimer.start(0.75)
		$Bar/Icon.texture = load(current_texture + "Hurt.png")
		$HurtAnim.play("shake")
		
	if new_value <= 20 and current_value > 20:
		$LowHealth.play()
		
		
	if new_value > current_value:
		if new_value <= 25:
			$Bar/Icon.texture = load(current_texture + "Dying.png")
		else:
			$Bar/Icon.texture = load(current_texture + ".png")
		
	
	create_tween().tween_property($Bar/TextureProgress, "value", new_value, 0.12)
	current_value = new_value
	$Bar/Label.text = str(new_value) + "%"
	
	if new_value <= 25:
		$Bar/TextureProgress.texture_progress = flashing_texture
		$Bar/Label.label_settings.font_color = Color(0.996094, 0.47081, 0.47081)
	else:
		$Bar/TextureProgress.texture_progress = normal_texture
		$Bar/Label.label_settings.font_color = Color.WHITE


func set_icon(new_icon):
	$Bar/Icon.texture = load(new_icon)
	
func set_color(new_color):
	$Bar/Border.self_modulate = new_color
	

func set_targeted(is_targeted = false):
	$Bar/Targeted.visible = is_targeted
	self.targeted = is_targeted


func _on_HurtTimer_timeout():
	if current_value <= 0:
		$Bar/Icon.texture = load(current_texture + "Dead.png")
	else:
		if current_value <= 25:
			$Bar/Icon.texture = load(current_texture + "Dying.png")
		else:
			$Bar/Icon.texture = load(current_texture + ".png")
			
			
func set_turn(partynum):
	if partynum[0] == player_num:
		$TurnAnim.play("Turn")
		active = true
	else:
		if active:
			active = false
			$TurnAnim.play_backwards("Turn")
			
			
func set_turn_bool(turn):
	if turn:
		active = true
	else:
		if active:
			active = false
			$TurnAnim.play_backwards("Turn")
			
			
			
func side_changed(enemyturn):
	if !enemyturn and collapsed:
		collapsed = false
		$Entry.play("expand")
	if enemyturn:
		if active:
			active = false
			$TurnAnim.play_backwards("Turn")
		if (!targeted) and (BattleSystem.num_party > 1) and (PartyStats.party.size() > 1):
			$Entry.play("collapse")
			collapsed = true
		
		
func set_skip(queue):
	if party_num in queue:
		$Bar/Skip.visible = true
	else:
		$Bar/Skip.visible = false


func _on_entry_animation_finished(_anim_name):
	pass
