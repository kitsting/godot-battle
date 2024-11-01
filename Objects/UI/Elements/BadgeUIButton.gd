extends TextureButton

var slot = 0

@export var badge_id : String = "null"
@export var desc = "Equip a pin here!"
@export var badge_name = "No Pin"
@export var badge_icon : Texture:
	set(new_icon):
		texture_normal = new_icon
		badge_icon = new_icon
		if badge_id != "null" and badge_id != "cancel":
			$ShimmerMask.texture = new_icon
			$Edge/Edge1.texture = new_icon
			$Edge/Edge2.texture = new_icon
			$Edge.visible = true
	get:
		return badge_icon
@export var choose_mode = false

var can_select = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/Select.visible = false
	
	if PartyStats.has_badge(badge_id) and choose_mode:
		can_select = false
		$ShimmerMask/Overlay.visible = true
		$Equipped.visible = true
		badge_name = badge_name + " (Equipped)"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CanvasLayer.offset = global_position


func _on_focus_entered():
	SoundSystem.play_sound("res://Sounds/UI/UI_Navigate.wav","ui_battle",-6)
	if badge_id != "cancel":
		$ShimmerAnim.play("Shimmer")
	$CanvasLayer/Select.visible = true


func _on_focus_exited():
	$CanvasLayer/Select.visible = false


func _on_pressed():
	SoundSystem.play_sound("res://Sounds/UI/UI_Select.wav","ui_battle",-6)
	if !choose_mode:
		var choice_window = load("res://Objects/UI/Elements/GetBadge.tscn").instantiate()
		add_child(choice_window)
		get_tree().call_group("badgeui","set_can_exit",false)
		var choice = await choice_window.selected
		
		if choice != "cancel":
			if choice != "null":
				PartyStats.equip_badge(choice, slot)
				var badge_info = PartyStats.load_badge(choice)
				desc = badge_info.badge_desc
				badge_name = badge_info.badge_name
				badge_icon = badge_info.badge_sprite
			else:
				PartyStats.equip_badge(null, slot)
				desc = "Equip a pin here!"
				badge_name = "No Pin"
				badge_icon = load("res://Graphics/UI/Menus/BadgeUI/BadgeEmptyNew.png")
		
		await get_tree().process_frame
		
		grab_focus()
		get_tree().call_group("badgeui","set_can_exit",true)
