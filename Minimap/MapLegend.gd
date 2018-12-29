extends ColorRect

var base_color := Color("#323b4f")

var hover_color := Color("#6A9EEA")

func on_hover():
	color = hover_color
func on_stop_hovering():
	color = base_color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_marker(marker_data):
	$VBoxContainer/HBoxContainer/Label.text = marker_data["name"]
	$VBoxContainer/HBoxContainer/TextureRect.texture = marker_data["icon"]