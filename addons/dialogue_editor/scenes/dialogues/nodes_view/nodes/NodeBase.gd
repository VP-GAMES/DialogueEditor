# Base node for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends GraphNode

var _nodedata

func set_nodedata(nodedata: DialogueNode) -> void:
	_nodedata = nodedata
	offset = _nodedata.position

func nodedata() -> DialogueNode:
	return _nodedata

func global_position() -> Vector2:
	return _to_global_position(offset)

func _to_global_position(graph_position : Vector2) -> Vector2:
	return graph_position * get_parent().zoom - get_parent().scroll_offset
