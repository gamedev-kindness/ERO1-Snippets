tool
extends Control

export(Texture) var sprite_texture setget set_sprite_texture 
var sprite_rotation setget set_sprite_rotation
class_name MinimapIcon

var center_container
var sprite

var label = Label.new()

# Called when the node enters the scene tree for the first time.
func _init():
	sprite = TextureRect.new()
	center_container = CenterContainer.new()
	center_container.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	add_child(center_container)
	center_container.add_child(sprite)
	rect_min_size = Vector2(65, 65)
	
	
func _ready():
	pass
	#sprite.rect_rotation = 60
	
func set_position_centered(position):
	rect_position = position - rect_size / 2

func set_position_centered_global(position):
	rect_global_position = position - rect_size / 2

func set_sprite_texture(value):
	sprite_texture = value
	sprite.texture = value
	

func set_sprite_rotation(value):
	sprite_rotation = value
	center_container.rect_pivot_offset = center_container.rect_size/2
	center_container.rect_rotation = value
	

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
