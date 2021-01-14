# Nodes view for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _data: DialogueData
var _dialogue: DialogueDialogue

onready var _graph_ui = $Graph as GraphEdit
onready var _popup_ui = $Popup as PopupMenu

func set_data(dialogue: DialogueDialogue, data: DialogueData) -> void:
	_dialogue = dialogue
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	pass

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	_graph_ui.clear_connections()
	for node in _graph_ui.get_children():
		if node is GraphNode:
			_graph_ui.remove_child(node)
			node.queue_free()

func _draw_view() -> void:
	pass
