# Dialogue dialogue for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueDialogue, "res://addons/dialogue_editor/icons/Dialogue.png"

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor: EditorPlugin
var _undo_redo: UndoRedo

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/dialogue_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****
signal node_added(node)
signal node_removed(node)

export (String) var uuid
export (String) var name = ""
export (Vector2) var scroll_offset = Vector2.ZERO
export (Array) var nodes

func add_node_start(position: Vector2, sendSignal = true) -> void:
		var node = _create_node_start(position)
		if _undo_redo != null:
			_undo_redo.create_action("Add node start")
			_undo_redo.add_do_method(self, "_add_node", node)
			_undo_redo.add_undo_method(self, "_del_node", node)
			_undo_redo.commit_action()
		else:
			_add_node(node, sendSignal)

func _create_node_start(position: Vector2) -> DialogueNode:
	var node_start = DialogueNode.new()
	node_start.uuid = UUID.v4()
	node_start.type = DialogueNode.START
	node_start.name = "Start"
	node_start.position = position
	return node_start

func _add_node(node: DialogueNode, sendSignal = true) -> void:
	nodes.append(node)
	emit_signal("node_added", node)
