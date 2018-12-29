extends Node

signal marker_position_changed
signal new_marker

func add_marker(marker):
	
	emit_signal("new_marker", marker)
	
func delete_marker(marker):
	emit_signal("marker_deleted", marker)