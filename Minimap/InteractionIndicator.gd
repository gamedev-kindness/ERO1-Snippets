extends Spatial

enum BUTTON_MODES {
	NORMAL,
	ONE_USE
}

const FILL_SPEED = 100

onready var visibility_notifier = get_node("VisibilityNotifier")

onready var progress = get_node("EROGameUI/TextureProgress")

onready var label = get_node("EROGameUI/TextureProgress/NinePatchRect/Label") 

onready var position_dot = get_node("PositionDot") 

export(BUTTON_MODES) var MODE = BUTTON_MODES.NORMAL
export(bool) var starts_disabled = false 
export(String) var text
export(float) var max_distance = 3.0

var is_disabled = false

var is_deployed = false

signal on_use

func _ready():
	set_process(true)
	label.text = text
	is_disabled = starts_disabled

func _process(delta):
	
	var world_postion = global_transform.origin
	
	var screen_position = get_tree().get_root().get_camera().unproject_position(world_postion)

	screen_position = screen_position - Vector2(32,32)

	var visible_on_screen = visibility_notifier.is_on_screen()
	
	progress.visible = is_deployed and is_visible_on_screen() and not is_disabled
	
	progress.rect_position = screen_position
	
	if progress.visible:
		if Input.is_action_pressed("use"):
			progress.value += FILL_SPEED*delta
			if progress.value >= 100:
				use()
		else:
			progress.value = 0
			
	if not is_disabled and not is_deployed and is_visible_on_screen():
		position_dot.rect_position = screen_position
		position_dot.visible = true
	else:
		position_dot.visible = false
func use():
	progress.value = 0
	if MODE == BUTTON_MODES.ONE_USE:
		is_disabled = true
	
	emit_signal("on_use")
		
func deploy():
	is_deployed = true
	print("ENABLE BUTTON")
		
func undeploy():
	is_deployed = false
	print("DISABLE BUTTON")
		
func is_visible_on_screen():
	return visibility_notifier.is_on_screen()
	
func reset():
	print("RESETTING: %s" % text)
	is_disabled = false