extends "res://System/Scenes/Utils/EROGameUI.gd"

var marker_categories = {}

export(NodePath) var road_renderer

const DEFAULT_MAP_SCALE = 10.0

const MapLegend = preload("res://System/Scenes/GameModes/OpenWorld/MapLegend.tscn")

#warning-ignore:unused_argument
func _process(delta):
	if visible:
		var player = EROGameModeManager.game_mode.player
		if player:
			set_map_origin(player.global_transform.origin)
			var camera_gimball = player.character.camera_gimball_base
			var rotation = camera_gimball.global_transform.basis.orthonormalized().get_euler() 
			rect_pivot_offset = rect_size / 2
			rect_rotation = rad2deg(-(rotation.y)) - 180.0

# Called when the node enters the scene tree for the first time.
func _ready():
	var map_manager = EROGameModeManager.game_mode.map_manager
	if map_manager:
		map_manager.connect("new_marker", self, "add_new_marker")

	connect("resized", self, "update_viewport_size")
	get_renderer().scale = DEFAULT_MAP_SCALE
	on_show()
	

	
func on_show():
	update_viewport_size()
	get_renderer().scale = DEFAULT_MAP_SCALE



func global2map(origin):
	return get_renderer().global3d2minimap(origin)

func set_map_origin(origin):
	get_renderer().set_origin(origin)
	update_all_marker_transforms()

func update_all_marker_transforms():
	for marker_list in marker_categories.values():
		for marker_data in marker_list:
			update_marker_transform(marker_data)

func update_viewport_size():
	get_renderer_viewport().size = rect_size

func add_new_marker(marker):
	var legend_entry = MapLegend.instance()
	if not marker_categories.has(marker.type):
		legend_entry.set_marker(marker.get_marker_type_data())
		marker_categories[marker.type] = []
	
	var map_icon = MinimapIcon.new()
	map_icon.sprite_texture = marker.get_marker_icon()

	var marker_data = {
		"map_icon": map_icon,
		"world_marker": marker
	}

	marker_categories[marker.type].append(marker_data)

	get_node("../MapIcons").add_child(map_icon)

	marker.connect("marker_position_changed", self, "update_marker_transform", [marker_data])

	update_marker_transform(marker_data)

func update_marker_transform(marker_data):
	var map_icon = marker_data["map_icon"]
	var marker = marker_data["world_marker"]

	var position = global2map(marker.global_transform.origin)

	var position_transform = Transform2D()
	
	position_transform.origin = position
	position_transform = get_global_transform() * position_transform
	map_icon.set_position_centered_global(position_transform.origin)
	
	var map_icons_container = get_node("../MapIcons")
	
	if marker.important:
		map_icon.rect_position.x = clamp(map_icon.rect_position.x, -map_icon.rect_size.x * 0.25, map_icons_container.rect_size.x - map_icon.rect_size.x * 0.75)
		map_icon.rect_position.y = clamp(map_icon.rect_position.y, -map_icon.rect_size.y * 0.25, map_icons_container.rect_size.y - map_icon.rect_size.y * 0.75)

	if marker.display_rotation:
		var rotation = marker.global_transform.basis.get_euler()
		map_icon.sprite_rotation = rad2deg(-(rotation.y)) + rect_rotation

func get_renderer():
	return get_node(road_renderer).get_node("RoadRenderer")

func get_renderer_viewport():
	return get_node(road_renderer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
