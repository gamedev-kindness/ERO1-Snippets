extends Control

class_name road_renderer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var scale = 3.0 setget set_scale

const ROAD_COLOR = Color("#fff")

const BUILDING_COLOR = Color("#CBCBCB")

const ROAD_BORDER_COLOR = Color("#777777")

#warning-ignore:unused_class_variable
var width_varies_with_scale = true

var origin = Vector3()

func get_transformed_origin():
	return -Vector2(origin.x, origin.z) * scale

# Called when the node enters the scene tree for the first time.
func _ready():
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _draw():
	var road_roots = get_tree().get_nodes_in_group("minimap_roads")
	for root_node in road_roots:
		draw_roads(root_node)
		
	var buildings = get_tree().get_nodes_in_group("minimap_buildings")
	
	for building in buildings:
		draw_building(building)
	
func set_origin(origin):
	#rect_position = -Vector2(origin.x, origin.z) * scale
	if self.origin != origin:
		self.origin = origin
		update()
func global2minimap(position) -> Vector2:
	position *= scale
	position += get_parent().size / 2
	return position
	
func global3d2minimap(position) -> Vector2:
	var map_position = Vector2(position.x, position.z)
	
	map_position *= scale
	map_position += get_parent().size / 2
	
	return map_position - Vector2(origin.x, origin.z) * scale
	
func set_scale(value):
	if scale != value:
		scale = value
		set_origin(origin)
		update()

func draw_building(building : CollisionShape):
	if building.get_shape() is BoxShape:
		var building_center := global3d2minimap(building.global_transform.origin)
		var building_extents := Vector2()
		
		building_extents.x = building.get_shape().extents.x * scale
		building_extents.y = building.get_shape().extents.z * scale
		
		draw_set_transform(building_center, -building.rotation.y, Vector2(1,1))
		var rect := Rect2(-building_extents, building_extents * 2)
		
		draw_rect(rect, BUILDING_COLOR)
		
		
func draw_road_lines(node, width = 2.5, road_color=ROAD_COLOR):
	var from = global3d2minimap(node.global_transform.origin)
	for child in node.get_children():
		var to = global3d2minimap(child.global_transform.origin)
		
		var width_scaled = width * scale

		draw_line(from, to, road_color, width_scaled, true)
		if child.get_child_count() > 1:
			draw_circle(to, width_scaled/2, road_color)
		draw_road_lines(child, width, road_color)
		
func draw_roads(node):
	draw_road_lines(node, 3.0, ROAD_BORDER_COLOR)
	draw_road_lines(node)