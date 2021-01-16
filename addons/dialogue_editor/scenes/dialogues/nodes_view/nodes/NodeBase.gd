# Base node for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends GraphNode

func global_position() -> Vector2:
	return _to_global_position(offset)

func _to_global_position(graph_position : Vector2) -> Vector2:
	return graph_position * get_parent().zoom - get_parent().scroll_offset
