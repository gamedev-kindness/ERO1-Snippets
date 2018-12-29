tool
extends Position3D

class_name WorldMarker

signal marker_position_changed

enum MarkerType {
	PLAYER,
	DOT
}

var marker_type_data = {
	MarkerType.PLAYER: {
		"name": "Player",
		"icon": preload("res://System/Textures/ui/Icons/nav_player.png")
	},
	MarkerType.DOT: {
		"name": "Point of interest",
		"icon": preload("res://System/Textures/ui/Icons/nav_dot.png")
	}
}

export(MarkerType) var type = MarkerType.PLAYER

#warning-ignore:unused_class_variable
export(String) var marker_name = "Marker"

#warning-ignore:unused_class_variable
export(bool) var display_rotation = false

#warning-ignore:unused_class_variable
export(bool) var important = false

var tool_placeholder = preload("res://System/Scenes/World/ToolPlaceholder.tscn").instance()
const PLACEHOLDER_TEXTURE = preload("res://System/Textures/ui/World/EditorHints/minimap.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(tool_placeholder)
	tool_placeholder.translation = Vector3()
	tool_placeholder.texture = PLACEHOLDER_TEXTURE
	if not Engine.editor_hint:
		var map_manager = EROGameModeManager.game_mode.map_manager
		if map_manager:
			map_manager.add_marker(self)
	set_notify_transform(true)
		
func _notification(what):
	if not Engine.editor_hint:
		"""
		if what == NOTIFICATION_PREDELETE:
			if EROGameModeManager.game_mode:
				var map_manager = EROGameModeManager.game_mode.map_manager
				if map_manager:
					map_manager.delete_marker(self)
		"""
		if what == NOTIFICATION_TRANSFORM_CHANGED:
			emit_signal("marker_position_changed")
	
func get_marker_icon():
	return get_marker_type_data()["icon"]
	
func get_marker_type_data():
	return marker_type_data[type]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
