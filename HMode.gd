extends Node

var player_pleasure = 0 setget set_player_pleasure
var partner_pleasure = 0 setget set_partner_pleasure

var partner_orgasms = 0

var thrust_speed = 1 setget set_thrust_speed # Thrusts/s

var base_thrust_pleasure = 0.025 # Base pleasure per thrust without any multipliers
var global_pleasure_multiplier = 1.0

var sweetspot = 0.5 # Speed sweetspot
var sweetspot_margin = 0.025 # Speed sweetspot margin
var sweetspot_multiplier = 1.0 # Multiplier when speed is just right

var orgasm_line = 0.75 # Orgasm no return point
var post_orgasm_line_modifier = 1.5 # Makes pleasure buildup faster after orgasm no return line

var partner_auto_orgasm = true # If set to true the partner will orgasm automatically on reaching max pleasure

var thrust_timer = Timer.new()

var poses = [
	{
		'name': 'dildo',
		'pleasureMults': {
			'player': 0,
			'partner': 1
		},
		'animations': {
			'idle': 'DildoPreEntryIdle',
			'start': 'DildoEntry',
			'startedIdle': 'DildoEnteredIdle',
			'lowSpeed': 'DildoPumpLow',
			'lowSpeedVariant': 'DildoPumpLowVariant',
			'lowCum': 'DildoPumpLowCum',
			'postCumIdle': 'DildoPumpLowPostCumIdle'
		}
	}
]

onready var currentPose = poses[0]

onready var animationController = get_node("../Action")

onready var gauge = get_node("CanvasLayer/HModeGauge")

var current_state

func set_player_pleasure(value):
	player_pleasure = value
	gauge.player_pleasure_level = player_pleasure
	
func set_partner_pleasure(value):
	partner_pleasure = value
	gauge.partner_pleasure_level = partner_pleasure

func set_thrust_speed(value):
	thrust_speed = value
	gauge.speed = value
	gauge.is_sweetspotted = is_sweetspotted()
	# To make the animation look better, we remap the 0 - sweetspot
	# inputs to 0 - 1.0 to make the sweetspot point be 1.0
	if value > 0:
		var modifier = 1.0
		if is_past_orgasm_line():
			modifier += 1.0
		animationController.set_speed(clamp((value * (1.0 / sweetspot) * modifier), 0.5, 1.5))
	else:
		animationController.set_speed(0)

func set_current_state(state_class):
	current_state = state_class.new()
	current_state.init(self)
	current_state.on_enter()
func _ready():
	set_current_state(PreEnterState)
	set_process(true)
	set_process_input(true)
	set_thrust_speed(0.5)
func is_past_orgasm_line():
	return partner_pleasure >= orgasm_line

func _input(event):
	current_state._input(event)

func _process(delta):
	current_state._process(delta)
	
# The more orgasms the partner has the more sensitive they are, this effect
# drops off the more orgasms they have.
func get_sensitivity_multiplier():
	return sqrt(partner_orgasms)*0.75+1

func get_sweetspot_multiplier():
	if is_sweetspotted():
		return sweetspot_multiplier
		
	else:
		return 0.25

func is_sweetspotted():
	var is_sweetspotted = false
	if thrust_speed >= sweetspot-sweetspot_margin and thrust_speed <= sweetspot+sweetspot_margin:
		is_sweetspotted = true
	return is_sweetspotted

func player_orgasm():
	pass
	
func partner_orgasm():
	partner_pleasure = 0
	partner_orgasms += 1
	set_current_state(OrgasmState)
func together_orgasm():
	partner_orgasm()
	player_orgasm()
	
class BaseState:
	var this
	func init(hmode):
		self.this = hmode
	func _process(delta):
		pass
	func _input(event):
		pass
	func on_enter():
		pass
	
class PreEnterState extends BaseState:
	var waitingForEntryToFinish = false
	func on_enter():
		this.animationController.set_speed(1)
		this.animationController.playSynchronizedAnimation(this.currentPose['animations']['idle'])
	func _input(event):
		if not waitingForEntryToFinish:
			if event.is_action("increase_thrust_speed") or event.is_action("decrease_thrust_speed"):
				waitingForEntryToFinish = true
				this.animationController.connect('animation_finished', self, 'on_animation_finish')
				this.animationController.playSynchronizedAnimation(this.currentPose['animations']['start'])
	func on_animation_finish(anim_name):
		this.set_current_state(EnteredIdleState)
			
class EnteredIdleState extends BaseState:
	func on_enter():
		this.animationController.playSynchronizedAnimation(this.currentPose['animations']['startedIdle'])
	func _input(event):
		if event.is_action("increase_thrust_speed") or event.is_action("decrease_thrust_speed"):
			this.set_current_state(ThrustState)
			
class ThrustState extends BaseState:
	func on_enter():
		this.animationController.playSynchronizedAnimation(this.currentPose['animations']['lowSpeed'])
		this.animationController.connect('animation_finished', self, 'on_animation_finish')
	func on_animation_finish(animation_name):
		pass
	func _process(delta):
		var partner_pleasure_delta = this.base_thrust_pleasure
		partner_pleasure_delta*=this.get_sensitivity_multiplier()
		partner_pleasure_delta*=this.get_sweetspot_multiplier()
		partner_pleasure_delta*=this.global_pleasure_multiplier
		
		# Apply the post-orgasm line modifier
		if this.is_past_orgasm_line():
			partner_pleasure_delta*=this.post_orgasm_line_modifier
		
		if this.thrust_speed > 0:
			this.set_partner_pleasure(this.partner_pleasure + partner_pleasure_delta*delta)
		
		# Automatic partner orgasm
		if this.partner_pleasure >= 1.0 and this.partner_auto_orgasm:
			this.partner_orgasm()
	func _input(event):
		var new_speed = 0.0
		if event.is_action("increase_thrust_speed"):
			new_speed = 1.0*this.get_process_delta_time()
		elif event.is_action("decrease_thrust_speed"):
			new_speed = -1.0*this.get_process_delta_time()
		this.thrust_speed += new_speed
		this.set_thrust_speed(clamp(this.thrust_speed, 0.0, 1.0))
		
class OrgasmState extends BaseState:
	var hasFinishedCumming = true
	func on_enter():
		this.animationController.set_speed(1)
		this.animationController.playSynchronizedAnimation(this.currentPose['animations']['lowCum'])
		this.animationController.connect('animation_finished', self, 'on_animation_finish')
	func on_animation_finish(animation_name):
		hasFinishedCumming = true
		this.animationController.playSynchronizedAnimation(this.currentPose['animations']['postCumIdle'])
		
	func _input(event):
		if event.is_action("increase_thrust_speed") or event.is_action("decrease_thrust_speed"):
			this.set_current_state(PreEnterState)