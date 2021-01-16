# Node start for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends "res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/NodeBase.gd"

var _data: DialogueData
var _node: DialogueNode
var _dialogue: DialogueDialogue

func node() -> DialogueNode:
	return _node

func set_data(node: DialogueNode, dialogue: DialogueDialogue, data: DialogueData) -> void:
	_node = node
	_dialogue = dialogue
	_data = data
	offset = _node.position

func _ready() -> void:
	set_slot(0, false, 0, Color(1, 1, 1), true, 0, Color(1, 1, 1))

func selected_slot() -> Vector2:
	return Vector2.ZERO
