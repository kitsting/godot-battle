extends TextureRect


@export var action_name : String = ""
@export_file("*.png") var xbox_texture : String = ""
@export_file("*.png") var nintendo_texture : String = ""
@export_file("*.png") var playstation_texture : String = ""
@export_file("*.png") var pc_texture : String = ""

var current_texture = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = load(pc_texture)
	current_texture = pc_texture
	InputHelper.connect("device_changed", _on_device_changed)
	_on_device_changed(InputHelper.guess_device_name(),0)


func _on_device_changed(device: String, _device_index: int) -> void:
	if System.options["buttons"] == int(0):
		if device == InputHelper.DEVICE_XBOX_CONTROLLER:
			texture = load(xbox_texture)
			current_texture = xbox_texture
		elif device == InputHelper.DEVICE_SWITCH_CONTROLLER:
			texture = load(nintendo_texture)
			current_texture = nintendo_texture
		elif device == InputHelper.DEVICE_PLAYSTATION_CONTROLLER:
			texture = load(playstation_texture)
			current_texture = playstation_texture
		else:
			texture = load(pc_texture)
			current_texture = pc_texture
		
		
func _input(_event):
	if System.options["buttons"] == int(1):
		texture = load(pc_texture)
		current_texture = pc_texture
	elif System.options["buttons"] == int(2):
		texture = load(xbox_texture)
		current_texture = xbox_texture
	elif System.options["buttons"] == int(3):
		texture = load(playstation_texture)
		current_texture = playstation_texture
	elif System.options["buttons"] == int(4):
		texture = load(nintendo_texture)
		current_texture = nintendo_texture
		
		
	if action_name != "":
		if Input.is_action_just_pressed(action_name):
			texture = load(get_pressed_texture(current_texture))
			
		if Input.is_action_just_released(action_name):
			texture = load(current_texture)


func get_pressed_texture(texturepath):
	return texturepath.split(".")[0]+"_pressed.png"
